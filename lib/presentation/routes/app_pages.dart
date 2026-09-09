import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/main_layout/bindings/main_layout_binding.dart';
import '../modules/main_layout/views/main_layout_view.dart';
import '../modules/orders/views/active_order_view.dart';
import '../modules/navigation/bindings/navigation_binding.dart';
import '../modules/navigation/views/navigation_view.dart';
import '../modules/earnings/bindings/earnings_binding.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/documents_view.dart';
import '../modules/profile/views/operating_zones_view.dart';
import '../modules/profile/views/payout_info_view.dart';
import '../modules/profile/views/vehicle_info_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.activeOrder,
      page: () => const ActiveOrderView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.navigation,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.earnings,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.operatingZones,
      page: () => const OperatingZonesView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.payoutInfo,
      page: () => const PayoutInfoView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.vehicleInfo,
      page: () => const VehicleInfoView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
