import 'dart:convert';
import 'dart:developer' as dev;
import 'api_log_record.dart';
import 'api_logger_config.dart';

/// Formats ApiLogRecord instances into clean, color-coded, box-delimited terminal entries.
class ConsoleLogFormatter {
  ConsoleLogFormatter._();

  // ANSI Escape Codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[90m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  static const String _divider =
      '────────────────────────────────────────────────────────────────────────────';

  /// Prints an outgoing request log.
  static void printRequest(ApiLogRecord record, ApiLoggerConfig config) {
    if (!config.printToConsole || !config.logRequests) return;

    final colorize = config.colorizeConsole;
    final methodColor = colorize ? _methodColor(record.method) : '';
    final reset = colorize ? _reset : '';
    final dim = colorize ? _dim : '';
    final bold = colorize ? _bold : '';

    final lines = <String>[];
    lines.add(
      '┌── 🚀 API REQUEST: $bold$methodColor[${record.method.toUpperCase()}]$reset ${record.url}',
    );

    // Headers
    if (config.logHeaders &&
        record.requestHeaders != null &&
        record.requestHeaders!.isNotEmpty) {
      lines.add('│ 📋 Headers:');
      final headerLines = _formatJsonOrMap(record.requestHeaders, config.maxBodyLength);
      for (final hl in headerLines) {
        lines.add('│   $hl');
      }
    }

    // Body
    if (config.logRequestBody && record.requestBody != null) {
      lines.add('│ 📦 Body:');
      final bodyLines = _formatBody(record.requestBody, config.maxBodyLength);
      for (final bl in bodyLines) {
        lines.add('│   $bl');
      }
    }

    // cURL
    if (config.logCurl &&
        record.curlCommand != null &&
        record.curlCommand!.isNotEmpty) {
      lines.add('│ 💻 cURL:');
      for (final cl in record.curlCommand!.split('\n')) {
        lines.add('│   $dim$cl$reset');
      }
    }

    lines.add('└──$_divider');

    _printLines(lines, 'API_REQUEST');
  }

  /// Prints an incoming response log.
  static void printResponse(ApiLogRecord record, ApiLoggerConfig config) {
    if (!config.printToConsole || !config.logResponses) return;

    final colorize = config.colorizeConsole;
    final statusColor = colorize ? _statusColor(record.statusCode) : '';
    final methodColor = colorize ? _methodColor(record.method) : '';
    final reset = colorize ? _reset : '';
    final bold = colorize ? _bold : '';
    final dim = colorize ? _dim : '';

    final statusText = record.statusCode != null
        ? '$bold$statusColor[${record.statusCode} ${record.statusMessage ?? ''}]$reset'
        : '[NO_STATUS]';

    final lines = <String>[];
    lines.add(
      '┌── ✅ API RESPONSE: $statusText $methodColor[${record.method.toUpperCase()}]$reset ${record.url} $dim(${record.formattedDuration})$reset',
    );

    // Headers
    if (config.logHeaders &&
        record.responseHeaders != null &&
        record.responseHeaders!.isNotEmpty) {
      lines.add('│ 📋 Headers:');
      final headerLines =
          _formatJsonOrMap(record.responseHeaders, config.maxBodyLength);
      for (final hl in headerLines) {
        lines.add('│   $hl');
      }
    }

    // Body
    if (config.logResponseBody && record.responseBody != null) {
      lines.add('│ 📦 Body:');
      final bodyLines = _formatBody(record.responseBody, config.maxBodyLength);
      for (final bl in bodyLines) {
        lines.add('│   $bl');
      }
    }

    lines.add('└──$_divider');

    _printLines(lines, 'API_RESPONSE');
  }

  /// Prints an error log.
  static void printError(ApiLogRecord record, ApiLoggerConfig config) {
    if (!config.printToConsole || !config.logErrors) return;

    final colorize = config.colorizeConsole;
    final red = colorize ? _red : '';
    final reset = colorize ? _reset : '';
    final bold = colorize ? _bold : '';
    final dim = colorize ? _dim : '';

    final statusInfo = record.statusCode != null
        ? ' [$red${record.statusCode}$reset]'
        : '';

    final lines = <String>[];
    lines.add(
      '┌── ❌ API ERROR:$statusInfo $bold$red[${record.method.toUpperCase()}]$reset ${record.url} $dim(${record.formattedDuration})$reset',
    );

    if (record.error != null) {
      lines.add('│ ⚠️ Error: $red${record.error}$reset');
    }

    // Response Body (Error Payload)
    if (config.logResponseBody && record.responseBody != null) {
      lines.add('│ 📦 Error Body:');
      final bodyLines = _formatBody(record.responseBody, config.maxBodyLength);
      for (final bl in bodyLines) {
        lines.add('│   $bl');
      }
    }

    lines.add('└──$_divider');

    _printLines(lines, 'API_ERROR');
  }

  static String _methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return _green;
      case 'POST':
        return _blue;
      case 'PUT':
      case 'PATCH':
        return _yellow;
      case 'DELETE':
        return _red;
      default:
        return _magenta;
    }
  }

  static String _statusColor(int? statusCode) {
    if (statusCode == null) return _red;
    if (statusCode >= 200 && statusCode < 300) return _green;
    if (statusCode >= 300 && statusCode < 400) return _cyan;
    if (statusCode >= 400 && statusCode < 500) return _yellow;
    return _red;
  }

  static List<String> _formatBody(dynamic body, int maxBodyLength) {
    if (body == null) return ['null'];

    String formatted;
    try {
      if (body is Map || body is List) {
        formatted = const JsonEncoder.withIndent('  ').convert(body);
      } else if (body is String) {
        try {
          final decoded = jsonDecode(body);
          formatted = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          formatted = body;
        }
      } else {
        formatted = body.toString();
      }
    } catch (_) {
      formatted = body.toString();
    }

    if (maxBodyLength > 0 && formatted.length > maxBodyLength) {
      final truncatedCount = formatted.length - maxBodyLength;
      formatted =
          '${formatted.substring(0, maxBodyLength)}\n... [TRUNCATED $truncatedCount characters]';
    }

    return formatted.split('\n');
  }

  static List<String> _formatJsonOrMap(Map<String, dynamic>? map, int maxLength) {
    if (map == null || map.isEmpty) return ['{}'];
    try {
      final str = const JsonEncoder.withIndent('  ').convert(map);
      if (maxLength > 0 && str.length > maxLength) {
        return ['${str.substring(0, maxLength)} ... [TRUNCATED]'];
      }
      return str.split('\n');
    } catch (_) {
      return [map.toString()];
    }
  }

  static void _printLines(List<String> lines, String name) {
    // Join lines to log atomically
    final message = lines.join('\n');
    dev.log(message, name: name);
  }
}
