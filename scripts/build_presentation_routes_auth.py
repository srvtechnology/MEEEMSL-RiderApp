import os

files = {}

# 1. Routes
files['lib/presentation/routes/app_routes.dart'] = '''/// AppRoutes defines string route paths across the entire application.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';

  static const String main = '/main';
  static const String dashboard = '/dashboard';
  
  static const String activeOrder = '/active-order';
  static const String orderDetails = '/order-details';
  static const String orderHistory = '/order-history';

  static const String navigation = '/navigation';

  static const String earnings = '/earnings';
  static const String payout = '/payout';

  static const String profile = '/profile';
  static const String documents = '/documents';
  static const String vehicleInfo = '/vehicle-info';
  
  static const String notifications = '/notifications';
}
'''

files['lib/presentation/routes/auth_guard.dart'] = '''import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import 'app_routes.dart';

/// AuthGuard checks if the rider is authenticated before granting access to protected screens.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
'''

# 2. Splash Module
files['lib/presentation/modules/splash/controllers/splash_controller.dart'] = '''import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkInitialState();
  }

  void _checkInitialState() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
'''

files['lib/presentation/modules/splash/bindings/splash_binding.dart'] = '''import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
'''

files['lib/presentation/modules/splash/views/splash_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: AppTextStyles.displayMedium(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.appTagline,
                style: AppTextStyles.bodyMedium(color: Colors.white70),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 32),
              Text(
                'v1.0.0 (Build 2026)',
                style: AppTextStyles.labelSmall(color: Colors.white54),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
'''

# 3. Auth Module
files['lib/presentation/modules/auth/controllers/auth_controller.dart'] = '''import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/rider_entity.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../../domain/usecases/auth/register_rider_usecase.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterRiderUseCase registerRiderUseCase;

  AuthController({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.registerRiderUseCase,
  });

  // State Observables
  final isLoading = false.obs;
  final selectedCountryCode = '+1'.obs;
  final phoneNumber = ''.obs;
  final otpCode = ''.obs;
  final resendTimerSeconds = AppConstants.otpResendSeconds.obs;
  final canResendOtp = false.obs;
  Timer? _timer;

  // Controllers
  final phoneTextController = TextEditingController();
  final otpTextController = TextEditingController();
  
  // Registration Form Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final vehicleType = 'Motorcycle'.obs;
  final vehicleModelController = TextEditingController();
  final licensePlateController = TextEditingController();

  @override
  void onClose() {
    _timer?.cancel();
    phoneTextController.dispose();
    otpTextController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    vehicleModelController.dispose();
    licensePlateController.dispose();
    super.onClose();
  }

  void startResendTimer() {
    _timer?.cancel();
    resendTimerSeconds.value = AppConstants.otpResendSeconds;
    canResendOtp.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimerSeconds.value > 0) {
        resendTimerSeconds.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> sendOtp() async {
    final phone = phoneTextController.text.trim();
    final error = Validators.validatePhone(phone);
    if (error != null) {
      Get.snackbar('Invalid Input', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final fullPhone = '\${selectedCountryCode.value} \$phone';
    phoneNumber.value = fullPhone;

    final result = await loginUseCase(fullPhone);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
      (success) {
        startResendTimer();
        Get.toNamed(AppRoutes.otp);
      },
    );
  }

  Future<void> verifyOtp() async {
    final otp = otpTextController.text.trim();
    final error = Validators.validateOtp(otp);
    if (error != null) {
      Get.snackbar('Invalid OTP', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await verifyOtpUseCase(phoneNumber.value, otp);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Verification Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (rider) {
        Get.snackbar('Welcome!', 'Logged in as \${rider.name}', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(AppRoutes.main);
      },
    );
  }

  Future<void> registerRider() async {
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (licensePlateController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your vehicle license plate', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final data = {
      'name': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneNumber.value,
      'vehicle': {
        'type': vehicleType.value,
        'model': vehicleModelController.text.trim(),
        'licensePlate': licensePlateController.text.trim(),
      }
    };

    final result = await registerRiderUseCase(data);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Registration Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (rider) {
        Get.snackbar('Success', 'Registration submitted for verification!', snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(AppRoutes.main);
      },
    );
  }
}
'''

files['lib/presentation/modules/auth/bindings/auth_binding.dart'] = '''import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../../domain/usecases/auth/register_rider_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(Get.find<DioClient>()));
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(Get.find()));

    // Repository
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(
          remoteDataSource: Get.find<AuthRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ));

    // UseCases
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => VerifyOtpUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => RegisterRiderUseCase(Get.find<AuthRepository>()));

    // Controller
    Get.lazyPut<AuthController>(() => AuthController(
          loginUseCase: Get.find<LoginUseCase>(),
          verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
          registerRiderUseCase: Get.find<RegisterRiderUseCase>(),
        ));
  }
}
'''

files['lib/presentation/modules/auth/views/login_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Header Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppStrings.welcomeBack,
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.loginSubtitle,
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 40),

              // Phone Number Field with Country Code
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lightCardBorder,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Obx(() => DropdownButton<String>(
                            value: controller.selectedCountryCode.value,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, size: 20),
                            items: const [
                              DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                              DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                              DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                            ],
                            onChanged: (val) {
                              if (val != null) controller.selectedCountryCode.value = val;
                            },
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.phoneTextController,
                      hintText: '555 019 2834',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Send OTP Button
              Obx(() => CustomButton(
                    text: AppStrings.sendOtp,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.sendOtp(),
                  )),

              const SizedBox(height: 24),
              // Register Prompt
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Want to become a rider? ",
                      style: AppTextStyles.bodyMedium(),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        "Register",
                        style: AppTextStyles.labelLarge(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              // Terms footnote
              Center(
                child: Text(
                  'By signing in, you agree to our Terms of Service & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
'''

files['lib/presentation/modules/auth/views/otp_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOtp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    '\${AppStrings.otpSubtitle} \${controller.phoneNumber.value}',
                    style: AppTextStyles.bodyMedium(),
                  )),
              const SizedBox(height: 36),

              // 6-Digit OTP Field
              CustomTextField(
                controller: controller.otpTextController,
                hintText: '• • • • • •',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_outline,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 24),

              // Timer & Resend Button
              Center(
                child: Obx(() {
                  if (controller.canResendOtp.value) {
                    return TextButton.icon(
                      onPressed: () => controller.sendOtp(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(AppStrings.resendOtp),
                    );
                  }
                  return Text(
                    '\${AppStrings.resendIn} \${controller.resendTimerSeconds.value}s',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify Button
              Obx(() => CustomButton(
                    text: AppStrings.verifyOtp,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.verifyOtp(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
'''

files['lib/presentation/modules/auth/views/register_view.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal & Vehicle Details',
                style: AppTextStyles.headlineSmall(),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.registerSubtitle,
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 28),

              // Full Name
              CustomTextField(
                controller: controller.fullNameController,
                label: AppStrings.fullName,
                hintText: 'John Doe',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: controller.emailController,
                label: AppStrings.email,
                hintText: 'john.doe@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Vehicle Type Dropdown
              const Text(
                AppStrings.vehicleType,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.vehicleType.value,
                        items: const [
                          DropdownMenuItem(value: 'Motorcycle', child: Text('🏍️ Motorcycle / Scooter')),
                          DropdownMenuItem(value: 'Bicycle', child: Text('🚲 Bicycle / E-Bike')),
                          DropdownMenuItem(value: 'Car', child: Text('🚗 Car / Sedan')),
                          DropdownMenuItem(value: 'Van', child: Text('🚐 Delivery Van')),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.vehicleType.value = val;
                        },
                      ),
                    )),
              ),
              const SizedBox(height: 16),

              // Vehicle Model
              CustomTextField(
                controller: controller.vehicleModelController,
                label: AppStrings.vehicleModel,
                hintText: 'e.g. Honda CB500X',
                prefixIcon: Icons.two_wheeler_outlined,
              ),
              const SizedBox(height: 16),

              // License Plate
              CustomTextField(
                controller: controller.licensePlateController,
                label: AppStrings.vehiclePlate,
                hintText: 'e.g. NY-9820-AA',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 36),

              // Submit Button
              Obx(() => CustomButton(
                    text: 'Complete Application',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.registerRider(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
'''

# 4. Main Layout Module
files['lib/presentation/modules/main_layout/controllers/main_layout_controller.dart'] = '''import 'package:get/get.dart';

class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;
  final unreadNotificationsCount = 2.obs;
  final hasActiveOrder = true.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
'''

files['lib/presentation/modules/main_layout/bindings/main_layout_binding.dart'] = '''import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../../data/datasources/order_remote_datasource.dart';
import '../../../../data/datasources/earnings_remote_datasource.dart';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../../../../data/repositories/dashboard_repository_impl.dart';
import '../../../../data/repositories/order_repository_impl.dart';
import '../../../../data/repositories/earnings_repository_impl.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/repositories/dashboard_repository.dart';
import '../../../../domain/repositories/order_repository.dart';
import '../../../../domain/repositories/earnings_repository.dart';
import '../../../../domain/repositories/profile_repository.dart';
import '../../../../domain/usecases/dashboard/toggle_online_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import '../../../../domain/usecases/dashboard/update_live_location_usecase.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/get_incoming_order_usecase.dart';
import '../../../../domain/usecases/orders/accept_order_usecase.dart';
import '../../../../domain/usecases/orders/decline_order_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../../domain/usecases/profile/get_documents_usecase.dart';
import '../../../../domain/usecases/profile/upload_document_usecase.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_layout_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());

    // Core Datasources
    final dioClient = Get.find<DioClient>();
    final localDataSource = Get.find<AuthLocalDataSource>();

    Get.lazyPut<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(dioClient));
    Get.lazyPut<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(dioClient));
    Get.lazyPut<EarningsRemoteDataSource>(() => EarningsRemoteDataSourceImpl(dioClient));
    Get.lazyPut<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(dioClient));

    // Repositories
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl(
          remoteDataSource: Get.find<DashboardRemoteDataSource>(),
          localDataSource: localDataSource,
        ));
    Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl(
          remoteDataSource: Get.find<OrderRemoteDataSource>(),
        ));
    Get.lazyPut<EarningsRepository>(() => EarningsRepositoryImpl(
          remoteDataSource: Get.find<EarningsRemoteDataSource>(),
        ));
    Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(
          remoteDataSource: Get.find<ProfileRemoteDataSource>(),
          localDataSource: localDataSource,
        ));

    // UseCases
    Get.lazyPut(() => ToggleOnlineStatusUseCase(Get.find<DashboardRepository>()));
    Get.lazyPut(() => GetDashboardSummaryUseCase(Get.find<DashboardRepository>()));
    Get.lazyPut(() => UpdateLiveLocationUseCase(Get.find<DashboardRepository>()));

    Get.lazyPut(() => GetActiveOrdersUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetIncomingOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => AcceptOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => DeclineOrderUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => UpdateOrderStatusUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetOrderHistoryUseCase(Get.find<OrderRepository>()));
    Get.lazyPut(() => GetOrderDetailsUseCase(Get.find<OrderRepository>()));

    Get.lazyPut(() => GetEarningsBreakdownUseCase(Get.find<EarningsRepository>()));
    Get.lazyPut(() => RequestPayoutUseCase(Get.find<EarningsRepository>()));

    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetDocumentsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UploadDocumentUseCase(Get.find<ProfileRepository>()));

    // Module Controllers
    Get.lazyPut<DashboardController>(() => DashboardController(
          toggleOnlineStatusUseCase: Get.find<ToggleOnlineStatusUseCase>(),
          getDashboardSummaryUseCase: Get.find<GetDashboardSummaryUseCase>(),
          getActiveOrdersUseCase: Get.find<GetActiveOrdersUseCase>(),
          getIncomingOrderUseCase: Get.find<GetIncomingOrderUseCase>(),
          acceptOrderUseCase: Get.find<AcceptOrderUseCase>(),
          declineOrderUseCase: Get.find<DeclineOrderUseCase>(),
        ));

    Get.lazyPut<OrdersController>(() => OrdersController(
          getActiveOrdersUseCase: Get.find<GetActiveOrdersUseCase>(),
          updateOrderStatusUseCase: Get.find<UpdateOrderStatusUseCase>(),
          getOrderHistoryUseCase: Get.find<GetOrderHistoryUseCase>(),
          getOrderDetailsUseCase: Get.find<GetOrderDetailsUseCase>(),
        ));

    Get.lazyPut<EarningsController>(() => EarningsController(
          getEarningsBreakdownUseCase: Get.find<GetEarningsBreakdownUseCase>(),
          requestPayoutUseCase: Get.find<RequestPayoutUseCase>(),
        ));

    Get.lazyPut<ProfileController>(() => ProfileController(
          getProfileUseCase: Get.find<GetProfileUseCase>(),
          updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
          getDocumentsUseCase: Get.find<GetDocumentsUseCase>(),
          uploadDocumentUseCase: Get.find<UploadDocumentUseCase>(),
        ));
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

