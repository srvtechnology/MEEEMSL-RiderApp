import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static const String currencySymbol = 'Nle';

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: 'Nle ',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Safely formats currency amounts using integer-cent rounding to prevent
  /// floating-point artifacts (e.g. 449.996 -> "NLe 450", 450.5 -> "NLe 450.50").
  static String formatRevenueAmount(
    double value, {
    String currency = 'NLe',
    bool forceDecimals = false,
  }) {
    final safeVal = value.isNaN || value.isInfinite ? 0.0 : value;
    final roundedCents = (safeVal * 100).round();
    final isNegative = roundedCents < 0;
    final absCents = roundedCents.abs();
    final whole = absCents ~/ 100;
    final cents = absCents % 100;
    final wholeStr = NumberFormat('#,##0').format(whole);
    final sign = isNegative ? '-' : '';
    if (!forceDecimals && cents == 0) {
      return '$sign$currency $wholeStr';
    }
    return '$sign$currency $wholeStr.${cents.toString().padLeft(2, '0')}';
  }

  static String formatShortDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${formatShortDate(local)}, ${formatTime(local)}';
  }

  static String formatFullDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${DateFormat('MMM d, yyyy').format(local)} • ${formatTime(local)}';
  }

  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).toInt()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) return '$hours hrs';
    return '${hours}h ${remainingMins}m';
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d, yyyy').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d').format(dateTime);
  }

  /// Strips alphabetic characters and symbols from a local phone number, keeping digits only.
  /// Conforms to MOBILE_APP_SECURITY_INTEGRATION_GUIDE Section 4.
  static String sanitizeLocalPhone(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  /// Strips alphabetic characters and symbols from a phone number while preserving
  /// a single leading '+' if present (e.g. "+232 79-494-127" -> "+23279494127").
  static String sanitizePhoneNumber(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    final hasLeadingPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return hasLeadingPlus ? '+$digits' : digits;
  }

  /// Formats a phone number into clean E.164 format (e.g. "+23279494127").
  /// Preserves existing E.164 prefix if already present; otherwise strips leading
  /// trunk zeros (e.g. "079494127" -> "79494127") and prepends sanitized [countryCode].
  static String toE164Phone(String phone, {String countryCode = '+232'}) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('+')) {
      return sanitizePhoneNumber(trimmed);
    }
    final localDigits = sanitizeLocalPhone(trimmed).replaceFirst(RegExp(r'^0+'), '');
    if (localDigits.isEmpty) return '';
    final ccDigits = sanitizeLocalPhone(countryCode);
    if (ccDigits.isEmpty) return localDigits;
    return '+$ccDigits$localDigits';
  }
}
