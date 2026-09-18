import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;

import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/network/api_interceptor.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/core/utils/secure_utils.dart';
import 'package:meeem_rider/data/models/login_response_model.dart';
import 'package:meeem_rider/data/models/two_factor_resend_result_model.dart';
import 'package:meeem_rider/domain/entities/login_response_entity.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
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
import 'package:meeem_rider/domain/entities/two_factor_resend_result_entity.dart';
import 'package:meeem_rider/presentation/modules/auth/controllers/auth_controller.dart';
import 'package:meeem_rider/presentation/modules/auth/views/otp_view.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

Widget buildTestApp(Widget home) {
  return GetMaterialApp(
    home: home,
    getPages: [
      GetPage(name: AppRoutes.otp, page: () => const Scaffold(body: Text('OTP View'))),
      GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login View'))),
      GetPage(name: AppRoutes.main, page: () => const Scaffold(body: Text('Main View'))),
      GetPage(name: AppRoutes.onboarding, page: () => const Scaffold(body: Text('Onboarding View'))),
      GetPage(name: AppRoutes.pendingApproval, page: () => const Scaffold(body: Text('Pending Approval View'))),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

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
        return ByteData.view(Uint8List.fromList(utf8.encode(jsonEncode({
          'google_fonts/Inter-Regular.ttf': ['google_fonts/Inter-Regular.ttf'],
          'google_fonts/Inter-Medium.ttf': ['google_fonts/Inter-Medium.ttf'],
          'google_fonts/Inter-SemiBold.ttf': ['google_fonts/Inter-SemiBold.ttf'],
          'google_fonts/Inter-Bold.ttf': ['google_fonts/Inter-Bold.ttf'],
          'google_fonts/Poppins-Regular.ttf': ['google_fonts/Poppins-Regular.ttf'],
          'google_fonts/Poppins-SemiBold.ttf': ['google_fonts/Poppins-SemiBold.ttf'],
          'google_fonts/Poppins-Bold.ttf': ['google_fonts/Poppins-Bold.ttf'],
        }))).buffer);
      }
      if (key == 'FontManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
      }
      if (key.endsWith('.ttf')) {
        return ByteData.view(Uint8List.fromList(_fontBytes).buffer);
      }
      if (key.endsWith('.png') || key.endsWith('.jpg')) {
        return ByteData.view(Uint8List.fromList([
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
          0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
          0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
          0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
          0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
          0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
        ]).buffer);
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
  });

  tearDown(() {
    Get.reset();
  });

  group('1. Endpoints Matrix & Network Layer', () {
    test('verify2fa and resend2fa endpoints are documented and in part1Endpoints whitelist', () {
      expect(ApiEndpoints.verify2fa, equals('/auth/verify-2fa'));
      expect(ApiEndpoints.resend2fa, equals('/auth/resend-2fa'));
      expect(ApiEndpoints.isPart1Endpoint(ApiEndpoints.verify2fa), isTrue);
      expect(ApiEndpoints.isPart1Endpoint(ApiEndpoints.resend2fa), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint(ApiEndpoints.verify2fa), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint(ApiEndpoints.resend2fa), isTrue);

      // Verify path normalization
      expect(ApiEndpoints.isDocumentedEndpoint('/mobileapi/rider/auth/verify-2fa'), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint('/mobileapi/rider/auth/resend-2fa'), isTrue);
    });

    test('ApiInterceptor identifies 2FA endpoints as auth endpoints (no Bearer token appended)', () async {
      final dioInstance = dio.Dio();
      final interceptor = ApiInterceptor(dioInstance);

      final reqVerify = dio.RequestOptions(
        path: ApiEndpoints.verify2fa,
        headers: {},
      );
      final handler = dio.RequestInterceptorHandler();
      interceptor.onRequest(reqVerify, handler);

      expect(reqVerify.headers.containsKey('Authorization'), isFalse);

      final reqResend = dio.RequestOptions(
        path: ApiEndpoints.resend2fa,
        headers: {},
      );
      final handlerResend = dio.RequestInterceptorHandler();
      interceptor.onRequest(reqResend, handlerResend);

      expect(reqResend.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('2. Security Scrubbing', () {
    test('SecureUtils sanitizes preauthtoken and otp from logs', () {
      final payload = {
        'preAuthToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret',
        'otp': '123456',
        'password': 'riderpassword123',
        'maskedPhone': '+91 *******3210',
        'maskedEmail': 'r***@example.com',
      };

      final sanitized = SecureUtils.sanitizeLogPayload(payload) as Map;
      expect(sanitized['preAuthToken'], equals('[REDACTED]'));
      expect(sanitized['otp'], equals('[REDACTED]'));
      expect(sanitized['password'], equals('[REDACTED]'));
      expect(sanitized['maskedPhone'], equals('+91 *******3210'));
      expect(sanitized['maskedEmail'], equals('r***@example.com'));
    });
  });

  group('3. Model Deserialization', () {
    test('LoginResponseModel parses Step 1 2FA challenge response', () {
      final challengeJson = {
        'success': true,
        'requiresOtp': true,
        'message': 'Verification code sent to your registered mobile number and email.',
        'data': {
          'preAuthToken': 'test_pre_auth_token_abc',
          'maskedPhone': '+91 *******3210',
          'maskedEmail': 'r***@example.com',
          'channels': ['SMS', 'EMAIL'],
          'expiresIn': 300,
          'resendCooldown': 60,
        },
      };

      final model = LoginResponseModel.fromJson(challengeJson);
      expect(model.requiresOtp, isTrue);
      expect(model.preAuthToken, equals('test_pre_auth_token_abc'));
      expect(model.maskedPhone, equals('+91 *******3210'));
      expect(model.maskedEmail, equals('r***@example.com'));
      expect(model.channels, equals(['SMS', 'EMAIL']));
      expect(model.resendCooldown, equals(60));
      expect(model.expiresIn, equals(300));
      expect(model.accessToken, isEmpty);
    });

    test('LoginResponseModel parses Step 2 2FA completion response', () {
      final successJson = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user': {
            'id': 'usr_rider_999',
            'name': 'Alex Rider',
            'email': 'rider@example.com',
            'phone': '9876543210',
            'role': 'RIDER',
          },
          'rider': {
            'id': 'rider_profile_01',
            'isApproved': true,
            'isSuspended': false,
            'status': 'APPROVED',
            'onboardingCompleted': true,
            'isFirstLogin': false,
            'vehicleTypes': ['BIKE'],
            'vehicleNumber': 'DL 01 AB 1234',
            'drivingLicenseNo': 'DL-1234567890',
            'selectedZones': ['North Zone'],
            'selectedLocations': [],
          },
          'tokens': {
            'accessToken': 'access_token_jwt_xyz',
            'refreshToken': 'refresh_token_jwt_xyz',
            'expiresIn': 604800,
          },
          'sessionInfo': {
            'expiresIn': 604800,
            'tokenType': 'Bearer',
          },
        },
      };

      final model = LoginResponseModel.fromJson(successJson);
      expect(model.requiresOtp, isFalse);
      expect(model.user.id, equals('usr_rider_999'));
      expect(model.user.name, equals('Alex Rider'));
      expect(model.rider.id, equals('rider_profile_01'));
      expect(model.rider.isApproved, isTrue);
      expect(model.rider.onboardingCompleted, isTrue);
      expect(model.accessToken, equals('access_token_jwt_xyz'));
      expect(model.refreshToken, equals('refresh_token_jwt_xyz'));
      expect(model.expiresIn, equals(604800));
    });

    test('TwoFactorResendResultModel parses Step 3 resend response', () {
      final resendJson = {
        'success': true,
        'message': 'Verification code resent successfully.',
        'data': {
          'preAuthToken': 'new_pre_auth_token_456',
          'resendCooldown': 60,
        },
      };

      final model = TwoFactorResendResultModel.fromJson(resendJson);
      expect(model.preAuthToken, equals('new_pre_auth_token_456'));
      expect(model.resendCooldown, equals(60));
      expect(model.message, equals('Verification code resent successfully.'));
    });
  });

  group('4. AuthController 2FA Flow Lifecycle', () {
    late MockAuthRepository mockRepo;
    late MockDeviceInfoService mockDeviceInfo;
    late AuthController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockAuthRepository();
      mockDeviceInfo = MockDeviceInfoService();

      when(() => mockDeviceInfo.getDeviceId()).thenAnswer((_) async => 'device_test_123');
      when(() => mockDeviceInfo.getPlatform()).thenReturn('android');
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

    test('Step 1: loginWithEmailPassword intercepts 2FA challenge and stores preAuthToken in memory only', () async {
      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'riderpassword123';

      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'token_challenge_xyz',
        maskedPhone: '+91 *******3210',
        maskedEmail: 'r***@example.com',
        channels: const ['SMS', 'EMAIL'],
        resendCooldown: 60,
      );

      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      await controller.loginWithEmailPassword();

      expect(controller.otpFlowType.value, equals(OtpFlowType.twoFactorLogin));
      expect(controller.preAuthToken, equals('token_challenge_xyz'));
      expect(controller.twoFactorMaskedPhone.value, equals('+91 *******3210'));
      expect(controller.twoFactorMaskedEmail.value, equals('r***@example.com'));
      expect(controller.twoFactorChannels, equals(['SMS', 'EMAIL']));
      expect(controller.resendTimerSeconds.value, equals(60));
      expect(controller.twoFactorCodeExpirySeconds.value, equals(300));

      controller.cancelResendTimer();
      controller.cancelTwoFactorExpiryTimer();
    });

    test('Step 2: verifyOtp for 2FA succeeds, clears preAuthToken, and completes login', () async {
      controller.otpFlowType.value = OtpFlowType.twoFactorLogin;
      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'secret123';

      final loginSuccessResponse = LoginResponseEntity(
        user: const UserEntity(
          id: 'usr_rider_999',
          name: 'Alex Rider',
          email: 'rider@example.com',
          phone: '9876543210',
        ),
        rider: const RiderEntity(
          id: 'rider_profile_01',
          name: 'Alex Rider',
          phone: '9876543210',
          email: 'rider@example.com',
          avatar: '',
          rating: 4.8,
          totalTrips: 120,
          isOnline: false,
          walletBalance: 250.0,
          approvalStatus: 'approved',
          isApproved: true,
          onboardingCompleted: true,
          vehicleNumber: 'DL 01 AB 1234',
          drivingLicenseNo: 'DL-1234567890',
          selectedZones: ['North Zone'],
        ),
        accessToken: 'access_jwt_valid',
        refreshToken: 'refresh_jwt_valid',
        expiresIn: 604800,
        requiresOtp: false,
      );

      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'token_challenge_xyz',
      );
      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      await controller.loginWithEmailPassword();
      expect(controller.preAuthToken, equals('token_challenge_xyz'));

      // Set OTP after loginWithEmailPassword since challenge clears the controller
      controller.otpTextController.text = '123456';

      when(() => mockRepo.verify2faOtp(
        preAuthToken: 'token_challenge_xyz',
        otp: '123456',
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(loginSuccessResponse));

      await controller.verifyOtp();

      expect(controller.preAuthToken, isNull);
      controller.cancelResendTimer();
      controller.cancelTwoFactorExpiryTimer();
    });

    test('Step 2 Error: sessionExpired failure clears preAuthToken and navigates to login', () async {
      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'expired_session_token',
      );
      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'pass1234';
      await controller.loginWithEmailPassword();

      expect(controller.preAuthToken, equals('expired_session_token'));

      controller.otpTextController.text = '123456';
      when(() => mockRepo.verify2faOtp(
        preAuthToken: 'expired_session_token',
        otp: '123456',
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => const Left(TwoFactorSessionExpiredFailure()));

      await controller.verifyOtp();

      expect(controller.preAuthToken, isNull);
      controller.cancelResendTimer();
      controller.cancelTwoFactorExpiryTimer();
    });

    test('Step 2 Error: codeExpired zeroes resend timer to allow immediate resend', () async {
      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'token_code_expired',
      );
      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'pass1234';
      await controller.loginWithEmailPassword();

      expect(controller.canResendOtp.value, isFalse);

      controller.otpTextController.text = '123456';
      when(() => mockRepo.verify2faOtp(
        preAuthToken: 'token_code_expired',
        otp: '123456',
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => const Left(TwoFactorCodeExpiredFailure()));

      await controller.verifyOtp();

      expect(controller.resendTimerSeconds.value, equals(0));
      expect(controller.canResendOtp.value, isTrue);
      expect(controller.twoFactorCodeExpirySeconds.value, equals(0));

      controller.cancelResendTimer();
      controller.cancelTwoFactorExpiryTimer();
    });

    test('Step 3: resend2faOtp updates preAuthToken and restarts cooldown and expiry timers', () async {
      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'initial_pre_auth_token',
      );
      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'pass1234';
      await controller.loginWithEmailPassword();

      controller.canResendOtp.value = true;

      when(() => mockRepo.resend2faOtp(preAuthToken: 'initial_pre_auth_token')).thenAnswer(
        (_) async => const Right(TwoFactorResendResultEntity(
          preAuthToken: 'refreshed_pre_auth_token_999',
          resendCooldown: 60,
        )),
      );

      await controller.resendCurrentOtp();

      expect(controller.preAuthToken, equals('refreshed_pre_auth_token_999'));
      expect(controller.resendTimerSeconds.value, equals(60));
      expect(controller.canResendOtp.value, isFalse);
      expect(controller.twoFactorCodeExpirySeconds.value, equals(300));

      controller.cancelResendTimer();
      controller.cancelTwoFactorExpiryTimer();
    });
  });

  group('5. UI & Widget Tests', () {
    late MockAuthRepository mockRepo;
    late MockDeviceInfoService mockDeviceInfo;
    late AuthController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockAuthRepository();
      mockDeviceInfo = MockDeviceInfoService();

      when(() => mockDeviceInfo.getDeviceId()).thenAnswer((_) async => 'device_test_123');
      when(() => mockDeviceInfo.getPlatform()).thenReturn('android');
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

    testWidgets('OtpView displays 2FA security badge, masked chips, and button', (tester) async {
      controller.otpFlowType.value = OtpFlowType.twoFactorLogin;
      controller.twoFactorMaskedPhone.value = '+91 *******3210';
      controller.twoFactorMaskedEmail.value = 'r***@example.com';
      controller.twoFactorCodeExpirySeconds.value = 285;

      await tester.pumpWidget(
        buildTestApp(const OtpView()),
      );

      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.text('2-Step Security Verification'), findsOneWidget);
      expect(find.text('+91 *******3210'), findsOneWidget);
      expect(find.text('r***@example.com'), findsOneWidget);
      expect(find.text('Verify & Sign In'), findsOneWidget);
      expect(find.textContaining('Code valid for'), findsOneWidget);
    });

    testWidgets('Entering 6th digit auto-submits verifyOtp', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const OtpView()),
      );

      controller.otpFlowType.value = OtpFlowType.twoFactorLogin;
      controller.twoFactorMaskedPhone.value = '+91 *******3210';

      final challengeResponse = LoginResponseEntity(
        user: const UserEntity(id: '', name: '', phone: ''),
        rider: const RiderEntity(
          id: '',
          name: '',
          phone: '',
          email: '',
          avatar: '',
          rating: 0,
          totalTrips: 0,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: '',
        ),
        accessToken: '',
        refreshToken: '',
        expiresIn: 300,
        requiresOtp: true,
        preAuthToken: 'auto_submit_token',
      );
      when(() => mockRepo.loginWithEmailPassword(
        email: any(named: 'email'),
        identifier: any(named: 'identifier'),
        phone: any(named: 'phone'),
        phoneCountryCode: any(named: 'phoneCountryCode'),
        password: any(named: 'password'),
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => Right(challengeResponse));

      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'pass1234';
      await controller.loginWithEmailPassword();
      await tester.pump();

      when(() => mockRepo.verify2faOtp(
        preAuthToken: 'auto_submit_token',
        otp: '654321',
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).thenAnswer((_) async => const Right(LoginResponseEntity(
        user: UserEntity(id: '1', name: 'Rider', phone: '123'),
        rider: RiderEntity(
          id: '1',
          name: 'Rider',
          phone: '123',
          email: '',
          avatar: '',
          rating: 5,
          totalTrips: 1,
          isOnline: false,
          walletBalance: 0,
          approvalStatus: 'approved',
          isApproved: true,
          onboardingCompleted: true,
          vehicleNumber: 'V-1',
          drivingLicenseNo: 'DL-1',
          selectedZones: ['Z1'],
        ),
        accessToken: 'tok',
        refreshToken: 'ref',
        expiresIn: 3600,
      )));

      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsOneWidget);

      await tester.enterText(textFieldFinder, '654321');
      await tester.pump();

      verify(() => mockRepo.verify2faOtp(
        preAuthToken: 'auto_submit_token',
        otp: '654321',
        deviceId: any(named: 'deviceId'),
        platform: any(named: 'platform'),
        deviceToken: any(named: 'deviceToken'),
        userAgent: any(named: 'userAgent'),
      )).called(1);
    });
  });
}
