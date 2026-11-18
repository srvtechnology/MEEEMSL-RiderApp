import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Parses HTTP 429 (Too Many Requests) responses and mobile client auth token
/// errors conforming to MOBILE_APP_SECURITY_INTEGRATION_GUIDE.md.
class RateLimitParser {
  RateLimitParser._();

  /// Safely extracts a [Map] from Dio response data, decoding JSON strings if needed.
  static Map<dynamic, dynamic>? decodeBodyMap(dynamic data) {
    if (data is Map) return data;
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded;
      } catch (_) {}
    }
    return null;
  }

  /// Returns true when the server rejected the request due to a missing or
  /// invalid `x-meeem-app-token` header (HTTP 401).
  static bool isMobileClientTokenError(DioException err) {
    if (err.response?.statusCode != 401) return false;
    final data = decodeBodyMap(err.response?.data);
    final rawMsg = data != null
        ? (data['error'] ?? data['message'] ?? '').toString()
        : (err.response?.data?.toString() ?? '');
    final errorMsg = rawMsg.toLowerCase();
    return errorMsg.contains('mobile client authentication token') ||
        errorMsg.contains(AppConstants.mobileAppTokenHeader);
  }

  /// Extracts a typed [RateLimitException] from a [DioException] (HTTP 429).
  /// Reuses any already-parsed instance attached by [ApiInterceptor].
  static RateLimitException fromDioException(
    DioException err, {
    String fallbackMessage = 'Too many requests. Please try again later.',
    int defaultCooldownSeconds = AppConstants.otpResendSeconds,
  }) {
    if (err.error is RateLimitException) {
      return err.error as RateLimitException;
    }
    final extraEx = err.requestOptions.extra['rateLimitException'];
    if (extraEx is RateLimitException) {
      return extraEx;
    }
    return fromResponse(
      err.response,
      fallbackMessage: fallbackMessage,
      defaultCooldownSeconds: defaultCooldownSeconds,
    );
  }

  /// Extracts a typed [RateLimitException] from a Dio [Response].
  static RateLimitException fromResponse(
    Response<dynamic>? response, {
    String fallbackMessage = 'Too many requests. Please try again later.',
    int defaultCooldownSeconds = AppConstants.otpResendSeconds,
  }) {
    final Map<dynamic, dynamic>? body = decodeBodyMap(response?.data);
    final retryAfterHeader = response?.headers.value('retry-after');
    return parse(
      body: body,
      retryAfterHeader: retryAfterHeader,
      fallbackMessage: fallbackMessage,
      defaultCooldownSeconds: defaultCooldownSeconds,
    );
  }

  /// Core parser accepting raw response payload map and optional `Retry-After` header.
  static RateLimitException parse({
    Map<dynamic, dynamic>? body,
    String? retryAfterHeader,
    String fallbackMessage = 'Too many requests. Please try again later.',
    int defaultCooldownSeconds = AppConstants.otpResendSeconds,
  }) {
    final rawMsg = body?['error'] ?? body?['message'];
    final message = (rawMsg != null && rawMsg.toString().trim().isNotEmpty)
        ? rawMsg.toString().trim()
        : fallbackMessage;
    final lowerMsg = message.toLowerCase();

    final explicitRetryAfter = _parsePositiveInt(body?['retryAfter']) ??
        _parsePositiveInt(body?['cooldownRemaining']) ??
        _parsePositiveInt(retryAfterHeader);

    // 1. Daily Phone OTP Cap (9 SMS / 24h) — must be checked before numeric regex
    // so "(9/day)" is never mistaken for 9 seconds.
    if (lowerMsg.contains('daily') ||
        lowerMsg.contains('9/day') ||
        lowerMsg.contains('try again tomorrow')) {
      return RateLimitException(
        message: message,
        cooldownSeconds: explicitRetryAfter ?? 0,
        retryAfter: explicitRetryAfter,
        type: RateLimitType.dailyOtpLimit,
      );
    }

    // 2. Brute-force OTP Verification Lockout (5 failed attempts -> 15 min block)
    if (lowerMsg.contains('failed attempts') ||
        lowerMsg.contains('locked') ||
        lowerMsg.contains('lockout')) {
      final parsedSeconds = explicitRetryAfter ??
          _extractDurationSeconds(lowerMsg) ??
          AppConstants.otpLockoutSeconds;
      return RateLimitException(
        message: message,
        cooldownSeconds: parsedSeconds,
        retryAfter: parsedSeconds,
        type: RateLimitType.otpLockout,
      );
    }

    // 3. Password Login Rate Limiting (Max 5 attempts / minute per IP)
    if (lowerMsg.contains('login attempts')) {
      final parsedSeconds = explicitRetryAfter ??
          _extractDurationSeconds(lowerMsg) ??
          AppConstants.otpResendSeconds;
      return RateLimitException(
        message: message,
        cooldownSeconds: parsedSeconds,
        retryAfter: parsedSeconds,
        type: RateLimitType.loginRateLimit,
      );
    }

    // 4. Phone OTP Cooldown (60s between consecutive OTP dispatches)
    if (lowerMsg.contains('requesting another otp') ||
        lowerMsg.contains('before requesting') ||
        lowerMsg.contains('cooldown') ||
        lowerMsg.contains('resend')) {
      final parsedSeconds = explicitRetryAfter ??
          _extractDurationSeconds(lowerMsg) ??
          AppConstants.otpResendSeconds;
      return RateLimitException(
        message: message,
        cooldownSeconds: parsedSeconds,
        retryAfter: parsedSeconds,
        type: RateLimitType.otpCooldown,
      );
    }

    // 5. IP Rate Limiting (Max 3 requests / minute per IP)
    if (lowerMsg.contains('from your ip') ||
        lowerMsg.contains('too many requests')) {
      final parsedSeconds = explicitRetryAfter ??
          _extractDurationSeconds(lowerMsg) ??
          defaultCooldownSeconds;
      return RateLimitException(
        message: message,
        cooldownSeconds: parsedSeconds,
        retryAfter: parsedSeconds,
        type: RateLimitType.ipRateLimit,
      );
    }

    // 6. Generic 429 fallback
    final parsedSeconds = explicitRetryAfter ??
        _extractDurationSeconds(lowerMsg) ??
        defaultCooldownSeconds;
    return RateLimitException(
      message: message,
      cooldownSeconds: parsedSeconds,
      retryAfter: explicitRetryAfter ?? parsedSeconds,
      type: RateLimitType.generic,
    );
  }

  static int? _parsePositiveInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is num) {
      final v = value.ceil();
      return v > 0 ? v : null;
    }
    final parsed = int.tryParse(value.toString().trim());
    return (parsed != null && parsed > 0) ? parsed : null;
  }

  static int? _extractDurationSeconds(String lowerMessage) {
    final minuteMatch = RegExp(r'(\d+)\s*minute').firstMatch(lowerMessage);
    if (minuteMatch != null) {
      final mins = int.tryParse(minuteMatch.group(1)!);
      if (mins != null && mins > 0) return mins * 60;
    }
    final secondMatch = RegExp(r'(\d+)\s*second').firstMatch(lowerMessage);
    if (secondMatch != null) {
      final secs = int.tryParse(secondMatch.group(1)!);
      if (secs != null && secs > 0) return secs;
    }
    return null;
  }
}
