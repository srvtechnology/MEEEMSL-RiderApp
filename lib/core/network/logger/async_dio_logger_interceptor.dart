import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'async_api_logger.dart';

/// High-performance non-blocking Dio interceptor that forwards network telemetry
/// to the [AsyncApiLogger] event queue asynchronously.
class AsyncDioLoggerInterceptor extends Interceptor {
  final AsyncApiLogger _logger;
  static const String _logIdKey = '_api_log_id';
  static const String _startTimeKey = '_api_log_start_time';
  static const Uuid _uuid = Uuid();

  AsyncDioLoggerInterceptor([AsyncApiLogger? logger])
      : _logger = logger ?? AsyncApiLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final logId = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    options.extra[_logIdKey] = logId;
    options.extra[_startTimeKey] = now;

    // Dispatch logging event asynchronously to decouple from Dio execution
    _logger.logRequest(
      explicitId: logId,
      method: options.method,
      url: options.uri.toString(),
      headers: Map<String, dynamic>.from(options.headers),
      body: _extractRequestBody(options.data),
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final logId = response.requestOptions.extra[_logIdKey] as String?;
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;

    if (logId != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final durationMs = startTime != null ? now - startTime : null;

      final headersMap = <String, dynamic>{};
      response.headers.forEach((k, v) => headersMap[k] = v.join(', '));

      _logger.logResponse(
        logId: logId,
        statusCode: response.statusCode ?? 200,
        statusMessage: response.statusMessage,
        headers: headersMap,
        body: response.data,
        durationMs: durationMs,
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final logId = err.requestOptions.extra[_logIdKey] as String?;
    final startTime = err.requestOptions.extra[_startTimeKey] as int?;

    if (logId != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final durationMs = startTime != null ? now - startTime : null;

      final headersMap = <String, dynamic>{};
      err.response?.headers.forEach((k, v) => headersMap[k] = v.join(', '));

      _logger.logError(
        logId: logId,
        error: err.error ?? err.message,
        stackTrace: err.stackTrace,
        statusCode: err.response?.statusCode,
        statusMessage: err.response?.statusMessage,
        headers: headersMap.isNotEmpty ? headersMap : null,
        responseBody: err.response?.data,
        durationMs: durationMs,
      );
    }

    handler.next(err);
  }

  dynamic _extractRequestBody(dynamic data) {
    if (data == null) return null;
    if (data is FormData) {
      final map = <String, dynamic>{};
      for (final field in data.fields) {
        map[field.key] = field.value;
      }
      for (final file in data.files) {
        map[file.key] =
            'MultipartFile(filename: ${file.value.filename}, length: ${file.value.length})';
      }
      return map;
    }
    return data;
  }
}
