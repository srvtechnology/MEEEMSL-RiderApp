import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/constants/app_constants.dart';
import 'package:meeem_rider/core/error/exceptions.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/network/api_interceptor.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/rate_limit_parser.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/core/services/rider_delivery_service.dart';
import 'package:meeem_rider/core/utils/formatters.dart';
import 'package:meeem_rider/core/utils/secure_utils.dart';
import 'package:meeem_rider/data/datasources/auth_remote_datasource.dart';
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
import 'package:meeem_rider/presentation/modules/auth/views/otp_view.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class _StubHttpAdapter implements dio.HttpClientAdapter {
  final Future<dio.ResponseBody> Function(dio.RequestOptions options) onFetch;
  _StubHttpAdapter(this.onFetch);

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      onFetch(options);

  @override
  void close({bool force = false}) {}
}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final key = utf8.decode(
        message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes),
      );
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

  group('Section 2: Required Client Authentication Header (x-meeem-app-token)', () {
    test('AppConstants exposes the exact documented header name and default token value', () {
      expect(AppConstants.mobileAppTokenHeader, equals('x-meeem-app-token'));
      expect(AppConstants.mobileAppToken, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));
    });

    test('DioClient default BaseOptions headers contain x-meeem-app-token', () {
      final client = DioClient();
      expect(
        client.dio.options.headers[AppConstants.mobileAppTokenHeader],
        equals('meeem_mobile_token_9e7a4b2c1d8f3056'),
      );
    });

    test('ApiInterceptor attaches x-meeem-app-token on both auth and protected endpoints', () {
      final dioInstance = dio.Dio();
      final interceptor = ApiInterceptor(dioInstance);

      for (final endpoint in [
        ApiEndpoints.login,
        ApiEndpoints.register,
        ApiEndpoints.phoneOtpSend,
        ApiEndpoints.phoneOtpVerify,
        ApiEndpoints.forgotPasswordSendOtp,
        ApiEndpoints.resendRegistrationOtp,
        ApiEndpoints.resend2fa,
        ApiEndpoints.riderProfile,
      ]) {
        final req = dio.RequestOptions(path: endpoint, headers: {});
        final handler = dio.RequestInterceptorHandler();
        interceptor.onRequest(req, handler);

        expect(
          req.headers['x-meeem-app-token'],
          equals('meeem_mobile_token_9e7a4b2c1d8f3056'),
          reason: 'Endpoint $endpoint must carry x-meeem-app-token',
        );
      }
    });

    test('RiderDeliveryService includes x-meeem-app-token on all standalone HTTP requests', () async {
      String? capturedHeader;
      final mockClient = MockClient((request) async {
        capturedHeader = request.headers['x-meeem-app-token'];
        return http.Response(jsonEncode({'success': true}), 200);
      });

      await RiderDeliveryService.acceptOffer(
        orderId: 'ord_1',
        token: 'jwt_tok',
        client: mockClient,
      );
      expect(capturedHeader, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));

      capturedHeader = null;
      await RiderDeliveryService.rejectOffer(
        orderId: 'ord_1',
        token: 'jwt_tok',
        client: mockClient,
      );
      expect(capturedHeader, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));

      capturedHeader = null;
      await RiderDeliveryService.updateStatus(
        orderId: 'ord_1',
        status: 'AT_PICKUP',
        token: 'jwt_tok',
        client: mockClient,
      );
      expect(capturedHeader, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));

      capturedHeader = null;
      await RiderDeliveryService.completeDelivery(
        orderId: 'ord_1',
        otp: '123456',
        proofImageBase64: 'data:image/jpeg;base64,abc',
        token: 'jwt_tok',
        client: mockClient,
      );
      expect(capturedHeader, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));

      capturedHeader = null;
      await RiderDeliveryService.cancelTrip(
        orderId: 'ord_1',
        cancellationReason: 'Breakdown',
        token: 'jwt_tok',
        client: mockClient,
      );
      expect(capturedHeader, equals('meeem_mobile_token_9e7a4b2c1d8f3056'));
    });

    test('SecureUtils redacts x-meeem-app-token from log payloads', () {
      final sanitized = SecureUtils.sanitizeLogPayload({
        'x-meeem-app-token': 'meeem_mobile_token_9e7a4b2c1d8f3056',
        'Accept': 'application/json',
      }) as Map;
      expect(sanitized['x-meeem-app-token'], equals('[REDACTED]'));
      expect(sanitized['Accept'], equals('application/json'));
    });

    test('RateLimitParser identifies 401 mobile client authentication token error', () {
      final req = dio.RequestOptions(path: ApiEndpoints.riderProfile);
      final err = dio.DioException(
        requestOptions: req,
        response: dio.Response(
          requestOptions: req,
          statusCode: 401,
          data: {
            'success': false,
            'error': 'Missing or invalid mobile client authentication token.',
          },
        ),
        type: dio.DioExceptionType.badResponse,
      );
      expect(RateLimitParser.isMobileClientTokenError(err), isTrue);
    });
  });

  group('Section 3: HTTP 429 Rate Limiting & Cooldown Parsing', () {
    test('3A. IP Rate Limiting parses retryAfter integer and ipRateLimit type', () {
      final ex = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Too many requests from your IP. Please wait 48 seconds before trying again.',
          'retryAfter': 48,
        },
        retryAfterHeader: '48',
      );
      expect(ex.type, equals(RateLimitType.ipRateLimit));
      expect(ex.cooldownSeconds, equals(48));
      expect(ex.retryAfter, equals(48));
      expect(ex.isDailyLimit, isFalse);
      expect(ex.isOtpLockout, isFalse);
    });

    test('3B. Phone OTP Cooldown parses retryAfter and Retry-After header', () {
      final ex = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Please wait 35 seconds before requesting another OTP.',
          'retryAfter': 35,
        },
        retryAfterHeader: '35',
      );
      expect(ex.type, equals(RateLimitType.otpCooldown));
      expect(ex.cooldownSeconds, equals(35));
      expect(ex.retryAfter, equals(35));

      // Header-only fallback when body omits retryAfter
      final headerOnly = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Please wait before requesting another OTP.',
        },
        retryAfterHeader: '42',
      );
      expect(headerOnly.type, equals(RateLimitType.otpCooldown));
      expect(headerOnly.cooldownSeconds, equals(42));
      expect(headerOnly.retryAfter, equals(42));
    });

    test('3C. Daily Phone OTP Limit (9/day) is classified as dailyOtpLimit without misreading 9 as seconds', () {
      final ex = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Daily OTP verification limit (9/day) reached for this phone number. Please try again tomorrow.',
        },
      );
      expect(ex.type, equals(RateLimitType.dailyOtpLimit));
      expect(ex.isDailyLimit, isTrue);
      expect(ex.cooldownSeconds, equals(0));
      expect(ex.retryAfter, isNull);
    });

    test('3D. Brute-Force OTP Lockout (5 failed attempts -> 15 min) parses 900 seconds', () {
      final ex = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Too many failed attempts. Try again in 15 minute(s).',
        },
      );
      expect(ex.type, equals(RateLimitType.otpLockout));
      expect(ex.isOtpLockout, isTrue);
      expect(ex.cooldownSeconds, equals(900));
    });

    test('3E. Login Rate Limiting (5 attempts / min) parses 60 seconds and loginRateLimit type', () {
      final ex = RateLimitParser.parse(
        body: {
          'success': false,
          'error': 'Too many login attempts. Please wait 1 minute.',
        },
      );
      expect(ex.type, equals(RateLimitType.loginRateLimit));
      expect(ex.cooldownSeconds, equals(60));
    });
  });

  group('Section 4: Phone Number Formatting Best Practices', () {
    test('Sanitizes alphabetic characters and symbols before API dispatch', () {
      expect(Formatters.sanitizeLocalPhone('(079) 494-127 abc'), equals('079494127'));
      expect(Formatters.sanitizePhoneNumber('+232 79-494-127'), equals('+23279494127'));
      expect(Formatters.toE164Phone('79-494-127', countryCode: '+232'), equals('+23279494127'));
      expect(Formatters.toE164Phone('079494127', countryCode: '+232'), equals('+23279494127'));
      expect(Formatters.toE164Phone('+232 79 494 127', countryCode: '+232'), equals('+23279494127'));
    });

    test('RateLimitParser handles raw JSON string response bodies on 429 and 401', () {
      final req = dio.RequestOptions(path: ApiEndpoints.register);
      final res429 = dio.Response<dynamic>(
        requestOptions: req,
        statusCode: 429,
        data: jsonEncode({
          'success': false,
          'error': 'Too many requests from your IP. Please wait 48 seconds before trying again.',
          'retryAfter': 48,
        }),
      );
      final parsed = RateLimitParser.fromResponse(res429);
      expect(parsed.type, equals(RateLimitType.ipRateLimit));
      expect(parsed.retryAfter, equals(48));

      final err401 = dio.DioException(
        requestOptions: req,
        response: dio.Response<dynamic>(
          requestOptions: req,
          statusCode: 401,
          data: jsonEncode({
            'success': false,
            'error': 'Missing or invalid mobile client authentication token.',
          }),
        ),
        type: dio.DioExceptionType.badResponse,
      );
      expect(RateLimitParser.isMobileClientTokenError(err401), isTrue);
    });
  });

  group('End-to-End DioClient + ApiInterceptor + AuthRemoteDataSource 429 & Header Tests', () {
    test('All protected auth endpoints send x-meeem-app-token and convert HTTP 429 to typed RateLimitException', () async {
      final dioClient = DioClient();
      dio.RequestOptions? lastOptions;
      int stubStatus = 429;
      Map<String, dynamic> stubBody = {};
      Map<String, List<String>> stubHeaders = {'content-type': ['application/json']};

      dioClient.dio.httpClientAdapter = _StubHttpAdapter((options) async {
        lastOptions = options;
        return dio.ResponseBody.fromString(
          jsonEncode(stubBody),
          stubStatus,
          headers: stubHeaders,
        );
      });

      final dataSource = AuthRemoteDataSourceImpl(dioClient);

      // 1. Login rate limit (429)
      stubBody = {
        'success': false,
        'error': 'Too many login attempts. Please wait 1 minute.',
      };
      await expectLater(
        () => dataSource.loginWithEmailPassword(
          identifier: '+232 79-494-127',
          password: 'Password1!',
          deviceId: 'dev1',
          platform: 'android',
          deviceToken: 'tok',
          userAgent: 'ua',
        ),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.type, 'type', RateLimitType.loginRateLimit)
              .having((e) => e.cooldownSeconds, 'cooldown', 60),
        ),
      );
      expect(lastOptions?.headers['x-meeem-app-token'], equals('meeem_mobile_token_9e7a4b2c1d8f3056'));
      expect((lastOptions?.data as Map)['phone'], equals('+23279494127'));

      // 2. Self-register IP rate limit (429 with retryAfter: 48)
      stubBody = {
        'success': false,
        'error': 'Too many requests from your IP. Please wait 48 seconds before trying again.',
        'retryAfter': 48,
      };
      stubHeaders = {
        'content-type': ['application/json'],
        'retry-after': ['48'],
      };
      await expectLater(
        () => dataSource.selfRegister(
          name: 'Rider One',
          phone: '79-494-127',
          phoneCountryCode: '+232',
          password: 'Password1!',
        ),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.type, 'type', RateLimitType.ipRateLimit)
              .having((e) => e.retryAfter, 'retryAfter', 48),
        ),
      );
      expect(lastOptions?.headers['x-meeem-app-token'], equals('meeem_mobile_token_9e7a4b2c1d8f3056'));
      expect((lastOptions?.data as Map)['phone'], equals('79494127'));

      // 3. Send phone OTP daily cap (429)
      stubBody = {
        'success': false,
        'error': 'Daily OTP verification limit (9/day) reached for this phone number. Please try again tomorrow.',
      };
      stubHeaders = {'content-type': ['application/json']};
      await expectLater(
        () => dataSource.sendPhoneOtp(phone: '+232 79494127'),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.isDailyLimit, 'isDailyLimit', isTrue)
              .having((e) => e.cooldownSeconds, 'cooldown', 0),
        ),
      );

      // 4. Verify phone OTP 15-min lockout (429)
      stubBody = {
        'success': false,
        'error': 'Too many failed attempts. Try again in 15 minute(s).',
      };
      await expectLater(
        () => dataSource.verifyPhoneOtp(
          phone: '+23279494127',
          otp: '000000',
          deviceId: 'dev1',
          platform: 'android',
          deviceToken: 'tok',
          userAgent: 'ua',
        ),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.isOtpLockout, 'isOtpLockout', isTrue)
              .having((e) => e.cooldownSeconds, 'cooldown', 900),
        ),
      );
    });
  });

  group('AuthController & OtpView Security UI Tests', () {
    late MockAuthRepository mockRepo;
    late MockDeviceInfoService mockDeviceInfo;
    late AuthController controller;

    setUp(() {
      Get.testMode = true;
      mockRepo = MockAuthRepository();
      mockDeviceInfo = MockDeviceInfoService();

      when(() => mockDeviceInfo.getDeviceId()).thenAnswer((_) async => 'dev_test');
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
      controller.cancelAllSecurityTimers();
      controller.cancelTwoFactorExpiryTimer();
      Get.reset();
    });

    test('Login 429 starts loginCooldownSeconds countdown', () async {
      controller.loginEmailController.text = 'rider@example.com';
      controller.loginPasswordController.text = 'Password1!';

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
          )).thenAnswer((_) async => const Left(RateLimitFailure(
            message: 'Too many login attempts. Please wait 1 minute.',
            cooldownSeconds: 60,
            retryAfter: 60,
            type: RateLimitType.loginRateLimit,
          )));

      await controller.loginWithEmailPassword();
      expect(controller.loginCooldownSeconds.value, equals(60));
      controller.cancelAllSecurityTimers();
    });

    test('Daily OTP limit marks dailyOtpLimitReached and blocks resend', () async {
      controller.phoneTextController.text = '79494127';
      when(() => mockRepo.sendPhoneOtp('+23279494127')).thenAnswer(
        (_) async => const Left(RateLimitFailure(
          message: 'Daily OTP verification limit (9/day) reached for this phone number. Please try again tomorrow.',
          cooldownSeconds: 0,
          type: RateLimitType.dailyOtpLimit,
        )),
      );

      await controller.sendOtp();
      expect(controller.dailyOtpLimitReached.value, isTrue);
      expect(controller.canResendOtp.value, isFalse);
      controller.cancelAllSecurityTimers();
    });

    testWidgets('OtpView displays "Resend OTP in Xs", lockout banner, and disables Verify on 15-min lockout',
        (tester) async {
      controller.otpFlowType.value = OtpFlowType.phoneLogin;
      controller.phoneNumber.value = '+23279494127';
      controller.resendTimerSeconds.value = 35;
      controller.canResendOtp.value = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const OtpView(),
          getPages: [
            GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login'))),
          ],
        ),
      );

      expect(find.text('Resend OTP in 35s'), findsOneWidget);

      // Simulate 15-minute brute-force lockout state
      controller.otpLockoutSeconds.value = 900;
      controller.otpLockoutMessage.value = 'Too many failed attempts. Try again in 15 minute(s).';
      await tester.pump();

      expect(find.text('Verification Locked (15:00)'), findsOneWidget);
      expect(find.text('Locked (15:00)'), findsOneWidget);
      expect(
        find.text('Too many failed attempts. Try again in 15 minute(s).'),
        findsOneWidget,
      );
    });
  });
}
