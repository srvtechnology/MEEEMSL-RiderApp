import os

files = {}

# 1. lib/core/theme/app_colors.dart
files['lib/core/theme/app_colors.dart'] = '''import 'package:flutter/material.dart';

/// AppColors defines the complete design system color palette
/// derived from the primary brand color #0834C2 (Electric Sapphire).
class AppColors {
  AppColors._();

  // Primary Brand Palette (#0834C2)
  static const Color primary = Color(0xFF0834C2);
  static const Color primaryLight = Color(0xFF3B64E6);
  static const Color primaryDark = Color(0xFF052382);
  static const Color primaryContainer = Color(0xFFE8EEFF);
  static const Color onPrimaryContainer = Color(0xFF00164D);

  // Material 3 Swatch for #0834C2
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0834C2,
    <int, Color>{
      50: Color(0xFFEFF3FF),
      100: Color(0xFFDBE4FE),
      200: Color(0xFFBFD0FE),
      300: Color(0xFF93B2FD),
      400: Color(0xFF608DFC),
      500: Color(0xFF0834C2), // Base
      600: Color(0xFF2448F5),
      700: Color(0xFF1B36DE),
      800: Color(0xFF162BB4),
      900: Color(0xFF18298E),
    },
  );

  // Secondary Accent Palette (#FF6B00 - Warm Amber/Orange for CTAs & Actions)
  static const Color secondary = Color(0xFFFF6B00);
  static const Color secondaryLight = Color(0xFFFF8B3D);
  static const Color secondaryDark = Color(0xFFCC5500);
  static const Color secondaryContainer = Color(0xFFFFECE0);
  static const Color onSecondaryContainer = Color(0xFF4D2000);

  // Semantic Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F8EE);
  static const Color successDark = Color(0xFF009624);

  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFC67C00);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF0369A1);

  // Light Theme Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);

  // Neutral Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Neutral Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // UI Component Specifics
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color offlineGray = Color(0xFF94A3B8);
  static const Color mapPolyline = Color(0xFF0834C2);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0834C2), Color(0xFF2448F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8B3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onlineGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFF0834C2), Color(0xFF1B36DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
'''

# 2. lib/core/theme/text_styles.dart
files['lib/core/theme/text_styles.dart'] = '''import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextStyles provides consistent typographic hierarchy
/// based on Inter and Poppins fonts.
class AppTextStyles {
  AppTextStyles._();

  // Display Styles (for big splash, big numbers)
  static TextStyle displayLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  // Headline Styles (for screen headers, major cards)
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  // Title Styles (section headers, list item titles)
  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryLight,
      );

  // Body Styles (regular text, descriptions)
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondaryLight,
        height: 1.4,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondaryLight,
        height: 1.3,
      );

  // Label Styles (buttons, tabs, chips, badges)
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: 0.2,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: 0.2,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textSecondaryLight,
        letterSpacing: 0.3,
      );

  // Domain Specific Typography
  static TextStyle earningsAmount({Color? color, double fontSize = 28}) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle orderTimer({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.secondary,
      );

  static TextStyle navigationEta({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
      );
}
'''

# 3. lib/core/theme/app_theme.dart
files['lib/core/theme/app_theme.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTheme provides complete Material 3 Light & Dark themes
/// tuned to the #0834C2 primary design system.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiaryLight,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: GoogleFonts.inter().fontFamily,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      ),

      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiaryDark,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
'''

# 4. lib/core/constants/api_endpoints.dart
files['lib/core/constants/api_endpoints.dart'] = '''/// ApiEndpoints holds all REST and WebSocket endpoint paths.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.meeem.com/rider/v1';
  static const String socketUrl = 'wss://socket.meeem.com/rider';

  // Auth
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
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

  // Profile & Documents
  static const String riderProfile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String uploadDocument = '/profile/documents/upload';
  static const String getDocuments = '/profile/documents';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
}
'''

# 5. lib/core/constants/app_strings.dart
files['lib/core/constants/app_strings.dart'] = '''/// AppStrings centralizes all user-facing strings across the app.
class AppStrings {
  AppStrings._();

  // Common
  static const String appName = 'Meeem Rider';
  static const String appTagline = 'Fast, Reliable Partner on the Move';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String back = 'Back';
  static const String save = 'Save';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';

  // Auth
  static const String welcomeBack = 'Welcome Back, Partner';
  static const String loginSubtitle = 'Enter your mobile number to sign in or register';
  static const String phoneNumber = 'Phone Number';
  static const String sendOtp = 'Send Verification Code';
  static const String verifyOtp = 'Verify OTP';
  static const String otpSubtitle = 'Enter the 6-digit code sent to';
  static const String resendOtp = 'Resend Code';
  static const String resendIn = 'Resend in';
  static const String registerTitle = 'Rider Registration';
  static const String registerSubtitle = 'Complete your profile to start delivering';
  static const String fullName = 'Full Name';
  static const String email = 'Email Address';
  static const String vehicleType = 'Vehicle Type';
  static const String vehiclePlate = 'License Plate Number';
  static const String vehicleModel = 'Vehicle Make & Model';
  static const String documentsUpload = 'Upload Documents';

  // Dashboard
  static const String youAreOnline = "You're Online";
  static const String youAreOffline = "You're Offline";
  static const String goOnlineToEarn = 'Go online to start receiving delivery orders';
  static const String onlineFindingOrders = 'Searching for nearby delivery requests...';
  static const String todaysEarnings = "Today's Earnings";
  static const String completedOrders = 'Completed';
  static const String acceptanceRate = 'Acceptance';
  static const String rating = 'Rating';
  static const String onlineHours = 'Online Hours';

  // Incoming Order Alert
  static const String newOrderRequest = 'New Delivery Request!';
  static const String estimatedEarnings = 'Estimated Earnings';
  static const String pickupFrom = 'Pickup from';
  static const String deliverTo = 'Deliver to';
  static const String totalDistance = 'Total Distance';
  static const String estTime = 'Est. Time';
  static const String acceptOrder = 'Accept Order';
  static const String declineOrder = 'Decline';

  // Active Order Flow
  static const String activeOrder = 'Active Delivery';
  static const String navigateToPickup = 'Navigate to Pickup';
  static const String navigateToDropoff = 'Navigate to Dropoff';
  static const String arrivedAtPickup = 'Arrived at Pickup';
  static const String orderPickedUp = 'Confirm Order Picked Up';
  static const String startDelivery = 'Start Delivery';
  static const String arrivedAtDropoff = 'Arrived at Customer';
  static const String completeDelivery = 'Complete Delivery';
  static const String customerContact = 'Contact Customer';
  static const String callCustomer = 'Call';
  static const String messageCustomer = 'Message';
  static const String orderItems = 'Order Items';
  static const String specialInstructions = 'Special Instructions';
  static const String proofOfDelivery = 'Proof of Delivery';
  static const String uploadProofPhoto = 'Take Proof Photo';
  static const String enterCustomerOtp = 'Enter Delivery OTP';

  // Earnings
  static const String wallet = 'Wallet & Earnings';
  static const String availableForPayout = 'Available Balance';
  static const String cashOut = 'Cash Out';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String baseFare = 'Base Delivery Pay';
  static const String customerTips = 'Tips';
  static const String surgeBonus = 'Surge & Incentives';
  static const String payoutHistory = 'Payout History';

  // Profile & Documents
  static const String profile = 'My Profile';
  static const String vehicleDetails = 'Vehicle Details';
  static const String documents = 'Documents & Verification';
  static const String appSettings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String helpSupport = 'Help & Support';
  static const String termsPrivacy = 'Terms & Privacy';
  static const String logout = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';

  // Document Statuses
  static const String docVerified = 'Verified';
  static const String docPending = 'Under Review';
  static const String docRejected = 'Action Required';
}
'''

# 6. lib/core/constants/app_constants.dart
files['lib/core/constants/app_constants.dart'] = '''/// AppConstants defines system-wide constants.
class AppConstants {
  AppConstants._();

  // Storage Keys
  static const String tokenKey = 'rider_auth_token';
  static const String refreshTokenKey = 'rider_refresh_token';
  static const String riderProfileKey = 'rider_profile_data';
  static const String isOnlineKey = 'rider_is_online';
  static const String isDarkModeKey = 'app_dark_mode';
  static const String offlineQueueKey = 'offline_order_queue';

  // Timers & Timeouts
  static const int incomingOrderTimeoutSeconds = 30;
  static const int otpResendSeconds = 45;
  static const int locationUpdateIntervalSeconds = 10;
  static const int connectionTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Mock Settings
  static const bool useMockApi = true; // Provides instantaneous full simulation
}
'''

# 7. lib/core/error/failures.dart
files['lib/core/error/failures.dart'] = '''import 'package:equatable/equatable.dart';

/// Failure base class for functional error handling with Either<Failure, T>.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Changes queued offline.'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}
'''

# 8. lib/core/error/exceptions.dart
files['lib/core/error/exceptions.dart'] = '''/// Custom Exceptions thrown in Data layer
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network connection failure'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}
'''

# 9. lib/core/network/network_info.dart
files['lib/core/network/network_info.dart'] = '''abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // Simulated connected state
}
'''

# 10. lib/core/utils/validators.dart
files['lib/core/utils/validators.dart'] = '''class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 8 || clean.length > 15) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the 6-digit OTP';
    }
    if (value.trim().length != 6) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
'''

# 11. lib/core/utils/formatters.dart
files['lib/core/utils/formatters.dart'] = '''import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDistance(double km) {
    if (km < 1.0) {
      return '\${(km * 1000).toInt()} m';
    }
    return '\${km.toStringAsFixed(1)} km';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '\$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) return '\$hours hrs';
    return '\${hours}h \${remainingMins}m';
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
}
'''

# 12. lib/core/utils/extensions.dart
files['lib/core/utils/extensions.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get backgroundColor => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    return '\${parts.first[0]}\${parts.last[0]}'.toUpperCase();
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

