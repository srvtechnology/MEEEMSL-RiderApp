/// ApiEndpoints holds all REST and WebSocket endpoint paths.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.meeem.com/rider/v1';
  static const String socketUrl = 'wss://socket.meeem.com/rider';

  // Auth
  static const String login = '/auth/login';
  static const String loginWithPassword = '/auth/login-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

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

  // Profile & Documents & Zones
  static const String riderProfile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String uploadDocument = '/profile/documents/upload';
  static const String getDocuments = '/profile/documents';
  static const String operatingZones = '/profile/operating-zones';
  static const String updateVehicle = '/profile/vehicle/update';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
}
