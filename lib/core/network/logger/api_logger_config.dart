import 'package:flutter/foundation.dart';
import 'api_log_record.dart';

/// Callback signature for external log sinks (e.g. Firebase Crashlytics, Telemetry, In-app viewers)
typedef CustomLogHandler = void Function(ApiLogRecord record);

/// Configuration options for the asynchronous API logger system.
class ApiLoggerConfig {
  /// Whether the logging system is actively enabled.
  /// Defaults to true in debug mode, false in release mode unless overridden.
  final bool enabled;

  /// Whether to log outgoing requests.
  final bool logRequests;

  /// Whether to log incoming responses.
  final bool logResponses;

  /// Whether to log network errors/exceptions.
  final bool logErrors;

  /// Whether to include request and response headers in logs.
  final bool logHeaders;

  /// Whether to log the request payload/body.
  final bool logRequestBody;

  /// Whether to log the response payload/body.
  final bool logResponseBody;

  /// Whether to generate and print copy-pasteable cURL commands.
  final bool logCurl;

  /// Maximum character count for request/response bodies before truncation.
  /// Prevents memory exhaustion or console stutter on massive JSON payloads.
  final int maxBodyLength;

  /// Whether to print formatted logs to the developer console/terminal.
  final bool printToConsole;

  /// Whether to use ANSI terminal colors for status codes and methods.
  final bool colorizeConsole;

  /// Whether to maintain an in-memory ring buffer of recent API records.
  final bool enableHistory;

  /// Maximum number of records retained in the ring buffer.
  final int historyCapacity;

  /// Optional external handler to receive completed log records asynchronously.
  final CustomLogHandler? customLogHandler;

  const ApiLoggerConfig({
    this.enabled = kDebugMode,
    this.logRequests = true,
    this.logResponses = true,
    this.logErrors = true,
    this.logHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logCurl = true,
    this.maxBodyLength = 10000,
    this.printToConsole = true,
    this.colorizeConsole = true,
    this.enableHistory = true,
    this.historyCapacity = 100,
    this.customLogHandler,
  });

  /// Config with all logging disabled.
  const ApiLoggerConfig.disabled()
      : enabled = false,
        logRequests = false,
        logResponses = false,
        logErrors = false,
        logHeaders = false,
        logRequestBody = false,
        logResponseBody = false,
        logCurl = false,
        maxBodyLength = 0,
        printToConsole = false,
        colorizeConsole = false,
        enableHistory = false,
        historyCapacity = 0,
        customLogHandler = null;

  ApiLoggerConfig copyWith({
    bool? enabled,
    bool? logRequests,
    bool? logResponses,
    bool? logErrors,
    bool? logHeaders,
    bool? logRequestBody,
    bool? logResponseBody,
    bool? logCurl,
    int? maxBodyLength,
    bool? printToConsole,
    bool? colorizeConsole,
    bool? enableHistory,
    int? historyCapacity,
    CustomLogHandler? customLogHandler,
  }) {
    return ApiLoggerConfig(
      enabled: enabled ?? this.enabled,
      logRequests: logRequests ?? this.logRequests,
      logResponses: logResponses ?? this.logResponses,
      logErrors: logErrors ?? this.logErrors,
      logHeaders: logHeaders ?? this.logHeaders,
      logRequestBody: logRequestBody ?? this.logRequestBody,
      logResponseBody: logResponseBody ?? this.logResponseBody,
      logCurl: logCurl ?? this.logCurl,
      maxBodyLength: maxBodyLength ?? this.maxBodyLength,
      printToConsole: printToConsole ?? this.printToConsole,
      colorizeConsole: colorizeConsole ?? this.colorizeConsole,
      enableHistory: enableHistory ?? this.enableHistory,
      historyCapacity: historyCapacity ?? this.historyCapacity,
      customLogHandler: customLogHandler ?? this.customLogHandler,
    );
  }
}
