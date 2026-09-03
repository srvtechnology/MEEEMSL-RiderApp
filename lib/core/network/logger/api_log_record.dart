import 'dart:convert';

/// Represents an API interaction record capturing request, response, latency, and errors.
class ApiLogRecord {
  final String id;
  final String url;
  final String method;
  final Map<String, dynamic>? requestHeaders;
  final dynamic requestBody;
  final DateTime requestTime;

  final int? statusCode;
  final String? statusMessage;
  final Map<String, dynamic>? responseHeaders;
  final dynamic responseBody;
  final DateTime? responseTime;
  final int? durationMs;

  final dynamic error;
  final StackTrace? stackTrace;
  final String? curlCommand;

  ApiLogRecord({
    required this.id,
    required this.url,
    required this.method,
    this.requestHeaders,
    this.requestBody,
    required this.requestTime,
    this.statusCode,
    this.statusMessage,
    this.responseHeaders,
    this.responseBody,
    this.responseTime,
    this.durationMs,
    this.error,
    this.stackTrace,
    this.curlCommand,
  });

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  bool get isError =>
      error != null || (statusCode != null && statusCode! >= 400);

  bool get isPending => responseTime == null && error == null;

  int get computedDurationMs {
    if (durationMs != null) return durationMs!;
    if (responseTime != null) {
      return responseTime!.difference(requestTime).inMilliseconds;
    }
    return 0;
  }

  String get formattedDuration => '${computedDurationMs}ms';

  String get path {
    try {
      final uri = Uri.parse(url);
      return uri.path.isNotEmpty ? uri.path : url;
    } catch (_) {
      return url;
    }
  }

  ApiLogRecord copyWith({
    String? id,
    String? url,
    String? method,
    Map<String, dynamic>? requestHeaders,
    dynamic requestBody,
    DateTime? requestTime,
    int? statusCode,
    String? statusMessage,
    Map<String, dynamic>? responseHeaders,
    dynamic responseBody,
    DateTime? responseTime,
    int? durationMs,
    dynamic error,
    StackTrace? stackTrace,
    String? curlCommand,
  }) {
    return ApiLogRecord(
      id: id ?? this.id,
      url: url ?? this.url,
      method: method ?? this.method,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      requestBody: requestBody ?? this.requestBody,
      requestTime: requestTime ?? this.requestTime,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      responseBody: responseBody ?? this.responseBody,
      responseTime: responseTime ?? this.responseTime,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      curlCommand: curlCommand ?? this.curlCommand,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'method': method,
      'requestHeaders': requestHeaders,
      'requestBody': requestBody,
      'requestTime': requestTime.toIso8601String(),
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'responseTime': responseTime?.toIso8601String(),
      'durationMs': computedDurationMs,
      'error': error?.toString(),
      'curlCommand': curlCommand,
    };
  }

  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.writeln('=== API LOG [$id] ===');
    buffer.writeln('[$method] $url');
    buffer.writeln('Time: ${requestTime.toIso8601String()}');
    if (statusCode != null) {
      buffer.writeln('Status: $statusCode ${statusMessage ?? ''}');
      buffer.writeln('Duration: $formattedDuration');
    }
    if (requestHeaders != null && requestHeaders!.isNotEmpty) {
      buffer.writeln('Request Headers: ${jsonEncode(requestHeaders)}');
    }
    if (requestBody != null) {
      buffer.writeln('Request Body: ${jsonEncode(requestBody)}');
    }
    if (curlCommand != null && curlCommand!.isNotEmpty) {
      buffer.writeln('cURL: $curlCommand');
    }
    if (responseHeaders != null && responseHeaders!.isNotEmpty) {
      buffer.writeln('Response Headers: ${jsonEncode(responseHeaders)}');
    }
    if (responseBody != null) {
      buffer.writeln('Response Body: ${jsonEncode(responseBody)}');
    }
    if (error != null) {
      buffer.writeln('Error: $error');
      if (stackTrace != null) {
        buffer.writeln('StackTrace: $stackTrace');
      }
    }
    buffer.writeln('======================');
    return buffer.toString();
  }
}
