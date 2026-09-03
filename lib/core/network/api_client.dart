import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'dio_client.dart';
import 'logger/api_logger.dart';

enum AppEnvironment { staging, production }

class ApiClient extends GetConnect {
  static const Map<AppEnvironment, String> _baseUrls = {
    AppEnvironment.staging: 'https://development.meeemsl.com',
    AppEnvironment.production: 'https://www.meeemsl.com',
  };

  static AppEnvironment _env = AppEnvironment.production;

  static void setEnvironment(AppEnvironment env) {
    _env = env;
    if (Get.isRegistered<ApiClient>()) {
      Get.find<ApiClient>().httpClient.baseUrl = null;
    }
    if (Get.isRegistered<DioClient>()) {
      Get.find<DioClient>().dio.options.baseUrl = ApiEndpoints.baseUrl;
    }
  }

  static AppEnvironment get currentEnvironment => _env;
  static String get currentBaseUrl => _baseUrls[_env]!;
  static String get riderApiBaseUrl => '$currentBaseUrl/mobileapi/rider';

  /// Dynamically converts any URL string to use the active [currentBaseUrl].
  /// Replaces hardcoded domains with active environment base URL.
  static String formatUrl(String url) {
    if (url.trim().isEmpty) return url;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (trimmed.contains('meeemsl.com') || trimmed.contains('meeem.com')) {
        return trimmed.replaceAll(
          RegExp(r'https?://(development\.|www\.|api\.|cdn\.)?meeem(sl)?\.com(:\d+)?'),
          currentBaseUrl,
        );
      }
      if (trimmed.contains('localhost') || trimmed.contains('127.0.0.1')) {
        return trimmed.replaceAll(
          RegExp(r'https?://(localhost|127\.0\.0\.1)(:\d+)?'),
          currentBaseUrl,
        );
      }
      return trimmed;
    }
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (cleanPath.startsWith('/mobileapi/rider')) {
      return '$currentBaseUrl$cleanPath';
    }
    return '$riderApiBaseUrl$cleanPath';
  }

  final GetStorage _storage = GetStorage();

  /// Persistent high-performance native HTTP client with connection pooling
  /// and keep-alive to avoid frequent SSL handshakes and latency on low-end phones.
  late final io.HttpClient _ioClient;

  @override
  void onInit() {
    httpClient.baseUrl = null;
    httpClient.timeout = const Duration(seconds: 120);

    _ioClient = io.HttpClient()
      ..connectionTimeout = const Duration(seconds: 120)
      ..idleTimeout = const Duration(seconds: 30)
      ..maxConnectionsPerHost = 10;

    super.onInit();
  }

  @override
  void onClose() {
    _ioClient.close(force: true);
    super.onClose();
  }

  dynamic _extractRequestBody(dynamic body) {
    if (body == null) return null;
    if (body is FormData) {
      final Map<String, dynamic> fields = {};
      for (var entry in body.fields) {
        fields[entry.key] = entry.value;
      }
      for (var entry in body.files) {
        fields[entry.key] = 'File: ${entry.value.filename} (${entry.value.contentType})';
      }
      return fields;
    }
    return body;
  }

  /// High-performance non-blocking request executor using native dart:io HttpClient.
  /// Streams files directly to avoid single-byte chunking ANRs on low-end devices.
  Future<Response<T>> _executeRequest<T>(
    String method,
    String? url, {
    dynamic body,
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    if (url == null || url.trim().isEmpty) {
      return Response<T>(
        statusCode: null,
        statusText: 'URL cannot be null or empty',
      );
    }

    final formattedUrl = formatUrl(url);
    var uri = Uri.parse(formattedUrl);

    if (query != null && query.isNotEmpty) {
      final mergedQuery = Map<String, String>.from(uri.queryParameters);
      query.forEach((key, value) {
        if (value != null) mergedQuery[key] = value.toString();
      });
      uri = uri.replace(queryParameters: mergedQuery);
    }

    final startTime = DateTime.now().millisecondsSinceEpoch;
    final logId = AsyncApiLogger.instance.logRequest(
      method: method,
      url: uri.toString(),
      headers: headers,
      body: _extractRequestBody(body),
    );

    io.HttpClientRequest? ioRequest;
    try {
      ioRequest = await _ioClient.openUrl(method, uri);
      ioRequest.followRedirects = true;
      ioRequest.maxRedirects = 5;

      // Headers setup
      final path = uri.path;
      final isAuthEndpoint = path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/verify-otp') ||
          path.contains('/auth/resend-otp') ||
          path.contains('/auth/forgot-password') ||
          path.contains('/auth/phone-otp');

      final token = _storage.read<String>(AppConstants.tokenKey);
      if (token != null && token.isNotEmpty && !isAuthEndpoint) {
        ioRequest.headers.set('Authorization', 'Bearer $token');
      }
      ioRequest.headers.set('Accept', 'application/json');

      if (headers != null) {
        headers.forEach((key, value) {
          ioRequest!.headers.set(key, value);
        });
      }

      // Body writing
      if (body is FormData) {
        final boundary = body.boundary;
        ioRequest.headers.set(
          'content-type',
          'multipart/form-data; boundary=$boundary',
        );

        final separator = utf8.encode('--$boundary\r\n');
        const line = [13, 10];

        // 1. Write form fields
        for (final entry in body.fields) {
          ioRequest.add(separator);
          ioRequest.add(utf8.encode(
            'content-disposition: form-data; name="${Uri.encodeComponent(entry.key)}"\r\n\r\n',
          ));
          ioRequest.add(utf8.encode(entry.value));
          ioRequest.add(line);
        }

        // 2. Stream files directly into socket
        int totalBytes = 0;
        if (uploadProgress != null) {
          try {
            totalBytes = body.length;
          } catch (_) {
            totalBytes = 0;
          }
        }
        int sentBytes = 0;

        for (final entry in body.files) {
          final file = entry.value;
          ioRequest.add(separator);
          ioRequest.add(utf8.encode(
            'content-disposition: form-data; name="${Uri.encodeComponent(entry.key)}"; filename="${Uri.encodeComponent(file.filename)}"\r\n',
          ));
          ioRequest.add(utf8.encode(
            'content-type: ${file.contentType}\r\n\r\n',
          ));

          if (file.stream != null) {
            await for (final chunk in file.stream!) {
              ioRequest.add(chunk);
              if (uploadProgress != null && totalBytes > 0) {
                sentBytes += chunk.length;
                uploadProgress((sentBytes / totalBytes * 100).clamp(0.0, 100.0));
              }
            }
          }
          ioRequest.add(line);
        }

        // 3. Close boundary
        ioRequest.add(utf8.encode('--$boundary--\r\n'));
      } else if (body is Map || body is List) {
        final jsonBytes = utf8.encode(jsonEncode(body));
        ioRequest.headers.set(
          'content-type',
          contentType ?? 'application/json; charset=utf-8',
        );
        ioRequest.contentLength = jsonBytes.length;
        ioRequest.add(jsonBytes);
      } else if (body is String) {
        final strBytes = utf8.encode(body);
        ioRequest.headers.set(
          'content-type',
          contentType ?? 'text/plain; charset=utf-8',
        );
        ioRequest.contentLength = strBytes.length;
        ioRequest.add(strBytes);
      }

      // Close and receive response
      final ioResponse = await ioRequest.close().timeout(httpClient.timeout);

      final responseBytes = await ioResponse.fold<List<int>>(
        <int>[],
        (prev, elem) => prev..addAll(elem),
      );
      final bodyString = utf8.decode(responseBytes, allowMalformed: true);

      // Parse JSON body safely without stripping any response data
      dynamic parsedBody;
      try {
        parsedBody = jsonDecode(bodyString);
      } catch (_) {
        parsedBody = bodyString;
      }

      final respHeaders = <String, String>{};
      ioResponse.headers.forEach((key, values) {
        respHeaders[key] = values.join(', ');
      });

      final durationMs = DateTime.now().millisecondsSinceEpoch - startTime;
      AsyncApiLogger.instance.logResponse(
        logId: logId,
        statusCode: ioResponse.statusCode,
        statusMessage: ioResponse.reasonPhrase,
        headers: respHeaders,
        body: parsedBody,
        durationMs: durationMs,
      );

      T? decodedBody;
      if (decoder != null && parsedBody != null) {
        decodedBody = decoder(parsedBody);
      } else {
        decodedBody = parsedBody as T?;
      }

      return Response<T>(
        statusCode: ioResponse.statusCode,
        statusText: ioResponse.reasonPhrase,
        headers: respHeaders,
        body: decodedBody,
        bodyString: bodyString,
      );
    } on TimeoutException catch (e, stack) {
      ioRequest?.abort();
      final durationMs = DateTime.now().millisecondsSinceEpoch - startTime;
      AsyncApiLogger.instance.logError(
        logId: logId,
        error: 'Connection timed out: $e',
        stackTrace: stack,
        statusCode: HttpStatus.requestTimeout,
        statusMessage: 'Request Timeout',
        durationMs: durationMs,
      );
      return Response<T>(
        statusCode: HttpStatus.requestTimeout,
        statusText: 'Connection timed out. Please check your internet connection.',
      );
    } catch (e, stack) {
      ioRequest?.abort();
      final durationMs = DateTime.now().millisecondsSinceEpoch - startTime;
      AsyncApiLogger.instance.logError(
        logId: logId,
        error: e,
        stackTrace: stack,
        durationMs: durationMs,
      );
      return Response<T>(
        statusCode: null,
        statusText: e.toString(),
      );
    }
  }

  @override
  Future<Response<T>> request<T>(
    String url,
    String method, {
    dynamic body,
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) {
    return _executeRequest<T>(
      method.toUpperCase(),
      url,
      body: body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) {
    return _executeRequest<T>(
      'GET',
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) {
    return _executeRequest<T>(
      'POST',
      url,
      body: body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) {
    return _executeRequest<T>(
      'PUT',
      url,
      body: body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) {
    return _executeRequest<T>(
      'PATCH',
      url,
      body: body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) {
    return _executeRequest<T>(
      'DELETE',
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }
}
