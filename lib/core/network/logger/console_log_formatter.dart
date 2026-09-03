import 'dart:convert';
import 'dart:developer' as dev;
import 'api_log_record.dart';
import 'api_logger_config.dart';

/// Formats ApiLogRecord instances into clean, color-coded terminal entries.
/// Supports both a concise, compact view (default) and a verbose box view.
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

    if (config.compactView) {
      _printCompactRequest(record, config);
    } else {
      _printVerboseRequest(record, config);
    }
  }

  /// Prints an incoming response log.
  static void printResponse(ApiLogRecord record, ApiLoggerConfig config) {
    if (!config.printToConsole || !config.logResponses) return;

    if (config.compactView) {
      _printCompactResponse(record, config);
    } else {
      _printVerboseResponse(record, config);
    }
  }

  /// Prints an error log.
  static void printError(ApiLogRecord record, ApiLoggerConfig config) {
    if (!config.printToConsole || !config.logErrors) return;

    if (config.compactView) {
      _printCompactError(record, config);
    } else {
      _printVerboseError(record, config);
    }
  }

  // ==========================================
  // COMPACT FORMATTER (1-2 lines per event)
  // ==========================================

  static void _printCompactRequest(ApiLogRecord record, ApiLoggerConfig config) {
    final colorize = config.colorizeConsole;
    final methodColor = colorize ? _methodColor(record.method) : '';
    final reset = colorize ? _reset : '';
    final bold = colorize ? _bold : '';

    final lines = <String>[];
    lines.add(
      '🚀 $bold$methodColor[${record.method.toUpperCase()}]$reset ${record.url}',
    );

    // Compact single-line body preview
    if (config.logRequestBody && record.requestBody != null) {
      final compactBody = _formatCompactPayload(
        record.requestBody,
        maxLength: config.compactBodyMaxLength,
      );
      if (compactBody != null && compactBody.isNotEmpty) {
        lines.add('   📦 Body: $compactBody');
      }
    }

    _printLines(lines, 'API');
  }

  static void _printCompactResponse(
    ApiLogRecord record,
    ApiLoggerConfig config,
  ) {
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
      '✅ $statusText $dim(${record.formattedDuration})$reset $bold$methodColor[${record.method.toUpperCase()}]$reset ${record.url}',
    );

    // Full response body without hiding or truncating any data
    if (config.logResponseBody && record.responseBody != null) {
      final compactBody = _formatCompactPayload(
        record.responseBody,
        maxLength:
            config.truncateResponseBody ? config.compactBodyMaxLength : 0,
      );
      if (compactBody != null && compactBody.isNotEmpty) {
        lines.add('   📦 Body: $compactBody');
      }
    }

    _printLines(lines, 'API');
  }

  static void _printCompactError(ApiLogRecord record, ApiLoggerConfig config) {
    final colorize = config.colorizeConsole;
    final red = colorize ? _red : '';
    final reset = colorize ? _reset : '';
    final bold = colorize ? _bold : '';
    final dim = colorize ? _dim : '';
    final methodColor = colorize ? _methodColor(record.method) : '';

    final statusText = record.statusCode != null
        ? '$bold$red[${record.statusCode} ${record.statusMessage ?? ''}]$reset'
        : '$bold$red[ERROR]$reset';

    final lines = <String>[];
    lines.add(
      '❌ $statusText $dim(${record.formattedDuration})$reset $bold$methodColor[${record.method.toUpperCase()}]$reset ${record.url}',
    );

    if (record.error != null) {
      lines.add('   ⚠️ Error: $red${record.error}$reset');
    }

    if (config.logResponseBody && record.responseBody != null) {
      final compactBody = _formatCompactPayload(
        record.responseBody,
        maxLength:
            config.truncateResponseBody ? config.compactBodyMaxLength : 0,
      );
      if (compactBody != null && compactBody.isNotEmpty) {
        lines.add('   📦 Error Body: $compactBody');
      }
    }

    _printLines(lines, 'API');
  }

  // ==========================================
  // VERBOSE BOX FORMATTER (multi-line cards)
  // ==========================================

  static void _printVerboseRequest(ApiLogRecord record, ApiLoggerConfig config) {
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
      final headerLines =
          _formatJsonOrMap(record.requestHeaders, config.maxBodyLength);
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

  static void _printVerboseResponse(
    ApiLogRecord record,
    ApiLoggerConfig config,
  ) {
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
      final bodyLines = _formatBody(
        record.responseBody,
        config.truncateResponseBody ? config.maxBodyLength : 0,
      );
      for (final bl in bodyLines) {
        lines.add('│   $bl');
      }
    }

    lines.add('└──$_divider');

    _printLines(lines, 'API_RESPONSE');
  }

  static void _printVerboseError(ApiLogRecord record, ApiLoggerConfig config) {
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
      final bodyLines = _formatBody(
        record.responseBody,
        config.truncateResponseBody ? config.maxBodyLength : 0,
      );
      for (final bl in bodyLines) {
        lines.add('│   $bl');
      }
    }

    lines.add('└──$_divider');

    _printLines(lines, 'API_ERROR');
  }

  // ==========================================
  // HELPERS
  // ==========================================

  static String? _formatCompactPayload(dynamic body, {int maxLength = 250}) {
    if (body == null) return null;

    String text;
    try {
      if (body is Map || body is List) {
        text = jsonEncode(body);
      } else if (body is String) {
        try {
          final decoded = jsonDecode(body);
          text = jsonEncode(decoded);
        } catch (_) {
          text = body.replaceAll('\n', ' ').trim();
        }
      } else {
        text = body.toString();
      }
    } catch (_) {
      text = body.toString();
    }

    if (text.isEmpty) return null;

    if (maxLength > 0 && text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    }
    return text;
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
    final message = lines.join('\n');
    dev.log(message, name: name);
  }
}
