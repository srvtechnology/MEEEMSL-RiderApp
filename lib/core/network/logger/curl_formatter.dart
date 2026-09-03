import 'dart:convert';

/// Utility to generate reproducible, clean cURL commands from HTTP requests.
class CurlFormatter {
  CurlFormatter._();

  /// Builds a cURL string representation of an HTTP request.
  static String buildCurl({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final List<String> parts = ['curl -X ${method.toUpperCase()} "$url"'];

    // Headers
    if (headers != null && headers.isNotEmpty) {
      headers.forEach((key, value) {
        if (value == null) return;
        final headerValue = value.toString().replaceAll('"', r'\"');
        parts.add('-H "$key: $headerValue"');
      });
    }

    // Body
    if (body != null) {
      if (body is Map || body is List) {
        try {
          final jsonStr = jsonEncode(body);
          // Escape single quotes for bash safe argument
          final escapedJson = jsonStr.replaceAll("'", r"'\''");
          parts.add("-d '$escapedJson'");
        } catch (_) {
          parts.add("-d '$body'");
        }
      } else if (body is String) {
        if (body.isNotEmpty) {
          final escapedBody = body.replaceAll("'", r"'\''");
          parts.add("-d '$escapedBody'");
        }
      } else {
        parts.add("-d '$body'");
      }
    }

    return parts.join(' \\\n  ');
  }
}
