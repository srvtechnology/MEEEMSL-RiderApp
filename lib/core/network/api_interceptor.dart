import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'mock_interceptor.dart';
import 'rate_limit_parser.dart';

/// ApiInterceptor attaches the mandatory mobile client authentication header
/// (`x-meeem-app-token`) and Bearer auth tokens to outgoing requests,
/// automatically refreshes expired JWT tokens upon receiving 401,
/// and parses HTTP 429 rate-limit responses globally.
class ApiInterceptor extends Interceptor {
  final Dio dio;
  final GetStorage _storage = GetStorage();

  ApiInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    // Strictly enforce: DO NOT call any API not documented in Part 1 or Part 2
    if (!ApiEndpoints.isDocumentedEndpoint(path)) {
      final mockResponse = MockInterceptor.getMockResponse(options);
      return handler.resolve(mockResponse);
    }

    // Attach required mobile client authentication token to every /mobileapi/... request
    options.headers[AppConstants.mobileAppTokenHeader] = AppConstants.mobileAppToken;

    final isAuthEndpoint = path.contains('/auth/login') ||
        path.contains(ApiEndpoints.verify2fa) ||
        path.contains(ApiEndpoints.resend2fa) ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/resend-otp') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/phone-otp');

    final token = _storage.read<String>(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty && !isAuthEndpoint) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    if (options.data is FormData) {
      options.headers.remove('Content-Type');
      options.headers.remove('content-type');
      options.contentType = null;
    } else if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final statusCode = response?.statusCode;

    // Global HTTP 429 Rate-Limit & Cooldown Parsing
    if (statusCode == 429) {
      final rateLimitEx = RateLimitParser.fromResponse(response);
      err.requestOptions.extra['rateLimitException'] = rateLimitEx;
      err.requestOptions.extra['retryAfter'] = rateLimitEx.retryAfter;
      return handler.next(
        err.copyWith(
          error: rateLimitEx,
          message: rateLimitEx.message,
        ),
      );
    }

    // Do NOT treat a missing/invalid mobile client auth token (401) as an expired user JWT
    if (RateLimitParser.isMobileClientTokenError(err)) {
      return super.onError(err, handler);
    }

    // Token Auto-Refresh on 401 Unauthorized
    if (statusCode == 401 &&
        err.requestOptions.extra['isRetry'] != true &&
        !err.requestOptions.path.contains(ApiEndpoints.refreshToken) &&
        !err.requestOptions.path.contains(ApiEndpoints.login) &&
        !err.requestOptions.path.contains(ApiEndpoints.verify2fa) &&
        !err.requestOptions.path.contains(ApiEndpoints.resend2fa)) {
      final refreshToken = _storage.read<String>(AppConstants.refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        String? newAccessToken;
        String? newRefreshToken;
        bool shouldClearTokens = false;

        try {
          final refreshDio = Dio(BaseOptions(
            baseUrl: dio.options.baseUrl.isNotEmpty
                ? dio.options.baseUrl
                : ApiEndpoints.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeoutMs),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              AppConstants.mobileAppTokenHeader: AppConstants.mobileAppToken,
            },
          ));
          refreshDio.httpClientAdapter = dio.httpClientAdapter;

          final refreshResponse = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final data = RateLimitParser.decodeBodyMap(refreshResponse.data);
            if (data != null) {
              final nestedData = data['data'] is Map ? data['data'] as Map : null;
              final nestedTokens = nestedData?['tokens'] is Map
                  ? nestedData!['tokens'] as Map
                  : (data['tokens'] is Map ? data['tokens'] as Map : null);

              newAccessToken = _firstNonEmptyString([
                nestedTokens?['accessToken'],
                nestedTokens?['token'],
                nestedData?['accessToken'],
                nestedData?['token'],
                data['accessToken'],
                data['token'],
              ]);
              newRefreshToken = _firstNonEmptyString([
                nestedTokens?['refreshToken'],
                nestedData?['refreshToken'],
                data['refreshToken'],
              ]);
            }
          }

          if (newAccessToken == null) {
            shouldClearTokens = true;
          }
        } on DioException catch (refreshErr) {
          final refreshCode = refreshErr.response?.statusCode;
          if (refreshCode == 401 || refreshCode == 403) {
            shouldClearTokens = true;
          }
        } catch (_) {
          shouldClearTokens = true;
        }

        if (shouldClearTokens) {
          await _storage.remove(AppConstants.tokenKey);
          await _storage.remove(AppConstants.refreshTokenKey);
          return super.onError(err, handler);
        }

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storage.write(AppConstants.tokenKey, newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storage.write(AppConstants.refreshTokenKey, newRefreshToken);
          }

          // Retry original request with new token and mobile app header preserved.
          // Clone finalized FormData so multipart uploads (e.g. /onboarding) can be retried cleanly.
          final opts = err.requestOptions;
          if (opts.data is FormData) {
            final originalFormData = opts.data as FormData;
            if (originalFormData.isFinalized) {
              opts.data = originalFormData.clone();
            }
            opts.headers.remove('Content-Type');
            opts.headers.remove('content-type');
            opts.contentType = null;
          }
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          opts.headers[AppConstants.mobileAppTokenHeader] = AppConstants.mobileAppToken;
          opts.extra['isRetry'] = true;

          try {
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          } on DioException catch (retryErr) {
            return handler.next(retryErr);
          } catch (_) {
            return super.onError(err, handler);
          }
        }
      }
    }

    return super.onError(err, handler);
  }

  String? _firstNonEmptyString(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }
}
