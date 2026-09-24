import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/constants/app_strings.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
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
import 'package:meeem_rider/presentation/modules/auth/views/forgot_password_view.dart';
import 'package:meeem_rider/presentation/modules/auth/views/reset_password_view.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late AuthController controller;
  late MockAuthRepository mockRepo;
  late MockDeviceInfoService mockDeviceInfo;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (key == 'AssetManifest.bin' || key == 'AssetManifest.bin.json') {
        final manifest = <String, List<Object?>>{
          'google_fonts/Inter-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Regular.ttf'}
          ],
          'google_fonts/Inter-Medium.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Medium.ttf'}
          ],
          'google_fonts/Inter-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-SemiBold.ttf'}
          ],
          'google_fonts/Inter-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Bold.ttf'}
          ],
          'google_fonts/Poppins-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Regular.ttf'}
          ],
          'google_fonts/Poppins-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-SemiBold.ttf'}
          ],
          'google_fonts/Poppins-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Bold.ttf'}
          ],
        };
        return const StandardMessageCodec().encodeMessage(manifest);
      }
      if (key == 'AssetManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
      }
      if (key == 'FontManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
      }
      if (key.endsWith('.ttf')) {
        return ByteData.view(Uint8List.fromList(_fontBytes).buffer);
      }
      return null;
    });

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

  Widget createTestWidget(Widget child) {
    return GetMaterialApp(
      home: child,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login View'))),
        GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
        GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordView()),
      ],
    );
  }

  group('ForgotPasswordView (Screen 1)', () {
    testWidgets('renders all expected UI elements according to API doc', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ForgotPasswordView()));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password'), findsWidgets);
      expect(find.text('Enter your registered email address or phone number to receive a 6-digit password reset code.'), findsOneWidget);
      expect(find.text('Email or Mobile Number'), findsOneWidget);
      expect(find.text(AppStrings.send6DigitOtp), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('allows entering identifier in text field', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ForgotPasswordView()));
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextFormField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'rider@example.com');
      expect(controller.resetIdentityController.text, 'rider@example.com');
    });
  });

  group('ResetPasswordView (Screen 2)', () {
    testWidgets('renders all input fields, timers, and buttons according to API doc', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      controller.resetMaskedDestination.value = 'rider@example.com & +23276123456';
      controller.resetEmail.value = 'rider@example.com';
      controller.resetPhone.value = '+23276123456';
      controller.resendTimerSeconds.value = 45;
      controller.canResendOtp.value = false;

      await tester.pumpWidget(createTestWidget(const ResetPasswordView()));
      await tester.pumpAndSettle();

      expect(find.text('Create New Password'), findsOneWidget);
      expect(find.text('rider@example.com'), findsOneWidget);
      expect(find.text('+23276123456'), findsOneWidget);
      expect(find.text('6-Digit Verification Code'), findsOneWidget);
      expect(find.text(AppStrings.newPassword), findsOneWidget);
      expect(find.text(AppStrings.confirmPassword), findsOneWidget);
      expect(find.text('Resend code in 45s'), findsOneWidget);
      expect(find.text(AppStrings.resetPasswordAndSignIn), findsOneWidget);
      expect(find.text('Change Email or Phone Number'), findsOneWidget);
    });

    testWidgets('shows Resend OTP button when cooldown timer expires', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      controller.canResendOtp.value = true;

      await tester.pumpWidget(createTestWidget(const ResetPasswordView()));
      await tester.pumpAndSettle();

      expect(find.text('Resend OTP'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsNothing);
    });

    testWidgets('toggles visibility for new and confirm passwords', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const ResetPasswordView()));
      await tester.pumpAndSettle();

      expect(controller.isNewPasswordVisible.value, isFalse);
      expect(controller.isConfirmPasswordVisible.value, isFalse);

      final eyeIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(eyeIcons, findsNWidgets(2));

      // Tap first eye toggle (new password)
      await tester.tap(eyeIcons.at(0));
      await tester.pumpAndSettle();
      expect(controller.isNewPasswordVisible.value, isTrue);

      // Tap second eye toggle (confirm password)
      final secondEye = find.byIcon(Icons.visibility_off_outlined);
      expect(secondEye, findsOneWidget);
      await tester.tap(secondEye);
      await tester.pumpAndSettle();
      expect(controller.isConfirmPasswordVisible.value, isTrue);
    });
  });
}
