/// AppConstants defines system-wide constants.
class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String tokenKey = 'rider_auth_token';
  static const String refreshTokenKey = 'rider_refresh_token';
  static const String riderProfileKey = 'rider_profile_data';
  static const String userProfileKey = 'rider_user_data';
  static const String registeredDeviceIdKey = 'device_hardware_uuid';
  static const String devicePushTokenKey = 'rider_fcm_device_token';
  static const String isOnlineKey = 'rider_is_online';
  static const String isDarkModeKey = 'app_dark_mode';
  static const String offlineQueueKey = 'offline_order_queue';
  static const String operatingZonesKey = 'rider_operating_zones';
  static const String payoutInfoKey = 'rider_payout_info';

  // Default Localization
  static const String defaultCountryCode = '+232';

  // Timers & Timeouts
  static const int incomingOrderTimeoutSeconds = 60;
  static const int otpResendSeconds = 60;
  static const int locationUpdateIntervalSeconds = 10;
  static const int connectionTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Mock Settings
  static const bool useMockApi = true; // Provides instantaneous full simulation
}
