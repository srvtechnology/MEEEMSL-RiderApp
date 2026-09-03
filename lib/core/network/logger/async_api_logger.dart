import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../utils/secure_utils.dart';
import 'api_log_record.dart';
import 'api_logger_config.dart';
import 'console_log_formatter.dart';
import 'curl_formatter.dart';

/// Types of asynchronous log events processed in the background worker queue.
enum _LogEventType { request, response, error }

class _LogEvent {
  final _LogEventType type;
  final String id;
  final String? method;
  final String? url;
  final Map<String, dynamic>? headers;
  final dynamic body;
  final DateTime timestamp;
  final int? statusCode;
  final String? statusMessage;
  final dynamic error;
  final StackTrace? stackTrace;
  final int? durationMs;

  _LogEvent({
    required this.type,
    required this.id,
    this.method,
    this.url,
    this.headers,
    this.body,
    required this.timestamp,
    this.statusCode,
    this.statusMessage,
    this.error,
    this.stackTrace,
    this.durationMs,
  });
}

/// Central Asynchronous API Logger.
///
/// Features:
/// - Asynchronous, non-blocking event queue: Interceptors return in O(1) time
///   while sanitization, formatting, cURL generation, and I/O run in background microtasks.
/// - Credential sanitization (passwords, tokens, OTPs, PINs, card numbers).
/// - Thread-safe FIFO ring buffer for in-memory history.
/// - Reactive Stream API (`onLogRecord`) for UI diagnostics.
/// - Diagnostic export to JSON and formatted text.
class AsyncApiLogger {
  static AsyncApiLogger? _instance;
  static AsyncApiLogger get instance => _instance ??= AsyncApiLogger();

  ApiLoggerConfig _config;
  ApiLoggerConfig get config => _config;

  final StreamController<_LogEvent> _eventQueue =
      StreamController<_LogEvent>();
  final StreamController<ApiLogRecord> _recordBroadcast =
      StreamController<ApiLogRecord>.broadcast();

  StreamSubscription<_LogEvent>? _workerSubscription;

  /// Active in-flight requests keyed by ID
  final Map<String, ApiLogRecord> _activeRecords = {};

  /// Bounded in-memory ring buffer of historical records
  final ListQueue<ApiLogRecord> _history = ListQueue<ApiLogRecord>();

  static const Uuid _uuid = Uuid();

  AsyncApiLogger({ApiLoggerConfig? config})
      : _config = config ?? const ApiLoggerConfig() {
    _startWorker();
  }

  /// Update the logger configuration dynamically.
  void updateConfig(ApiLoggerConfig newConfig) {
    _config = newConfig;
  }

  /// Public stream emitting completed or updated log records.
  Stream<ApiLogRecord> get onLogRecord => _recordBroadcast.stream;

  void _startWorker() {
    _workerSubscription = _eventQueue.stream.listen(
      _processEvent,
      onError: (err, stack) {
        // Prevent worker failure
      },
    );
  }

  /// Enqueues a request start event asynchronously.
  /// Returns a tracking ID immediately in O(1) time.
  String logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    String? explicitId,
  }) {
    final logId = explicitId ?? _uuid.v4();

    if (!_config.enabled) {
      return logId;
    }

    _eventQueue.add(
      _LogEvent(
        type: _LogEventType.request,
        id: logId,
        method: method,
        url: url,
        headers: headers != null ? Map<String, dynamic>.from(headers) : null,
        body: body,
        timestamp: DateTime.now(),
      ),
    );

    return logId;
  }

  /// Enqueues a response completion event asynchronously.
  void logResponse({
    required String logId,
    required int statusCode,
    String? statusMessage,
    Map<String, dynamic>? headers,
    dynamic body,
    int? durationMs,
  }) {
    if (!_config.enabled) return;

    _eventQueue.add(
      _LogEvent(
        type: _LogEventType.response,
        id: logId,
        statusCode: statusCode,
        statusMessage: statusMessage,
        headers: headers != null ? Map<String, dynamic>.from(headers) : null,
        body: body,
        timestamp: DateTime.now(),
        durationMs: durationMs,
      ),
    );
  }

  /// Enqueues an error completion event asynchronously.
  void logError({
    required String logId,
    required dynamic error,
    StackTrace? stackTrace,
    int? statusCode,
    String? statusMessage,
    Map<String, dynamic>? headers,
    dynamic responseBody,
    int? durationMs,
  }) {
    if (!_config.enabled) return;

    _eventQueue.add(
      _LogEvent(
        type: _LogEventType.error,
        id: logId,
        statusCode: statusCode,
        statusMessage: statusMessage,
        headers: headers != null ? Map<String, dynamic>.from(headers) : null,
        body: responseBody,
        error: error,
        stackTrace: stackTrace,
        timestamp: DateTime.now(),
        durationMs: durationMs,
      ),
    );
  }

  /// Background event processing worker loop
  Future<void> _processEvent(_LogEvent event) async {
    try {
      switch (event.type) {
        case _LogEventType.request:
          _handleRequestEvent(event);
          break;
        case _LogEventType.response:
          _handleResponseEvent(event);
          break;
        case _LogEventType.error:
          _handleErrorEvent(event);
          break;
      }
    } catch (_) {
      // Background worker catches any formatting or sanitization error silently
    }
  }

  dynamic _sanitizePayload(dynamic payload) {
    final res = SecureUtils.sanitizeLogPayload(payload);
    if (res is Map) {
      try {
        return Map<String, dynamic>.from(res);
      } catch (_) {
        return res;
      }
    }
    return res;
  }

  void _handleRequestEvent(_LogEvent event) {
    // 1. Sanitize headers and body asynchronously in background worker
    final sanitizedHeaders = _sanitizeHeaders(event.headers);
    final sanitizedBody = _sanitizePayload(event.body);

    // 2. Build cURL command
    String? curlCommand;
    if (_config.logCurl && event.method != null && event.url != null) {
      curlCommand = CurlFormatter.buildCurl(
        method: event.method!,
        url: event.url!,
        headers: sanitizedHeaders,
        body: sanitizedBody,
      );
    }

    // 3. Create active record
    final record = ApiLogRecord(
      id: event.id,
      url: event.url ?? '',
      method: event.method ?? 'GET',
      requestHeaders: sanitizedHeaders,
      requestBody: sanitizedBody,
      requestTime: event.timestamp,
      curlCommand: curlCommand,
    );

    _activeRecords[event.id] = record;

    // 4. Console log output
    ConsoleLogFormatter.printRequest(record, _config);

    // 5. Emit on broadcast stream
    _recordBroadcast.add(record);
  }

  dynamic _ensureTypedPayload(dynamic payload) {
    if (payload is Map) {
      try {
        return Map<String, dynamic>.from(payload);
      } catch (_) {
        return payload;
      }
    }
    return payload;
  }

  void _handleResponseEvent(_LogEvent event) {
    final existing = _activeRecords.remove(event.id);
    final sanitizedHeaders = _sanitizeHeaders(event.headers);
    final responseBody = _config.sanitizeResponseBody
        ? _sanitizePayload(event.body)
        : _ensureTypedPayload(event.body);

    final duration = event.durationMs ??
        (existing != null
            ? event.timestamp.difference(existing.requestTime).inMilliseconds
            : 0);

    final record = (existing ??
            ApiLogRecord(
              id: event.id,
              url: '',
              method: 'UNKNOWN',
              requestTime: event.timestamp,
            ))
        .copyWith(
      statusCode: event.statusCode,
      statusMessage: event.statusMessage,
      responseHeaders: sanitizedHeaders,
      responseBody: responseBody,
      responseTime: event.timestamp,
      durationMs: duration,
    );

    // 1. Save to in-memory history ring buffer
    _addToHistory(record);

    // 2. Console log output
    ConsoleLogFormatter.printResponse(record, _config);

    // 3. Custom external handler callback (Crashlytics, custom listeners)
    _config.customLogHandler?.call(record);

    // 4. Emit on broadcast stream
    _recordBroadcast.add(record);
  }

  void _handleErrorEvent(_LogEvent event) {
    final existing = _activeRecords.remove(event.id);
    final sanitizedHeaders = _sanitizeHeaders(event.headers);
    final responseBody = _config.sanitizeResponseBody
        ? _sanitizePayload(event.body)
        : _ensureTypedPayload(event.body);

    final duration = event.durationMs ??
        (existing != null
            ? event.timestamp.difference(existing.requestTime).inMilliseconds
            : 0);

    final record = (existing ??
            ApiLogRecord(
              id: event.id,
              url: '',
              method: 'UNKNOWN',
              requestTime: event.timestamp,
            ))
        .copyWith(
      statusCode: event.statusCode,
      statusMessage: event.statusMessage,
      responseHeaders: sanitizedHeaders,
      responseBody: responseBody,
      responseTime: event.timestamp,
      durationMs: duration,
      error: event.error,
      stackTrace: event.stackTrace,
    );

    // 1. Save to in-memory history ring buffer
    _addToHistory(record);

    // 2. Console log output
    ConsoleLogFormatter.printError(record, _config);

    // 3. Custom external handler callback
    _config.customLogHandler?.call(record);

    // 4. Emit on broadcast stream
    _recordBroadcast.add(record);
  }

  void _addToHistory(ApiLogRecord record) {
    if (!_config.enableHistory || _config.historyCapacity <= 0) return;

    if (_history.length >= _config.historyCapacity) {
      _history.removeFirst();
    }
    _history.addLast(record);
  }

  Map<String, dynamic>? _sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return headers;
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      final keyLower = key.toLowerCase();
      if (keyLower == 'authorization') {
        final valStr = value.toString();
        if (valStr.toLowerCase().startsWith('bearer ')) {
          sanitized[key] = 'Bearer [REDACTED]';
        } else {
          sanitized[key] = '[REDACTED]';
        }
      } else if (keyLower.contains('token') ||
          keyLower.contains('secret') ||
          keyLower.contains('api-key') ||
          keyLower.contains('cookie')) {
        sanitized[key] = '[REDACTED]';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Returns a snapshot of in-memory logged records.
  List<ApiLogRecord> getHistory() {
    return List<ApiLogRecord>.unmodifiable(_history);
  }

  /// Clears in-memory history and in-flight active records.
  void clearHistory() {
    _history.clear();
    _activeRecords.clear();
  }

  /// Exports stored API logs as a formatted human-readable diagnostic report.
  String exportLogsAsText() {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('      MEEEM RIDER - API DIAGNOSTIC LOGS  ');
    buffer.writeln('Exported At: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Log Records: ${_history.length}');
    buffer.writeln('========================================\n');

    for (final record in _history) {
      buffer.writeln(record.toFormattedString());
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports stored API logs as a JSON string array.
  String exportLogsAsJson() {
    final list = _history.map((r) => r.toJson()).toList();
    return jsonEncode(list);
  }

  /// Disposes of background streams and resources.
  Future<void> dispose() async {
    await _workerSubscription?.cancel();
    await _eventQueue.close();
    await _recordBroadcast.close();
    _history.clear();
    _activeRecords.clear();
  }
}
