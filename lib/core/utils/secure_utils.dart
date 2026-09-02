import 'dart:convert';

class SecureUtils {
  SecureUtils._();

  /// Recursively scrubs sensitive credentials (passwords, tokens, OTPs, PINs) from debug logs
  static dynamic sanitizeLogPayload(dynamic payload) {
    if (payload == null) return null;

    if (payload is String) {
      if (payload.trim().isEmpty) return payload;
      try {
        final decoded = jsonDecode(payload);
        return jsonEncode(sanitizeLogPayload(decoded));
      } catch (_) {
        var sanitized = payload;
        final sensitivePatterns = [
          RegExp(r'(otp|password|token|secret|key|cvv|card)="?([a-zA-Z0-9_\-\.\@\!]+)"?', caseSensitive: false),
          RegExp(r'(otp|password|token|secret|key|cvv|card)\s*:\s*"([^"]+)"', caseSensitive: false),
        ];
        for (var pattern in sensitivePatterns) {
          sanitized = sanitized.replaceAllMapped(pattern, (match) {
            final key = match.group(1);
            return '$key="[REDACTED]"';
          });
        }
        return sanitized;
      }
    }

    if (payload is Map) {
      final sanitizedMap = <dynamic, dynamic>{};
      final sensitiveKeys = {
        'otp',
        'password',
        'currentpassword',
        'newpassword',
        'accesstoken',
        'refreshtoken',
        'devicetoken',
        'idtoken',
        'token',
        'secret',
        'key',
        'cvv',
        'cardnumber',
        'pin'
      };

      payload.forEach((k, v) {
        final keyStr = k.toString().toLowerCase();
        if (sensitiveKeys.contains(keyStr)) {
          sanitizedMap[k] = '[REDACTED]';
        } else {
          sanitizedMap[k] = sanitizeLogPayload(v);
        }
      });
      return sanitizedMap;
    }

    if (payload is List) {
      return payload.map((item) => sanitizeLogPayload(item)).toList();
    }

    return payload;
  }

  /// Formats raw API error responses into user-friendly messages
  static String formatApiErrorMessage(dynamic response, {String fallback = 'An unexpected error occurred'}) {
    if (response == null) return fallback;

    dynamic body;
    String? statusText;

    try {
      body = response.body is Map ? response.body : null;
      statusText = response.statusText;
    } catch (_) {
      if (response is Map) body = response;
    }

    if (body is Map) {
      if (body['error'] != null && body['error'].toString().isNotEmpty) {
        return body['error'].toString();
      }
      if (body['message'] != null && body['message'].toString().isNotEmpty) {
        return body['message'].toString();
      }
    }

    if (statusText != null && statusText.isNotEmpty) {
      return statusText;
    }

    return fallback;
  }
}
