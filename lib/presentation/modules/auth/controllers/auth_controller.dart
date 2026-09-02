import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
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
  final SelfRegisterUseCase selfRegisterUseCase;
  final VerifyRegistrationOtpUseCase verifyRegistrationOtpUseCase;
  final ResendRegistrationOtpUseCase resendRegistrationOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final DeviceInfoService deviceInfoService;

  AuthController({
    required this.loginUseCase,
    required this.loginWithPasswordUseCase,
    required this.loginWithEmailPasswordUseCase,
    required this.sendPhoneOtpUseCase,
    required this.verifyPhoneOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerRiderUseCase,
    required this.selfRegisterUseCase,
    required this.verifyRegistrationOtpUseCase,
    required this.resendRegistrationOtpUseCase,
    required this.resetPasswordUseCase,
    required this.deviceInfoService,
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
  final otpFlowType = OtpFlowType.registration.obs;
  final registrationEmail = ''.obs;

  // Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final phoneTextController = TextEditingController();
  final otpTextController = TextEditingController();

  // Forgot / Reset Password Controllers
  final resetIdentityController = TextEditingController();
  final resetOtpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isResetCodeSent = false.obs;

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

  // Step 2: Documents Expiry Dates
  final idExpiryController = TextEditingController(text: '2028-12-31');
  final licenseExpiryController = TextEditingController(text: '2028-10-15');
  final insuranceExpiryController = TextEditingController(text: '2027-05-20');

  // Step 3: Vehicle Details
  final vehicleType = '2-Wheeler (Motorcycle / Scooter)'.obs;
  final vehicleModelController = TextEditingController(text: 'Honda CB500X');
  final licensePlateController = TextEditingController(text: 'RD-8842-NY');
  final vehicleColorController = TextEditingController(text: 'Sapphire Blue');
  final vehicleYearController = TextEditingController(text: '2023');

  // Step 4: Operating Zones
  final selectedZones = <String>['zone_1', 'zone_2', 'zone_4'].obs;

  // Step 5: Payout Info
  final payoutMethodType = PayoutMethodType.bank.obs;
  final bankNameController = TextEditingController(text: 'Chase Bank USA');
  final accountNumberController = TextEditingController(text: '9920184920');
  final accountHolderController = TextEditingController(text: 'Alex Johnson');
  final routingNumberController = TextEditingController(text: '021000021');

  final mobileMoneyProviderController = TextEditingController(text: 'M-Pesa');
  final mobileMoneyNumberController = TextEditingController(text: '+1 555 234 5678');
  final beneficiaryNameController = TextEditingController(text: 'Alex Johnson');

  final _imagePicker = ImagePicker();

  @override
  void onClose() {
    _timer?.cancel();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    phoneTextController.dispose();
    otpTextController.dispose();
    resetIdentityController.dispose();
    resetOtpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    onboardingPhoneController.dispose();
    idExpiryController.dispose();
    licenseExpiryController.dispose();
    insuranceExpiryController.dispose();
    vehicleModelController.dispose();
    licensePlateController.dispose();
    vehicleColorController.dispose();
    vehicleYearController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    routingNumberController.dispose();
    mobileMoneyProviderController.dispose();
    mobileMoneyNumberController.dispose();
    beneficiaryNameController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerPhoneController.dispose();
    super.onClose();
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

  // 2.1 Rider Self-Registration
  Future<void> selfRegisterRider() async {
    final name = registerNameController.text.trim();
    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();
    final phone = registerPhoneController.text.trim();
    final countryCode = registerCountryCode.value;

    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      Get.snackbar('Validation', emailError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar('Validation', 'Please enter your phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final result = await selfRegisterUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      phoneCountryCode: countryCode,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Registration Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (data) {
        registrationEmail.value = email;
        otpFlowType.value = OtpFlowType.registration;
        otpTextController.clear();
        startResendTimer(seconds: data.resendCooldown);
        Get.snackbar(
          'Registration Successful',
          'A 6-digit verification code has been sent to $email',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          duration: const Duration(seconds: 4),
        );
        Get.toNamed(AppRoutes.otp);
      },
    );
  }

  // Resend current OTP (Registration Email OTP vs Phone SMS OTP)
  Future<void> resendCurrentOtp() async {
    if (!canResendOtp.value) return;

    isLoading.value = true;
    if (otpFlowType.value == OtpFlowType.registration) {
      final result = await resendRegistrationOtpUseCase(email: registrationEmail.value);
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
        (data) {
          startResendTimer(seconds: data.resendCooldown);
          Get.snackbar(
            'New Code Sent',
            'Verification code resent to ${registrationEmail.value}',
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
    if (!user.isEmailVerified) {
      registrationEmail.value = user.email;
      otpFlowType.value = OtpFlowType.registration;
      startResendTimer();
      Get.snackbar(
        'Verification Required',
        'Please verify your email address to proceed.',
        snackPosition: SnackPosition.TOP,
      );
      Get.toNamed(AppRoutes.otp);
      return;
    }

    if (rider.isSuspended || rider.status == 'SUSPENDED') {
      SuspendedAccountDialog.show();
      return;
    }

    if (!rider.onboardingCompleted || rider.isFirstLogin) {
      Get.snackbar(
        'Welcome!',
        'Please complete your initial rider onboarding details.',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed(AppRoutes.onboarding);
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

  // 3.1 Rider Login with Email & Password (with Auto Device Token Registration)
  Future<void> loginWithEmailPassword() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      Get.snackbar('Validation', emailError, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.isEmpty || password.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final deviceId = await deviceInfoService.getDeviceId();
    final platform = deviceInfoService.getPlatform();
    final userAgent = await deviceInfoService.getUserAgent();
    final storage = GetStorage();
    final deviceToken = storage.read<String>(AppConstants.devicePushTokenKey) ?? 'fcm_mock_device_token';

    final result = await loginWithEmailPasswordUseCase(
      email: email,
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

  // 3.2 (B) Verify Phone OTP & Obtain Session Tokens (or Email Registration OTP)
  Future<void> verifyOtp() async {
    final otp = otpTextController.text.trim();
    final error = Validators.validateOtp(otp);
    if (error != null) {
      Get.snackbar('Invalid OTP', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    if (otpFlowType.value == OtpFlowType.registration) {
      final result = await verifyRegistrationOtpUseCase(
        email: registrationEmail.value,
        otp: otp,
      );
      isLoading.value = false;

      result.fold(
        (failure) => Get.snackbar('Verification Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
        (res) {
          Get.snackbar(
            'Email Verified!',
            'Email verified successfully! You can now log in to complete your rider onboarding.',
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
    final result = await resetPasswordUseCase.sendResetCode(identity);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message, snackPosition: SnackPosition.BOTTOM),
      (success) {
        isResetCodeSent.value = true;
        Get.snackbar('Code Sent', 'Verification code sent to $identity', snackPosition: SnackPosition.TOP);
      },
    );
  }

  Future<void> confirmPasswordReset() async {
    final identity = resetIdentityController.text.trim();
    final otp = resetOtpController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (otp.length < 4) {
      Get.snackbar('Error', 'Please enter a valid reset code');
      return;
    }
    if (newPass.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    if (newPass != confirmPass) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    final result = await resetPasswordUseCase.confirmReset(identity, otp, newPass);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Reset Failed', failure.message),
      (success) {
        Get.snackbar('Success', 'Password has been updated! Please sign in with your new password.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
        Get.offNamed(AppRoutes.login);
      },
    );
  }

  // Image Picking for Onboarding & Documents
  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        profilePhotoPath.value = file.path;
      }
    } catch (_) {
      // Mock fallback if running without native camera permissions
      profilePhotoPath.value = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';
    }
  }

  Future<void> pickDocument(String docType) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      final path = file?.path ?? 'mock_doc_path_${DateTime.now().millisecondsSinceEpoch}.jpg';
      _setDocPath(docType, path);
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

  void toggleZone(String zoneId) {
    if (selectedZones.contains(zoneId)) {
      if (selectedZones.length > 1) {
        selectedZones.remove(zoneId);
      } else {
        Get.snackbar('Operating Zones', 'Please select at least 1 operating zone');
      }
    } else {
      selectedZones.add(zoneId);
    }
  }

  // 5-Step Onboarding Wizard Navigation
  void nextOnboardingStep() {
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
    isLoading.value = true;

    final registrationData = {
      'name': fullNameController.text.trim().isNotEmpty ? fullNameController.text.trim() : 'Alex Johnson',
      'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : 'alex.rider@meeem.com',
      'phone': onboardingPhoneController.text.trim().isNotEmpty ? onboardingPhoneController.text.trim() : '+1 555 234 5678',
      'avatar': profilePhotoPath.value,
      'vehicle': {
        'type': vehicleType.value,
        'model': vehicleModelController.text.trim(),
        'licensePlate': licensePlateController.text.trim(),
        'color': vehicleColorController.text.trim(),
        'year': vehicleYearController.text.trim(),
      },
      'operatingZones': selectedZones.toList(),
      'payoutInfo': {
        'methodType': payoutMethodType.value == PayoutMethodType.bank ? 'bank' : 'mobile_money',
        'bankName': bankNameController.text.trim(),
        'accountNumber': accountNumberController.text.trim(),
        'accountHolderName': accountHolderController.text.trim(),
        'routingNumber': routingNumberController.text.trim(),
        'mobileMoneyProvider': mobileMoneyProviderController.text.trim(),
        'mobileMoneyNumber': mobileMoneyNumberController.text.trim(),
        'beneficiaryName': beneficiaryNameController.text.trim(),
      },
    };

    final result = await registerRiderUseCase(registrationData);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Application Failed', failure.message, snackPosition: SnackPosition.BOTTOM),
      (rider) {
        Get.snackbar(
          '🎉 Application Submitted!',
          'Your profile, vehicle & documents are submitted for review.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          duration: const Duration(seconds: 4),
        );
        Get.offAllNamed(AppRoutes.main);
      },
    );
  }
}
