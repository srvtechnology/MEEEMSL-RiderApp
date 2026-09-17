import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/payout_info_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/rider_entity.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/login_with_password_usecase.dart';
import '../../../../domain/usecases/auth/login_with_email_password_usecase.dart';
import '../../../../domain/usecases/auth/send_phone_otp_usecase.dart';
import '../../../../domain/usecases/auth/verify_phone_otp_usecase.dart';
import '../../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../../domain/usecases/auth/register_rider_usecase.dart';
import '../../../../domain/usecases/auth/self_register_usecase.dart';
import '../../../../domain/usecases/auth/verify_registration_otp_usecase.dart';
import '../../../../domain/usecases/auth/resend_registration_otp_usecase.dart';
import '../../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../../domain/usecases/auth/submit_onboarding_usecase.dart';
import '../../../../domain/usecases/profile/get_operating_zones_usecase.dart';
import '../../../../domain/entities/operating_zone_entity.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/error/failures.dart';
import '../widgets/suspended_account_dialog.dart';
import '../../../routes/app_routes.dart';

enum OtpFlowType {
  registration,
  phoneLogin,
}

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final LoginWithPasswordUseCase loginWithPasswordUseCase;
  final LoginWithEmailPasswordUseCase loginWithEmailPasswordUseCase;
  final SendPhoneOtpUseCase sendPhoneOtpUseCase;
  final VerifyPhoneOtpUseCase verifyPhoneOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterRiderUseCase registerRiderUseCase;
  final SubmitOnboardingUseCase submitOnboardingUseCase;
  final SelfRegisterUseCase selfRegisterUseCase;
  final VerifyRegistrationOtpUseCase verifyRegistrationOtpUseCase;
  final ResendRegistrationOtpUseCase resendRegistrationOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final DeviceInfoService deviceInfoService;
  final GetOperatingZonesUseCase? getOperatingZonesUseCase;

  AuthController({
    required this.loginUseCase,
    required this.loginWithPasswordUseCase,
    required this.loginWithEmailPasswordUseCase,
    required this.sendPhoneOtpUseCase,
    required this.verifyPhoneOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerRiderUseCase,
    required this.submitOnboardingUseCase,
    required this.selfRegisterUseCase,
    required this.verifyRegistrationOtpUseCase,
    required this.resendRegistrationOtpUseCase,
    required this.resetPasswordUseCase,
    required this.deviceInfoService,
    this.getOperatingZonesUseCase,
  });

  // State Observables
  final isLoading = false.obs;
  final isEmailLoginMode = true.obs;
  final isPasswordVisible = false.obs;
  final selectedCountryCode = AppConstants.defaultCountryCode.obs;
  final phoneNumber = ''.obs;
  final otpCode = ''.obs;
  final resendTimerSeconds = AppConstants.otpResendSeconds.obs;
  final canResendOtp = false.obs;
  Timer? _timer;

  // Registration Controllers & State
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerCountryCode = AppConstants.defaultCountryCode.obs;
  final registerIsPasswordVisible = false.obs;
  final registerVehicleType = 'BIKE'.obs;
  final registerVehicleNumberController = TextEditingController();
  final registerDrivingLicenseController = TextEditingController();
  final otpFlowType = OtpFlowType.registration.obs;
  final registrationEmail = ''.obs;

  // Login Controllers & State
  final loginEmailController = TextEditingController();
  TextEditingController get loginIdentifierController => loginEmailController;
  final loginPasswordController = TextEditingController();
  final phoneTextController = TextEditingController();
  final otpTextController = TextEditingController();
  final isPendingApproval = false.obs;
  final pendingApprovalMessage = ''.obs;

  // Forgot / Reset Password Controllers
  final resetIdentityController = TextEditingController();
  final resetOtpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isResetCodeSent = false.obs;
  final resetMaskedDestination = ''.obs;

  // 5-Step Onboarding Wizard State
  final onboardingStep = 0.obs;
  final profilePhotoPath = ''.obs;
  final nationalIdFrontPath = ''.obs;
  final nationalIdBackPath = ''.obs;
  final driverLicensePath = ''.obs;
  final vehicleInsurancePath = ''.obs;

  // Step 1: Personal Info
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final onboardingPhoneController = TextEditingController();

  // Step 2: Documents & Driving License
  final drivingLicenseNoController = TextEditingController();
  final idExpiryController = TextEditingController();
  final licenseExpiryController = TextEditingController();
  final insuranceExpiryController = TextEditingController();

  // Step 3: Vehicle Details
  // Allowed values per API doc: "2_WHEELER", "3_WHEELER", "4_WHEELER", "BICYCLE"
  final vehicleType = ''.obs;
  final vehicleModelController = TextEditingController();
  final licensePlateController = TextEditingController();
  final vehicleColorController = TextEditingController();
  final vehicleYearController = TextEditingController();

  // Step 4: Operating Zones & Hierarchical Locations
  final operatingZonesList = <OperatingZoneEntity>[].obs;
  final isLoadingZones = false.obs;
  final selectedZones = <String>[].obs;
  final selectedLocations = <String>[].obs;

  // Step 5: Payout Info (API Doc Part 2)
  final selectedPaymentOption = PaymentOption.bank.obs;
  Rx<PaymentOption> get payoutMethodType => selectedPaymentOption;

  // Bank fields
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bbanNumberController = TextEditingController();
  final bankAddressController = TextEditingController();
  TextEditingController get routingNumberController => bbanNumberController;

  // Mobile money fields (Orange Money / AfriMoney)
  final mobileNumberController = TextEditingController();
  final agentNumberController = TextEditingController();
  final mobileMoneyProviderController = TextEditingController();
  TextEditingController get mobileMoneyNumberController => mobileNumberController;
  final beneficiaryNameController = TextEditingController();

  final _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    initOnboardingData();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void clearAuthFields() {
    loginPasswordController.clear();
    registerPasswordController.clear();
    registerVehicleNumberController.clear();
    registerDrivingLicenseController.clear();
    otpTextController.clear();
    resetOtpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    registerIsPasswordVisible.value = !registerIsPasswordVisible.value;
  }

  void startResendTimer({int? seconds}) {
    _timer?.cancel();
    resendTimerSeconds.value = seconds ?? AppConstants.otpResendSeconds;
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

  void cancelResendTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // 2.1 Rider Self-Registration
  Future<void> selfRegisterRider() async {
    final name = registerNameController.text.trim();
    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();
    final phone = registerPhoneController.text.trim();
    final countryCode = registerCountryCode.value;
    final vehicleType = registerVehicleType.value;
    final vehicleNumber = registerVehicleNumberController.text.trim();
    final drivingLicense = registerDrivingLicenseController.text.trim();

    final nameError = Validators.validateName(name);
    if (nameError != null) {
      Get.snackbar('Validation', nameError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar('Validation', AppStrings.phoneNumberRequired, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final phoneError = Validators.validatePhone(phone);
    if (phoneError != null) {
      Get.snackbar('Validation', phoneError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (email.isNotEmpty) {
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        Get.snackbar('Validation', emailError, snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      Get.snackbar('Validation', passwordError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (vehicleNumber.isEmpty) {
      Get.snackbar('Validation', AppStrings.vehicleNumberRequired, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final deviceId = await deviceInfoService.getDeviceId();
    final platform = deviceInfoService.getPlatform();

    final result = await selfRegisterUseCase(
      name: name,
      phone: phone,
      phoneCountryCode: countryCode,
      email: email.isNotEmpty ? email : null,
      password: password,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      drivingLicense: drivingLicense.isNotEmpty ? drivingLicense : null,
      deviceId: deviceId,
      platform: platform,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Registration Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (data) {
        registrationEmail.value = email;
        phoneNumber.value = '$countryCode$phone';
        otpFlowType.value = OtpFlowType.registration;
        otpTextController.clear();
        startResendTimer(seconds: data.resendCooldown);
        Get.snackbar(
          'Registration Successful',
          'A 6-digit verification code has been sent via SMS to $countryCode $phone',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          duration: const Duration(seconds: 4),
        );
        Get.toNamed(AppRoutes.otp);
      },
    );
  }

  // Resend current OTP (Registration Phone SMS OTP vs Phone SMS OTP)
  Future<void> resendCurrentOtp() async {
    if (!canResendOtp.value) return;

    isLoading.value = true;
    if (otpFlowType.value == OtpFlowType.registration) {
      final phone = registerPhoneController.text.trim().isNotEmpty
          ? registerPhoneController.text.trim()
          : (phoneNumber.value.isNotEmpty ? phoneNumber.value : null);
      final countryCode = registerCountryCode.value.isNotEmpty ? registerCountryCode.value : AppConstants.defaultCountryCode;
      final email = registrationEmail.value.isNotEmpty ? registrationEmail.value : null;

      final result = await resendRegistrationOtpUseCase(
        phone: phone,
        phoneCountryCode: countryCode,
        email: email,
      );
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
        (data) {
          startResendTimer(seconds: data.resendCooldown);
          final destination = (phone != null && phone.isNotEmpty)
              ? '$countryCode $phone'
              : (email ?? 'your device');
          Get.snackbar(
            'New Code Sent',
            'Verification code resent via SMS to $destination',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
          );
        },
      );
    } else {
      final result = await loginUseCase(phoneNumber.value);
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
        (success) {
          startResendTimer();
          Get.snackbar(
            'New OTP Sent',
            'Login OTP resent to ${phoneNumber.value}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
          );
        },
      );
    }
  }

  void _handleLoginSuccess(UserEntity user, RiderEntity rider) {
    if (!user.isPhoneVerified && !user.isEmailVerified) {
      if (user.phone.isNotEmpty) {
        phoneNumber.value = '${user.phoneCountryCode}${user.phone}';
      }
      registrationEmail.value = user.email;
      otpFlowType.value = OtpFlowType.registration;
      startResendTimer();
      Get.snackbar(
        'Verification Required',
        'Please verify your phone number to proceed.',
        snackPosition: SnackPosition.TOP,
      );
      Get.toNamed(AppRoutes.otp);
      return;
    }

    if (rider.isSuspended || rider.status == 'SUSPENDED') {
      SuspendedAccountDialog.show();
      return;
    }

    // Redirect to onboarding if onboarding is not completed, is first login, or essential details missing
    final bool requiresOnboarding = !rider.onboardingCompleted ||
        rider.isFirstLogin ||
        rider.vehicleNumber == null ||
        rider.vehicleNumber!.isEmpty ||
        rider.drivingLicenseNo == null ||
        rider.drivingLicenseNo!.isEmpty ||
        rider.selectedZones.isEmpty;

    if (requiresOnboarding) {
      initOnboardingData(user: user, rider: rider);
      onboardingStep.value = 0;
      Get.snackbar(
        'Welcome, ${user.name.isNotEmpty ? user.name : "Rider"}!',
        'Please complete your initial rider onboarding details.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    if (!rider.isApproved || rider.status.toUpperCase() == 'PENDING') {
      Get.offAllNamed(AppRoutes.pendingApproval);
      return;
    }

    Get.snackbar(
      'Welcome Back!',
      'Signed in as ${user.name.isNotEmpty ? user.name : rider.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE8F8EE),
    );
    Get.offAllNamed(AppRoutes.main);
  }

  // 3.1 Rider Login with Email/Phone & Password (with Auto Device Token Registration)
  Future<void> loginWithEmailPassword() async {
    final identifier = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    if (identifier.isEmpty) {
      Get.snackbar('Validation', 'Please enter your email or mobile number', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final isEmail = identifier.contains('@');
    if (isEmail) {
      final emailError = Validators.validateEmail(identifier);
      if (emailError != null) {
        Get.snackbar('Validation', emailError, snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (password.isEmpty || password.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isPendingApproval.value = false;
    isLoading.value = true;
    final deviceId = await deviceInfoService.getDeviceId();
    final platform = deviceInfoService.getPlatform();
    final userAgent = await deviceInfoService.getUserAgent();
    final storage = GetStorage();
    final deviceToken = storage.read<String>(AppConstants.devicePushTokenKey) ?? 'fcm_mock_device_token';

    final result = await loginWithEmailPasswordUseCase(
      identifier: identifier,
      email: isEmail ? identifier : null,
      phone: !isEmail ? identifier : null,
      phoneCountryCode: AppConstants.defaultCountryCode,
      password: password,
      deviceId: deviceId,
      platform: platform,
      deviceToken: deviceToken,
      userAgent: userAgent,
    );
    isLoading.value = false;

    result.fold(
      (failure) {
        if (failure is SuspendedFailure) {
          SuspendedAccountDialog.show(message: failure.message);
        } else if (failure is UnverifiedAccountFailure) {
          otpFlowType.value = OtpFlowType.registration;
          if (isEmail) {
            registrationEmail.value = identifier;
          } else {
            phoneNumber.value = identifier;
          }
          startResendTimer();
          Get.snackbar(
            'Verification Required',
            failure.message.isNotEmpty ? failure.message : 'Please verify your phone number to proceed.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFFF4E5),
          );
          Get.toNamed(AppRoutes.otp);
        } else if (failure is PendingApprovalFailure) {
          isPendingApproval.value = true;
          pendingApprovalMessage.value = failure.message.isNotEmpty
              ? failure.message
              : AppStrings.accountPendingVerification;
        } else {
          Get.snackbar('Sign In Failed', failure.message, snackPosition: SnackPosition.BOTTOM);
        }
      },
      (res) => _handleLoginSuccess(res.user, res.rider),
    );
  }

  // 3.2 (A) Send Phone OTP via SMS
  Future<void> sendOtp() async {
    final phone = phoneTextController.text.trim();
    final error = Validators.validatePhone(phone);
    if (error != null) {
      Get.snackbar('Invalid Input', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final fullPhone = '${selectedCountryCode.value}$phone';
    phoneNumber.value = fullPhone;
    otpFlowType.value = OtpFlowType.phoneLogin;
    otpTextController.clear();

    final result = await sendPhoneOtpUseCase(fullPhone);
    isLoading.value = false;

    result.fold(
      (failure) {
        if (failure is SuspendedFailure) {
          SuspendedAccountDialog.show(message: failure.message);
        } else if (failure is RateLimitFailure) {
          startResendTimer(seconds: failure.cooldownSeconds);
          Get.snackbar('Cooldown Active', failure.message, snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
        }
      },
      (res) {
        startResendTimer(seconds: res.resendCooldown);
        Get.toNamed(AppRoutes.otp);
      },
    );
  }

  // 3.2 (B) Verify Phone OTP & Obtain Session Tokens (or Phone/Email Registration OTP)
  Future<void> verifyOtp() async {
    final otp = otpTextController.text.trim();
    final error = Validators.validateOtp(otp);
    if (error != null) {
      Get.snackbar('Invalid OTP', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    if (otpFlowType.value == OtpFlowType.registration) {
      final phone = registerPhoneController.text.trim().isNotEmpty
          ? registerPhoneController.text.trim()
          : (phoneNumber.value.isNotEmpty ? phoneNumber.value : null);
      final countryCode = registerCountryCode.value.isNotEmpty ? registerCountryCode.value : AppConstants.defaultCountryCode;
      final email = registrationEmail.value.isNotEmpty ? registrationEmail.value : null;

      final result = await verifyRegistrationOtpUseCase(
        phone: phone,
        phoneCountryCode: countryCode,
        email: email,
        otp: otp,
      );
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Verification Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
        (res) {
          Get.snackbar(
            'Verification Successful!',
            'Account verified successfully! You can now log in to complete your rider onboarding.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(AppRoutes.login);
        },
      );
    } else {
      final deviceId = await deviceInfoService.getDeviceId();
      final platform = deviceInfoService.getPlatform();
      final userAgent = await deviceInfoService.getUserAgent();
      final storage = GetStorage();
      final deviceToken = storage.read<String>(AppConstants.devicePushTokenKey) ?? 'fcm_mock_device_token';

      final result = await verifyPhoneOtpUseCase(
        phone: phoneNumber.value,
        otp: otp,
        deviceId: deviceId,
        platform: platform,
        deviceToken: deviceToken,
        userAgent: userAgent,
      );
      isLoading.value = false;

      result.fold(
        (failure) {
          if (failure is SuspendedFailure) {
            SuspendedAccountDialog.show(message: failure.message);
          } else {
            Get.snackbar('Verification Failed', failure.message, snackPosition: SnackPosition.BOTTOM);
          }
        },
        (res) => _handleLoginSuccess(res.user, res.rider),
      );
    }
  }

  // Password Reset Flow
  Future<void> sendResetCode() async {
    final identity = resetIdentityController.text.trim();
    if (identity.isEmpty) {
      Get.snackbar('Input Required', 'Please enter your registered email or phone', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final isEmail = identity.contains('@');
    final countryCode = !isEmail ? AppConstants.defaultCountryCode : null;
    final result = await resetPasswordUseCase.sendResetCode(identity, countryCode);
    isLoading.value = false;

    result.fold(
      (failure) {
        if (failure is RateLimitFailure) {
          startResendTimer(seconds: failure.cooldownSeconds);
          Get.snackbar('Cooldown Active', failure.message, snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM);
        }
      },
      (res) {
        resetMaskedDestination.value = res.maskedDestination;
        isResetCodeSent.value = true;
        startResendTimer(seconds: res.resendCooldown);
        Get.snackbar(
          'Code Sent',
          'Password reset code sent to ${res.maskedDestination}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  Future<void> confirmPasswordReset() async {
    final identity = resetIdentityController.text.trim();
    final otp = resetOtpController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (otp.length < 4) {
      Get.snackbar('Validation', 'Please enter the verification code sent to you', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPass.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPass != confirmPass) {
      Get.snackbar('Validation', 'Passwords do not match', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final isEmail = identity.contains('@');
    final countryCode = !isEmail ? AppConstants.defaultCountryCode : null;
    final result = await resetPasswordUseCase.confirmReset(identity, otp, newPass, countryCode);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Reset Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (success) {
        Get.snackbar(
          'Password Reset Successful',
          'Password has been successfully reset. Please log in with your new credentials.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          duration: const Duration(seconds: 4),
        );
        isResetCodeSent.value = false;
        resetOtpController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  // Image Picking for Onboarding & Documents with Compression
  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final photoPath = await CameraService.to.capturePhoto(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        quality: 70,
        showGalleryFallback: true,
      );
      if (photoPath != null) {
        profilePhotoPath.value = photoPath;
      }
    } catch (_) {
      // Mock fallback if running without native camera permissions
      profilePhotoPath.value = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';
    }
  }

  Future<void> pickDocument(String docType, {ImageSource source = ImageSource.gallery}) async {
    try {
      final photoPath = await CameraService.to.capturePhoto(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        quality: 70,
        showGalleryFallback: true,
      );
      if (photoPath != null) {
        _setDocPath(docType, photoPath);
      }
    } catch (_) {
      _setDocPath(docType, 'mock_doc_path_${DateTime.now().millisecondsSinceEpoch}.jpg');
    }
  }

  void _setDocPath(String docType, String path) {
    switch (docType) {
      case 'national_id_front':
        nationalIdFrontPath.value = path;
        break;
      case 'national_id_back':
        nationalIdBackPath.value = path;
        break;
      case 'driver_license':
        driverLicensePath.value = path;
        break;
      case 'vehicle_insurance':
        vehicleInsurancePath.value = path;
        break;
    }
    Get.snackbar('Document Uploaded', 'Attached successfully', snackPosition: SnackPosition.BOTTOM);
  }

  void initOnboardingData({UserEntity? user, RiderEntity? rider}) {
    try {
      final localSource = Get.isRegistered<AuthLocalDataSource>() ? Get.find<AuthLocalDataSource>() : null;
      final savedUser = user ?? localSource?.getSavedUser();
      if (savedUser != null) {
        if (savedUser.name.isNotEmpty) {
          fullNameController.text = savedUser.name;
        }
        if (savedUser.email.isNotEmpty) {
          emailController.text = savedUser.email;
        }
        if (savedUser.phone.isNotEmpty) {
          final code = savedUser.phoneCountryCode;
          onboardingPhoneController.text = (code.isNotEmpty && !savedUser.phone.startsWith('+'))
              ? '$code${savedUser.phone}'
              : savedUser.phone;
        }
        if (savedUser.image != null && savedUser.image!.isNotEmpty) {
          profilePhotoPath.value = savedUser.image!;
        }
      }

      final savedRider = rider ?? localSource?.getSavedRider();
      if (savedRider != null) {
        if (fullNameController.text.isEmpty && savedRider.name.isNotEmpty) {
          fullNameController.text = savedRider.name;
        }
        if (onboardingPhoneController.text.isEmpty && savedRider.phone.isNotEmpty) {
          onboardingPhoneController.text = savedRider.phone;
        }
        if (emailController.text.isEmpty && savedRider.email.isNotEmpty) {
          emailController.text = savedRider.email;
        }
        if (profilePhotoPath.value.isEmpty) {
          if (savedRider.profileImage != null && savedRider.profileImage!.isNotEmpty) {
            profilePhotoPath.value = savedRider.profileImage!;
          } else if (savedRider.avatar.isNotEmpty) {
            profilePhotoPath.value = savedRider.avatar;
          }
        }
      }

      // Direct fallback to GetStorage if localSource was not ready or fields still empty
      if (fullNameController.text.isEmpty || emailController.text.isEmpty || onboardingPhoneController.text.isEmpty) {
        try {
          final storage = GetStorage();
          final rawUser = storage.read<String>(AppConstants.userProfileKey);
          if (rawUser != null) {
            final userMap = jsonDecode(rawUser) as Map<String, dynamic>;
            if (fullNameController.text.isEmpty && userMap['name'] != null) {
              fullNameController.text = userMap['name'] as String;
            }
            if (emailController.text.isEmpty && userMap['email'] != null) {
              emailController.text = userMap['email'] as String;
            }
            if (onboardingPhoneController.text.isEmpty && userMap['phone'] != null) {
              final p = userMap['phone'] as String;
              final c = (userMap['phoneCountryCode'] as String?) ?? '+232';
              onboardingPhoneController.text = (c.isNotEmpty && !p.startsWith('+')) ? '$c$p' : p;
            }
          }
        } catch (_) {}
      }
    } catch (_) {}
    loadOperatingZones();
  }

  Future<void> loadOperatingZones() async {
    isLoadingZones.value = true;
    try {
      final useCase = getOperatingZonesUseCase ??
          (Get.isRegistered<GetOperatingZonesUseCase>() ? Get.find<GetOperatingZonesUseCase>() : null);
      if (useCase != null) {
        final result = await useCase();
        result.fold(
          (failure) => _loadDefaultOperatingZones(),
          (zones) {
            if (zones.isNotEmpty) {
              operatingZonesList.assignAll(zones);
            } else {
              _loadDefaultOperatingZones();
            }
          },
        );
      } else {
        _loadDefaultOperatingZones();
      }
    } catch (_) {
      _loadDefaultOperatingZones();
    } finally {
      isLoadingZones.value = false;
    }
  }

  void _loadDefaultOperatingZones() {
    final defaultZones = [
      const OperatingZoneEntity(
        id: 'ZONE 1',
        name: 'ZONE 1 (Western Rural)',
        district: 'Western Rural',
        locations: [
          DeliveryLocationEntity(id: 'NO 2 RIVER', zoneId: 'ZONE 1', name: 'NO 2 RIVER'),
          DeliveryLocationEntity(id: 'BAW BAW', zoneId: 'ZONE 1', name: 'BAW BAW'),
          DeliveryLocationEntity(id: 'BIG WATER', zoneId: 'ZONE 1', name: 'BIG WATER'),
          DeliveryLocationEntity(id: 'JOHN OBEY', zoneId: 'ZONE 1', name: 'JOHN OBEY'),
          DeliveryLocationEntity(id: 'MAMA BEACH', zoneId: 'ZONE 1', name: 'MAMA BEACH'),
          DeliveryLocationEntity(id: 'TOKEH', zoneId: 'ZONE 1', name: 'TOKEH'),
          DeliveryLocationEntity(id: 'YORK', zoneId: 'ZONE 1', name: 'YORK'),
        ],
      ),
      const OperatingZoneEntity(
        id: 'ZONE 2',
        name: 'ZONE 2 (Peninsula Area)',
        district: 'Peninsula Area',
        locations: [
          DeliveryLocationEntity(id: 'HAMILTON', zoneId: 'ZONE 2', name: 'HAMILTON'),
          DeliveryLocationEntity(id: 'LAKKA', zoneId: 'ZONE 2', name: 'LAKKA'),
          DeliveryLocationEntity(id: 'SUSSEX', zoneId: 'ZONE 2', name: 'SUSSEX'),
          DeliveryLocationEntity(id: 'KIMBO VILLAGE', zoneId: 'ZONE 2', name: 'KIMBO VILLAGE'),
        ],
      ),
      const OperatingZoneEntity(
        id: 'ZONE 3',
        name: 'ZONE 3 (Central Business)',
        district: 'Central Business',
        locations: [
          DeliveryLocationEntity(id: 'COTTON TREE', zoneId: 'ZONE 3', name: 'COTTON TREE'),
          DeliveryLocationEntity(id: 'SIAKA STEVENS ST', zoneId: 'ZONE 3', name: 'SIAKA STEVENS ST'),
          DeliveryLocationEntity(id: 'CONNAUGHT', zoneId: 'ZONE 3', name: 'CONNAUGHT'),
        ],
      ),
      const OperatingZoneEntity(
        id: 'ZONE 4',
        name: 'ZONE 4 (East End)',
        district: 'East End',
        locations: [
          DeliveryLocationEntity(id: 'CLINE TOWN', zoneId: 'ZONE 4', name: 'CLINE TOWN'),
          DeliveryLocationEntity(id: 'KISSY', zoneId: 'ZONE 4', name: 'KISSY'),
          DeliveryLocationEntity(id: 'WELLINGTON', zoneId: 'ZONE 4', name: 'WELLINGTON'),
        ],
      ),
    ];
    operatingZonesList.assignAll(defaultZones);
  }

  void toggleZone(String zoneId) {
    if (selectedZones.contains(zoneId)) {
      selectedZones.remove(zoneId);
      final zone = operatingZonesList.firstWhereOrNull((z) => z.id == zoneId);
      if (zone != null) {
        final locNames = zone.locations.map((l) => l.name).toSet();
        selectedLocations.removeWhere((l) => locNames.contains(l));
      }
    } else {
      selectedZones.add(zoneId);
      final zone = operatingZonesList.firstWhereOrNull((z) => z.id == zoneId);
      if (zone != null) {
        for (final loc in zone.locations) {
          if (!selectedLocations.contains(loc.name)) {
            selectedLocations.add(loc.name);
          }
        }
      }
    }
  }

  void toggleLocation(String locationName) {
    if (selectedLocations.contains(locationName)) {
      selectedLocations.remove(locationName);
    } else {
      selectedLocations.add(locationName);
    }
  }

  void _safeShowSnackbar(String title, String message, {SnackPosition snackPosition = SnackPosition.BOTTOM}) {
    if (Get.overlayContext != null) {
      Get.snackbar(title, message, snackPosition: snackPosition);
    }
  }

  bool validatePayoutMethod() {
    final selectedOpt = selectedPaymentOption.value;
    if (selectedOpt == PaymentOption.bank) {
      final bankName = bankNameController.text.trim();
      final accountHolder = accountHolderController.text.trim();
      final accountNumber = accountNumberController.text.trim();

      if (bankName.isEmpty) {
        _safeShowSnackbar('Payout Method Required', 'Please enter your bank name');
        return false;
      }
      if (accountHolder.isEmpty) {
        _safeShowSnackbar('Payout Method Required', 'Please enter the bank account holder name');
        return false;
      }
      if (accountNumber.isEmpty) {
        _safeShowSnackbar('Payout Method Required', 'Please enter your bank account number');
        return false;
      }
    } else {
      // Orange Money or AfriMoney
      final mobilePhone = mobileNumberController.text.trim().isNotEmpty
          ? mobileNumberController.text.trim()
          : mobileMoneyNumberController.text.trim();
      if (mobilePhone.isEmpty) {
        _safeShowSnackbar('Payout Method Required', 'Please enter your ${selectedOpt.displayName} mobile number');
        return false;
      }
      final digitsOnly = mobilePhone.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length < 6) {
        _safeShowSnackbar('Payout Method Required', 'Please enter a valid mobile money number');
        return false;
      }
    }
    return true;
  }

  // 5-Step Onboarding Wizard Navigation
  void nextOnboardingStep() {
    final current = onboardingStep.value;
    if (current == 0) {
      if (profilePhotoPath.value.trim().isEmpty) {
        _safeShowSnackbar(
          'Profile Photo Required',
          'Please upload your profile photo to continue',
        );
        return;
      }
      final name = fullNameController.text.trim();
      final phone = onboardingPhoneController.text.trim();
      if (name.isEmpty) {
        _safeShowSnackbar('Personal Information', 'Please enter your legal full name');
        return;
      }
      if (phone.isEmpty) {
        _safeShowSnackbar('Personal Information', 'Please enter your phone number');
        return;
      }
    } else if (current == 1) {
      final dlNo = drivingLicenseNoController.text.trim();
      if (dlNo.isEmpty) {
        _safeShowSnackbar('Documents Required', "Please enter your Driver's License ID Number");
        return;
      }
      if (nationalIdFrontPath.value.trim().isEmpty) {
        _safeShowSnackbar('Document Upload Required', 'Please upload National ID / Passport (Front)');
        return;
      }
      if (nationalIdBackPath.value.trim().isEmpty) {
        _safeShowSnackbar('Document Upload Required', 'Please upload National ID / Passport (Back)');
        return;
      }
      if (driverLicensePath.value.trim().isEmpty) {
        _safeShowSnackbar('Document Upload Required', "Please upload your Driver's License Document");
        return;
      }
      if (vehicleInsurancePath.value.trim().isEmpty) {
        _safeShowSnackbar('Document Upload Required', 'Please upload your Vehicle Insurance Certificate');
        return;
      }
    } else if (current == 2) {
      if (vehicleType.value.isEmpty) {
        _safeShowSnackbar('Vehicle Information', 'Please select your vehicle type');
        return;
      }
      final plate = licensePlateController.text.trim();
      if (vehicleType.value != 'BICYCLE' && plate.isEmpty) {
        _safeShowSnackbar('Vehicle Information', 'Please enter your vehicle license plate / registration number');
        return;
      }
    } else if (current == 3) {
      if (selectedZones.isEmpty) {
        _safeShowSnackbar('Zones Required', 'Please select at least one operating delivery zone');
        return;
      }
    } else if (current == 4) {
      if (!validatePayoutMethod()) {
        return;
      }
    }

    if (onboardingStep.value < 4) {
      onboardingStep.value++;
    } else {
      submitFullOnboarding();
    }
  }

  void prevOnboardingStep() {
    if (onboardingStep.value > 0) {
      onboardingStep.value--;
    } else {
      Get.back();
    }
  }

  Future<void> submitFullOnboarding() async {
    if (!validatePayoutMethod()) {
      return;
    }

    isLoading.value = true;

    // Vehicle Type per API doc: "2_WHEELER", "3_WHEELER", "4_WHEELER", "BICYCLE"
    String mappedVehicleType = vehicleType.value;
    if (mappedVehicleType.contains('3-Wheeler') || mappedVehicleType == '3_WHEELER') {
      mappedVehicleType = '3_WHEELER';
    } else if (mappedVehicleType.contains('4-Wheeler') || mappedVehicleType == '4_WHEELER') {
      mappedVehicleType = '4_WHEELER';
    } else if (mappedVehicleType.contains('Bicycle') || mappedVehicleType == 'BICYCLE') {
      mappedVehicleType = 'BICYCLE';
    } else if (mappedVehicleType.contains('2-Wheeler') || mappedVehicleType == '2_WHEELER') {
      mappedVehicleType = '2_WHEELER';
    } else if (mappedVehicleType.isNotEmpty) {
      mappedVehicleType = mappedVehicleType;
    } else {
      mappedVehicleType = '2_WHEELER';
    }

    final dlNo = drivingLicenseNoController.text.trim();

    // Extract country code and phone
    String rawPhone = onboardingPhoneController.text.trim();
    String phoneCountryCode = '+232';
    String phoneNumber = rawPhone;
    if (rawPhone.startsWith('+232')) {
      phoneCountryCode = '+232';
      phoneNumber = rawPhone.substring(4);
    } else if (rawPhone.startsWith('+')) {
      final match = RegExp(r'^(\+\d{1,4})(.*)$').firstMatch(rawPhone);
      if (match != null) {
        phoneCountryCode = match.group(1)!;
        phoneNumber = match.group(2)!;
      }
    }

    final locationsToSubmit = <String>[...selectedLocations];
    if (locationsToSubmit.isEmpty) {
      for (final zId in selectedZones) {
        final matchedZone = operatingZonesList.firstWhereOrNull((z) => z.id == zId);
        if (matchedZone != null) {
          locationsToSubmit.addAll(matchedZone.locations.map((l) => l.name));
        }
      }
    }

    final hasBankDetails = bankNameController.text.trim().isNotEmpty ||
        accountNumberController.text.trim().isNotEmpty;
    final mobilePhone = mobileNumberController.text.trim().isNotEmpty
        ? mobileNumberController.text.trim()
        : mobileMoneyNumberController.text.trim();
    final hasMobileMoneyDetails = mobilePhone.isNotEmpty;

    final selectedOpt = selectedPaymentOption.value;
    final Map<String, dynamic>? payoutData = selectedOpt == PaymentOption.bank
        ? (hasBankDetails
            ? {
                'paymentOption': 'Bank',
                'preferredPayoutMethod': 'Bank Transfer',
                'bankName': bankNameController.text.trim(),
                'bankAddress': bankAddressController.text.trim(),
                'accountHolderName': accountHolderController.text.trim().isNotEmpty
                    ? accountHolderController.text.trim()
                    : fullNameController.text.trim(),
                'accountNumber': accountNumberController.text.trim(),
                'bbanNumber': bbanNumberController.text.trim().isNotEmpty
                    ? bbanNumberController.text.trim()
                    : routingNumberController.text.trim(),
                'branchName': branchNameController.text.trim(),
                // Backward compatibility keys
                'methodType': 'bank',
                'accountHolder': accountHolderController.text.trim().isNotEmpty
                    ? accountHolderController.text.trim()
                    : fullNameController.text.trim(),
                'routingNumber': bbanNumberController.text.trim().isNotEmpty
                    ? bbanNumberController.text.trim()
                    : routingNumberController.text.trim(),
              }
            : null)
        : (hasMobileMoneyDetails
            ? {
                'paymentOption': selectedOpt.apiValue,
                'preferredPayoutMethod': 'Mobile Wallet',
                'mobileMoneyOption': selectedOpt.apiValue,
                'mobileNumber': mobilePhone,
                'agentNumber': agentNumberController.text.trim(),
                // Backward compatibility keys
                'methodType': 'mobile_money',
                'provider': selectedOpt.apiValue,
                'phone': mobilePhone,
                'accountHolder': beneficiaryNameController.text.trim().isNotEmpty
                    ? beneficiaryNameController.text.trim()
                    : fullNameController.text.trim(),
              }
            : null);

    final addressData = {
      'street': '14 Lumley Beach Rd',
      'city': 'Freetown',
      'state': 'Western Area',
      'postalCode': '00232',
    };

    final emergencyContactData = {
      'name': 'Fatima Koroma',
      'relationship': 'Family Contact',
      'phone': rawPhone.isNotEmpty ? rawPhone : '+23278999888',
    };

    final compProfile = profilePhotoPath.value.isNotEmpty
        ? await ImageCompressor.compressImage(profilePhotoPath.value, maxWidth: 800, maxHeight: 800, quality: 70)
        : null;
    final compDl = driverLicensePath.value.isNotEmpty
        ? await ImageCompressor.compressImage(driverLicensePath.value, maxWidth: 1200, maxHeight: 1200, quality: 70)
        : null;
    final compId = nationalIdFrontPath.value.isNotEmpty
        ? await ImageCompressor.compressImage(nationalIdFrontPath.value, maxWidth: 1200, maxHeight: 1200, quality: 70)
        : null;
    final compIdBack = nationalIdBackPath.value.isNotEmpty
        ? await ImageCompressor.compressImage(nationalIdBackPath.value, maxWidth: 1200, maxHeight: 1200, quality: 70)
        : null;
    final compInsurance = vehicleInsurancePath.value.isNotEmpty
        ? await ImageCompressor.compressImage(vehicleInsurancePath.value, maxWidth: 1200, maxHeight: 1200, quality: 70)
        : null;

    final result = await submitOnboardingUseCase(
      name: fullNameController.text.trim().isNotEmpty ? fullNameController.text.trim() : null,
      phone: phoneNumber.isNotEmpty ? phoneNumber : null,
      phoneCountryCode: phoneCountryCode,
      vehicleType: mappedVehicleType,
      vehicleTypes: [mappedVehicleType],
      vehicleName: vehicleModelController.text.trim().isNotEmpty ? vehicleModelController.text.trim() : null,
      vehicleNumber: licensePlateController.text.trim().isNotEmpty ? licensePlateController.text.trim() : null,
      drivingLicenseNo: dlNo.isNotEmpty ? dlNo : null,
      selectedZones: selectedZones.toList(),
      selectedLocations: locationsToSubmit,
      address: addressData,
      emergencyContact: emergencyContactData,
      payoutInfo: payoutData,
      profileImagePath: compProfile,
      drivingLicenseDocPath: compDl,
      nationalIdDocPath: compId,
      nationalIdPath: compIdBack,
      vehicleInsuranceDocPath: compInsurance,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Onboarding Submission Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (rider) {
        if (!rider.isApproved || rider.status.toUpperCase() == 'PENDING') {
          Get.snackbar(
            '🎉 Onboarding Submitted!',
            'Rider onboarding submitted successfully! Your account status is PENDING review.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFFFBEB),
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(AppRoutes.pendingApproval);
        } else {
          Get.snackbar(
            '🎉 Onboarding Completed!',
            'Rider onboarding submitted successfully! Your account status is ${rider.status}.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(AppRoutes.main);
        }
      },
    );
  }
}
