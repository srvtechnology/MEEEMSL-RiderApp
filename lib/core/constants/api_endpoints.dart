import '../network/api_client.dart';

/// ApiEndpoints holds all REST and WebSocket endpoint paths
/// conforming to MEEEM Delivery Network — Rider Mobile App API Doc (Part 1).
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => ApiClient.riderApiBaseUrl;
  static String get socketUrl => ApiClient.currentEnvironment == AppEnvironment.staging
      ? 'wss://development.meeemsl.com/rider'
      : 'wss://www.meeemsl.com/rider';

  /// WebSocket server URL for real-time GPS telemetry streaming (Section 1.1)
  static String get telemetrySocketUrl => ApiClient.currentEnvironment == AppEnvironment.staging
      ? 'https://development.meeemsl.com:3001'
      : 'https://www.meeemsl.com:3001';

  // 1.2 Fallback Background Telemetry (REST API)
  static const String location = '/location';

  // 2. Rider Registration & OTP Verification
  static const String register = '/auth/register';
  static const String verifyRegistrationOtp = '/auth/verify-otp';
  static const String resendRegistrationOtp = '/auth/resend-otp';

  // 3. Rider Login & Session Lifecycle
  static const String login = '/auth/login';
  static const String phoneOtpSend = '/auth/phone-otp/send-otp';
  static const String phoneOtpVerify = '/auth/phone-otp/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout'; // Note: Logout in Part 1 is DELETE /device-token

  /// Whitelist of endpoints strictly specified in MOBILE_RIDER_APP_API_DOC (Part 1 & Part 2)
  static const Set<String> part1Endpoints = {
    // Part 2: 1.2 Telemetry Fallback
    location,
    // 2. Rider Registration & OTP Verification
    register,
    verifyRegistrationOtp,
    resendRegistrationOtp,
    // 3. Rider Login & Session Lifecycle
    login,
    phoneOtpSend,
    phoneOtpVerify,
    refreshToken,
    // 4. Forgot & Reset Password Flow
    forgotPasswordSendOtp,
    forgotPasswordReset,
    // 5. First-Time Onboarding Flow
    onboarding,
    // 6. Rider Profile Management
    riderProfile,
    // 7. Rider Settings & Preferences
    settings,
    // 8. Delivery Zones & Hierarchical Locations
    zones,
    // 9. Multi-Device Push Token Management
    deviceToken,
  };

  /// Returns true ONLY if the given [path] is documented in MOBILE_RIDER_APP_API_DOC.
  static bool isPart1Endpoint(String path) {
    var cleanPath = path;
    if (cleanPath.contains('?')) {
      cleanPath = cleanPath.split('?').first;
    }
    final uri = Uri.tryParse(cleanPath);
    if (uri != null && uri.hasScheme) {
      cleanPath = uri.path;
    }
    if (cleanPath.length > 1 && cleanPath.endsWith('/')) {
      cleanPath = cleanPath.substring(0, cleanPath.length - 1);
    }
    const prefix = '/mobileapi/rider';
    if (cleanPath.startsWith(prefix)) {
      cleanPath = cleanPath.substring(prefix.length);
    }
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    return part1Endpoints.contains(cleanPath);
  }

  // 4. Forgot & Reset Password
  static const String forgotPasswordSendOtp = '/auth/forgot-password/send-otp';
  static const String forgotPasswordReset = '/auth/forgot-password/reset';

  // Compatibility aliases
  static const String loginWithPassword = login;
  static const String verifyOtp = verifyRegistrationOtp;
  static const String forgotPassword = forgotPasswordSendOtp;
  static const String resetPassword = forgotPasswordReset;

  // 5. First-Time Onboarding Flow
  static const String onboarding = '/onboarding';

  // 6. Rider Profile Management
  static const String riderProfile = '/profile';
  static const String updateProfile = '/profile'; // PATCH

  // 7. Rider Settings & Preferences
  static const String settings = '/settings'; // GET and POST

  // 8. Delivery Zones & Hierarchical Locations
  static const String zones = '/zones';

  // 9. Multi-Device Push Token Management
  static const String deviceToken = '/device-token'; // POST and DELETE

  // Legacy/Additional Profile & Documents endpoints
  static const String uploadDocument = '/profile/documents/upload';
  static const String getDocuments = '/profile/documents';
  static const String operatingZones = '/profile/operating-zones';
  static const String updateVehicle = '/profile/vehicle/update';

  // Dashboard & Status
  static const String dashboardSummary = '/dashboard/summary';
  static const String toggleOnline = '/rider/status/toggle';
  static const String updateLocation = '/rider/location/update';

  // Orders
  static const String activeOrders = '/orders/active';
  static const String incomingOrder = '/orders/incoming';
  static const String acceptOrder = '/orders/accept';
  static const String declineOrder = '/orders/decline';
  static const String updateOrderStatus = '/orders/status/update';
  static const String orderHistory = '/orders/history';
  static const String orderDetails = '/orders/details';
  static const String uploadProof = '/orders/delivery-proof';

  // Earnings
  static const String earningsBreakdown = '/earnings/breakdown';
  static const String requestPayout = '/earnings/payout/request';
  static const String payoutHistory = '/earnings/payout/history';
  static const String payoutInfo = '/earnings/payout/info';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
}
