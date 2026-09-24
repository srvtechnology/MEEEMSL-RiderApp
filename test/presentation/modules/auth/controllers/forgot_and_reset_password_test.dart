import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/domain/entities/reset_password_result_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/login_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_email_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/register_rider_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/resend_2fa_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/resend_registration_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/reset_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/self_register_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/send_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/submit_onboarding_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_2fa_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_registration_otp_usecase.dart';
import 'package:meeem_rider/presentation/modules/auth/controllers/auth_controller.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;
  late MockAuthRepository mockRepo;
  late MockDeviceInfoService mockDeviceInfo;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
  });

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
    mockRepo = MockAuthRepository();
    mockDeviceInfo = MockDeviceInfoService();
    when(() => mockDeviceInfo.getUserAgent()).thenAnswer((_) async => 'MeeemRiderApp/1.0');

    controller = AuthController(
      loginUseCase: LoginUseCase(mockRepo),
      loginWithPasswordUseCase: LoginWithPasswordUseCase(mockRepo),
      loginWithEmailPasswordUseCase: LoginWithEmailPasswordUseCase(mockRepo),
      sendPhoneOtpUseCase: SendPhoneOtpUseCase(mockRepo),
      verifyPhoneOtpUseCase: VerifyPhoneOtpUseCase(mockRepo),
      verifyOtpUseCase: VerifyOtpUseCase(mockRepo),
      registerRiderUseCase: RegisterRiderUseCase(mockRepo),
      submitOnboardingUseCase: SubmitOnboardingUseCase(mockRepo),
      selfRegisterUseCase: SelfRegisterUseCase(mockRepo),
      verifyRegistrationOtpUseCase: VerifyRegistrationOtpUseCase(mockRepo),
      resendRegistrationOtpUseCase: ResendRegistrationOtpUseCase(mockRepo),
      resetPasswordUseCase: ResetPasswordUseCase(mockRepo),
      deviceInfoService: mockDeviceInfo,
      verify2faOtpUseCase: Verify2faOtpUseCase(mockRepo),
      resend2faOtpUseCase: Resend2faOtpUseCase(mockRepo),
    );
    Get.put<AuthController>(controller);
  });

  tearDown(() {
    controller.cancelResendTimer();
    controller.cancelTwoFactorExpiryTimer();
    Get.reset();
  });

  Widget buildTestApp(Widget child) {
    return GetMaterialApp(
      home: child,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login'))),
        GetPage(name: AppRoutes.forgotPassword, page: () => const Scaffold(body: Text('Forgot Password'))),
        GetPage(name: AppRoutes.resetPassword, page: () => const Scaffold(body: Text('Reset Password'))),
      ],
    );
  }

  Future<void> settleTest(WidgetTester tester) async {
    controller.cancelResendTimer();
    controller.cancelTwoFactorExpiryTimer();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('Password Visibility Toggles', () {
    test('toggleNewPasswordVisibility and toggleConfirmPasswordVisibility change values', () {
      expect(controller.isNewPasswordVisible.value, isFalse);
      controller.toggleNewPasswordVisibility();
      expect(controller.isNewPasswordVisible.value, isTrue);

      expect(controller.isConfirmPasswordVisible.value, isFalse);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible.value, isTrue);
    });
  });

  group('sendResetCode', () {
    testWidgets('does not call repository if identity input is empty', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.resetIdentityController.text = '   ';
      await controller.sendResetCode();
      verifyNever(() => mockRepo.forgotPassword(any(), any()));
      expect(controller.isResetCodeSent.value, isFalse);
      await settleTest(tester);
    });

    testWidgets('calls repository with email and parses response with cooldown timer', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));

      const tResult = SendResetOtpResultEntity(
        identity: 'rider@example.com',
        identityType: 'EMAIL',
        maskedDestination: 'rider@example.com & +23276123456',
        email: 'rider@example.com',
        phone: '+23276123456',
        expiresIn: 600,
        resendCooldown: 60,
      );

      when(() => mockRepo.forgotPassword('rider@example.com', null))
          .thenAnswer((_) async => const Right(tResult));

      controller.resetIdentityController.text = 'rider@example.com';
      await controller.sendResetCode();

      verify(() => mockRepo.forgotPassword('rider@example.com', null)).called(1);
      expect(controller.isResetCodeSent.value, isTrue);
      expect(controller.resetMaskedDestination.value, 'rider@example.com & +23276123456');
      expect(controller.resetEmail.value, 'rider@example.com');
      expect(controller.resetPhone.value, '+23276123456');
      expect(controller.resendTimerSeconds.value, inInclusiveRange(58, 60));
      expect(controller.canResendOtp.value, isFalse);
      await settleTest(tester);
    });

    testWidgets('starts cooldown timer on RateLimitFailure', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));

      when(() => mockRepo.forgotPassword(any(), any()))
          .thenAnswer((_) async => const Left(RateLimitFailure(
                message: 'Please wait 45 seconds before requesting another OTP.',
                cooldownSeconds: 45,
              )));

      controller.resetIdentityController.text = '+23276123456';
      await controller.sendResetCode();

      expect(controller.resendTimerSeconds.value, inInclusiveRange(43, 45));
      expect(controller.canResendOtp.value, isFalse);
      await settleTest(tester);
    });
  });

  group('resendResetOtp', () {
    testWidgets('does not trigger sendResetCode if canResendOtp is false', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.canResendOtp.value = false;
      controller.resetIdentityController.text = 'rider@example.com';

      await controller.resendResetOtp();
      verifyNever(() => mockRepo.forgotPassword(any(), any()));
      await settleTest(tester);
    });

    testWidgets('triggers sendResetCode when canResendOtp is true', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.canResendOtp.value = true;
      controller.resetIdentityController.text = 'rider@example.com';

      const tResult = SendResetOtpResultEntity(
        identity: 'rider@example.com',
        identityType: 'EMAIL',
        maskedDestination: 'rider@example.com',
        resendCooldown: 60,
      );
      when(() => mockRepo.forgotPassword('rider@example.com', null))
          .thenAnswer((_) async => const Right(tResult));

      await controller.resendResetOtp();
      verify(() => mockRepo.forgotPassword('rider@example.com', null)).called(1);
      await settleTest(tester);
    });
  });

  group('confirmPasswordReset', () {
    testWidgets('validates missing identity', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.resetIdentityController.text = '';
      await controller.confirmPasswordReset();
      verifyNever(() => mockRepo.resetPassword(any(), any(), any(), any()));
      await settleTest(tester);
    });

    testWidgets('validates invalid OTP (not 6 digits)', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.resetIdentityController.text = 'rider@example.com';
      controller.resetOtpController.text = '123';
      await controller.confirmPasswordReset();
      verifyNever(() => mockRepo.resetPassword(any(), any(), any(), any()));
      await settleTest(tester);
    });

    testWidgets('validates short password (< 6 chars)', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.resetIdentityController.text = 'rider@example.com';
      controller.resetOtpController.text = '123456';
      controller.newPasswordController.text = '123';
      controller.confirmPasswordController.text = '123';
      await controller.confirmPasswordReset();
      verifyNever(() => mockRepo.resetPassword(any(), any(), any(), any()));
      await settleTest(tester);
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));
      controller.resetIdentityController.text = 'rider@example.com';
      controller.resetOtpController.text = '123456';
      controller.newPasswordController.text = 'newPass123';
      controller.confirmPasswordController.text = 'differentPass';
      await controller.confirmPasswordReset();
      verifyNever(() => mockRepo.resetPassword(any(), any(), any(), any()));
      await settleTest(tester);
    });

    testWidgets('successfully resets password, clears fields, and resets state', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));

      controller.resetIdentityController.text = 'rider@example.com';
      controller.resetOtpController.text = '123456';
      controller.newPasswordController.text = 'newSecurePassword';
      controller.confirmPasswordController.text = 'newSecurePassword';
      controller.isResetCodeSent.value = true;

      when(() => mockRepo.resetPassword('rider@example.com', '123456', 'newSecurePassword', null))
          .thenAnswer((_) async => const Right(true));

      await controller.confirmPasswordReset();

      verify(() => mockRepo.resetPassword('rider@example.com', '123456', 'newSecurePassword', null)).called(1);
      expect(controller.resetOtpController.text, isEmpty);
      expect(controller.newPasswordController.text, isEmpty);
      expect(controller.confirmPasswordController.text, isEmpty);
      expect(controller.isResetCodeSent.value, isFalse);
      await settleTest(tester);
    });

    testWidgets('handles RateLimitFailure gracefully', (tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold()));

      controller.resetIdentityController.text = 'rider@example.com';
      controller.resetOtpController.text = '123456';
      controller.newPasswordController.text = 'newSecurePassword';
      controller.confirmPasswordController.text = 'newSecurePassword';

      when(() => mockRepo.resetPassword('rider@example.com', '123456', 'newSecurePassword', null))
          .thenAnswer((_) async => const Left(RateLimitFailure(
                message: 'Too many failed attempts. Try again in 15 minute(s).',
                cooldownSeconds: 900,
              )));

      await controller.confirmPasswordReset();

      verify(() => mockRepo.resetPassword('rider@example.com', '123456', 'newSecurePassword', null)).called(1);
      await settleTest(tester);
    });
  });
}
