import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'mock_interceptor.dart';

/// ApiInterceptor attaches Bearer auth tokens to outgoing requests,
/// automatically refreshes expired JWT tokens upon receiving 401,
/// and standardizes API headers.
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

    final isAuthEndpoint = path.contains('/auth/login') ||
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
    if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final statusCode = response?.statusCode;

    // Token Auto-Refresh on 401 Unauthorized
    if (statusCode == 401 &&
        err.requestOptions.extra['isRetry'] != true &&
        !err.requestOptions.path.contains(ApiEndpoints.refreshToken) &&
        !err.requestOptions.path.contains(ApiEndpoints.login)) {
      final refreshToken = _storage.read<String>(AppConstants.refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeoutMs),
            receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
          ));

          final refreshResponse = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final data = refreshResponse.data;
            String? newAccessToken;
            if (data is Map<String, dynamic>) {
              if (data['data'] != null && data['data'] is Map<String, dynamic>) {
                newAccessToken = data['data']['accessToken'] as String?;
              } else {
                newAccessToken = data['accessToken'] as String?;
              }
            }

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              await _storage.write(AppConstants.tokenKey, newAccessToken);

              // Retry original request with new token
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              opts.extra['isRetry'] = true;

              final retryResponse = await dio.fetch(opts);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          await _storage.remove(AppConstants.tokenKey);
          await _storage.remove(AppConstants.refreshTokenKey);
        }
      }
    }

    return super.onError(err, handler);
  }
}
