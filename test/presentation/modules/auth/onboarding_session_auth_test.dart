import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/constants/app_constants.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/network/api_interceptor.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/data/datasources/auth_remote_datasource.dart';
import 'package:meeem_rider/data/models/login_response_model.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';
import 'package:meeem_rider/domain/usecases/auth/login_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_email_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/register_rider_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/resend_registration_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/reset_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/self_register_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/send_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/submit_onboarding_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_registration_otp_usecase.dart';
import 'package:meeem_rider/presentation/modules/auth/controllers/auth_controller.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockDioClient extends Mock implements DioClient {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLoginWithPasswordUseCase extends Mock implements LoginWithPasswordUseCase {}
class MockLoginWithEmailPasswordUseCase extends Mock implements LoginWithEmailPasswordUseCase {}
class MockSendPhoneOtpUseCase extends Mock implements SendPhoneOtpUseCase {}
class MockVerifyPhoneOtpUseCase extends Mock implements VerifyPhoneOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockRegisterRiderUseCase extends Mock implements RegisterRiderUseCase {}
class MockSubmitOnboardingUseCase extends Mock implements SubmitOnboardingUseCase {}
class MockSelfRegisterUseCase extends Mock implements SelfRegisterUseCase {}
class MockVerifyRegistrationOtpUseCase extends Mock implements VerifyRegistrationOtpUseCase {}
class MockResendRegistrationOtpUseCase extends Mock implements ResendRegistrationOtpUseCase {}
class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class _TestHttpAdapter implements dio.HttpClientAdapter {
  final Future<dio.ResponseBody> Function(
    dio.RequestOptions options,
    List<int> bodyBytes,
  ) onFetch;

  _TestHttpAdapter(this.onFetch);

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    return onFetch(options, bytes);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('meeem_onboarding_auth_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    await GetStorage.init();
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    final storage = GetStorage();
    await storage.erase();
  });

  group('1. LoginResponseModel token parsing fallbacks', () {
    test('parses direct data.accessToken and data.refreshToken when tokens object is absent', () {
      final model = LoginResponseModel.fromJson({
        'success': true,
        'data': {
          'accessToken': 'direct_access_jwt_123',
          'refreshToken': 'direct_refresh_jwt_456',
          'expiresIn': 172800,
          'user': {
            'id': 'usr_1',
            'name': 'Test Rider',
            'phone': '+919749617626',
            'role': 'RIDER',
          },
          'rider': {
            'id': 'rid_1',
            'onboardingCompleted': false,
            'isFirstLogin': true,
          },
        },
      });

      expect(model.accessToken, equals('direct_access_jwt_123'));
      expect(model.refreshToken, equals('direct_refresh_jwt_456'));
    });

    test('parses tokens.token and top-level accessToken fallbacks', () {
      final model = LoginResponseModel.fromJson({
        'success': true,
        'accessToken': 'top_level_jwt',
        'refreshToken': 'top_level_refresh',
        'user': {'id': 'usr_2', 'name': 'Rider 2', 'phone': '+23276000001'},
        'rider': {'id': 'rid_2', 'onboardingCompleted': false},
      });

      expect(model.accessToken, equals('top_level_jwt'));
      expect(model.refreshToken, equals('top_level_refresh'));
    });
  });

  group('2. AuthRemoteDataSourceImpl.refreshToken response parsing', () {
    test('parses API Doc Part 1 Section 3.3 data.accessToken payload', () async {
      final dioInstance = dio.Dio(
        dio.BaseOptions(baseUrl: 'https://www.meeemsl.com/mobileapi/rider'),
      );
      dioInstance.httpClientAdapter = _TestHttpAdapter((options, _) async {
        expect(options.path, equals(ApiEndpoints.refreshToken));
        return dio.ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'accessToken': 'refreshed_jwt_part1_doc',
              'expiresIn': 172800,
              'tokenType': 'Bearer',
            },
          }),
          200,
          headers: {
            dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
          },
        );
      });

      final mockClient = MockDioClient();
      when(() => mockClient.dio).thenReturn(dioInstance);
      final ds = AuthRemoteDataSourceImpl(mockClient);

      final newToken = await ds.refreshToken('valid_refresh_token');
      expect(newToken, equals('refreshed_jwt_part1_doc'));
    });
  });

  group('3. ApiInterceptor 401 refresh + FormData retry on /onboarding', () {
    test(
      'refreshes expired accessToken and successfully retries multipart FormData /onboarding without wiping tokens',
      () async {
        final storage = GetStorage();
        await storage.write(AppConstants.tokenKey, 'expired_access_token');
        await storage.write(AppConstants.refreshTokenKey, 'valid_refresh_token');

        final dummyFile = File('${tempDir.path}/dummy_dl.jpg');
        await dummyFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

        int onboardingAttempts = 0;
        int refreshAttempts = 0;
        final List<String?> capturedAuthHeaders = [];
        final List<String?> capturedContentTypes = [];
        final List<int> capturedBodyLengths = [];

        final adapter = _TestHttpAdapter((options, bodyBytes) async {
          if (options.path.contains(ApiEndpoints.refreshToken)) {
            refreshAttempts++;
            return dio.ResponseBody.fromString(
              jsonEncode({
                'success': true,
                'data': {
                  'accessToken': 'fresh_access_token_xyz',
                  'refreshToken': 'rotated_refresh_token_xyz',
                  'expiresIn': 172800,
                  'tokenType': 'Bearer',
                },
              }),
              200,
              headers: {
                dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
              },
            );
          }

          if (options.path.contains(ApiEndpoints.onboarding)) {
            onboardingAttempts++;
            final auth = options.headers['Authorization'] as String?;
            capturedAuthHeaders.add(auth);
            capturedContentTypes.add(options.headers['content-type']?.toString() ?? options.contentType);
            capturedBodyLengths.add(bodyBytes.length);

            if (auth != 'Bearer fresh_access_token_xyz') {
              return dio.ResponseBody.fromString(
                jsonEncode({
                  'success': false,
                  'error': 'Unauthorized: Invalid or expired mobile session.',
                }),
                401,
                headers: {
                  dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
                },
              );
            }

            return dio.ResponseBody.fromString(
              jsonEncode({
                'success': true,
                'message': 'Rider onboarding completed successfully!',
                'data': {
                  'onboardingCompleted': true,
                  'rider': {
                    'id': 'rid_999',
                    'name': 'Test Rider',
                    'phone': '+919749617626',
                    'status': 'PENDING',
                    'isApproved': false,
                    'onboardingCompleted': true,
                    'vehicleType': '2_WHEELER',
                  },
                },
              }),
              200,
              headers: {
                dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
              },
            );
          }

          return dio.ResponseBody.fromString('{"success":false}', 404);
        });

        final dioInstance = dio.Dio(
          dio.BaseOptions(baseUrl: 'https://www.meeemsl.com/mobileapi/rider'),
        );
        dioInstance.httpClientAdapter = adapter;
        dioInstance.interceptors.add(ApiInterceptor(dioInstance));

        final formData = dio.FormData.fromMap({
          'vehicleType': '2_WHEELER',
          'paymentOption': 'Orange Money',
          'mobileNumber': '8927602437',
          'drivingLicenseDoc': await dio.MultipartFile.fromFile(
            dummyFile.path,
            filename: 'dummy_dl.jpg',
          ),
        });

        final response = await dioInstance.post(
          ApiEndpoints.onboarding,
          data: formData,
          options: dio.Options(contentType: 'multipart/form-data'),
        );

        expect(response.statusCode, equals(200));
        expect(refreshAttempts, equals(1));
        expect(onboardingAttempts, equals(2));
        expect(capturedAuthHeaders, equals(['Bearer expired_access_token', 'Bearer fresh_access_token_xyz']));
        expect(capturedBodyLengths.last, greaterThan(0));
        expect(capturedContentTypes.last, contains('multipart/form-data'));
        expect(storage.read<String>(AppConstants.tokenKey), equals('fresh_access_token_xyz'));
        expect(storage.read<String>(AppConstants.refreshTokenKey), equals('rotated_refresh_token_xyz'));
      },
    );

    test(
      'does NOT wipe freshly refreshed tokens when the retried request fails with a non-401 server error',
      () async {
        final storage = GetStorage();
        await storage.write(AppConstants.tokenKey, 'expired_access_token');
        await storage.write(AppConstants.refreshTokenKey, 'valid_refresh_token');

        final adapter = _TestHttpAdapter((options, _) async {
          if (options.path.contains(ApiEndpoints.refreshToken)) {
            return dio.ResponseBody.fromString(
              jsonEncode({
                'success': true,
                'data': {'accessToken': 'fresh_access_token_keep'},
              }),
              200,
              headers: {
                dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
              },
            );
          }
          if (options.headers['Authorization'] == 'Bearer fresh_access_token_keep') {
            return dio.ResponseBody.fromString(
              jsonEncode({'success': false, 'error': 'Invalid mobile number format'}),
              400,
              headers: {
                dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
              },
            );
          }
          return dio.ResponseBody.fromString(
            jsonEncode({'success': false, 'error': 'Unauthorized: Invalid or expired mobile session.'}),
            401,
            headers: {
              dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
            },
          );
        });

        final dioInstance = dio.Dio(
          dio.BaseOptions(baseUrl: 'https://www.meeemsl.com/mobileapi/rider'),
        );
        dioInstance.httpClientAdapter = adapter;
        dioInstance.interceptors.add(ApiInterceptor(dioInstance));

        await expectLater(
          () => dioInstance.post(
            ApiEndpoints.onboarding,
            data: dio.FormData.fromMap({'vehicleType': '2_WHEELER'}),
          ),
          throwsA(
            isA<dio.DioException>().having((e) => e.response?.statusCode, 'statusCode', 400),
          ),
        );

        expect(storage.read<String>(AppConstants.tokenKey), equals('fresh_access_token_keep'));
        expect(storage.read<String>(AppConstants.refreshTokenKey), equals('valid_refresh_token'));
      },
    );

    test(
      'clears stored tokens when /auth/refresh also returns 401 (expired refresh token)',
      () async {
        final storage = GetStorage();
        await storage.write(AppConstants.tokenKey, 'expired_access_token');
        await storage.write(AppConstants.refreshTokenKey, 'expired_refresh_token');

        final adapter = _TestHttpAdapter((options, _) async {
          return dio.ResponseBody.fromString(
            jsonEncode({'success': false, 'error': 'Unauthorized: Invalid or expired mobile session.'}),
            401,
            headers: {
              dio.Headers.contentTypeHeader: [dio.Headers.jsonContentType],
            },
          );
        });

        final dioInstance = dio.Dio(
          dio.BaseOptions(baseUrl: 'https://www.meeemsl.com/mobileapi/rider'),
        );
        dioInstance.httpClientAdapter = adapter;
        dioInstance.interceptors.add(ApiInterceptor(dioInstance));

        await expectLater(
          () => dioInstance.post(
            ApiEndpoints.onboarding,
            data: dio.FormData.fromMap({'vehicleType': '2_WHEELER'}),
          ),
          throwsA(
            isA<dio.DioException>().having((e) => e.response?.statusCode, 'statusCode', 401),
          ),
        );

        expect(storage.read<String>(AppConstants.tokenKey), isNull);
        expect(storage.read<String>(AppConstants.refreshTokenKey), isNull);
      },
    );
  });

  group('4. AuthController.submitFullOnboarding 401 session-expired handling', () {
    testWidgets(
      'clears stale tokens and redirects to Login when onboarding fails with 401 session expired',
      (tester) async {
        Get.testMode = false;
        final storage = GetStorage();
        await storage.write(AppConstants.tokenKey, 'stale_token');
        await storage.write(AppConstants.refreshTokenKey, 'stale_refresh');

        final mockSubmitUseCase = MockSubmitOnboardingUseCase();
        when(() => mockSubmitUseCase(
              name: any(named: 'name'),
              phone: any(named: 'phone'),
              phoneCountryCode: any(named: 'phoneCountryCode'),
              newPassword: any(named: 'newPassword'),
              vehicleType: any(named: 'vehicleType'),
              vehicleTypes: any(named: 'vehicleTypes'),
              vehicleName: any(named: 'vehicleName'),
              vehicleNumber: any(named: 'vehicleNumber'),
              vehicleColor: any(named: 'vehicleColor'),
              vehicleYear: any(named: 'vehicleYear'),
              drivingLicenseNo: any(named: 'drivingLicenseNo'),
              selectedZones: any(named: 'selectedZones'),
              selectedLocations: any(named: 'selectedLocations'),
              address: any(named: 'address'),
              emergencyContact: any(named: 'emergencyContact'),
              payoutInfo: any(named: 'payoutInfo'),
              profileImagePath: any(named: 'profileImagePath'),
              drivingLicenseDocPath: any(named: 'drivingLicenseDocPath'),
              nationalIdDocPath: any(named: 'nationalIdDocPath'),
              nationalIdPath: any(named: 'nationalIdPath'),
              vehicleInsuranceDocPath: any(named: 'vehicleInsuranceDocPath'),
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(
              message: 'Unauthorized: Invalid or expired mobile session.',
              statusCode: 401,
            ),
          ),
        );

        final controller = AuthController(
          loginUseCase: MockLoginUseCase(),
          loginWithPasswordUseCase: MockLoginWithPasswordUseCase(),
          loginWithEmailPasswordUseCase: MockLoginWithEmailPasswordUseCase(),
          sendPhoneOtpUseCase: MockSendPhoneOtpUseCase(),
          verifyPhoneOtpUseCase: MockVerifyPhoneOtpUseCase(),
          verifyOtpUseCase: MockVerifyOtpUseCase(),
          registerRiderUseCase: MockRegisterRiderUseCase(),
          submitOnboardingUseCase: mockSubmitUseCase,
          selfRegisterUseCase: MockSelfRegisterUseCase(),
          verifyRegistrationOtpUseCase: MockVerifyRegistrationOtpUseCase(),
          resendRegistrationOtpUseCase: MockResendRegistrationOtpUseCase(),
          resetPasswordUseCase: MockResetPasswordUseCase(),
          deviceInfoService: MockDeviceInfoService(),
        );

        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: AppRoutes.onboarding,
            getPages: [
              GetPage(name: AppRoutes.onboarding, page: () => const Scaffold(body: Text('Onboarding Screen'))),
              GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login Screen'))),
            ],
          ),
        );

        controller.fullNameController.text = 'Test Rider';
        controller.onboardingPhoneController.text = '+919749617626';
        controller.vehicleType.value = '2_WHEELER';
        controller.selectedPaymentOption.value = PaymentOption.orangeMoney;
        controller.mobileNumberController.text = '8927602437';

        await controller.submitFullOnboarding();
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(storage.read<String>(AppConstants.tokenKey), isNull);
        expect(storage.read<String>(AppConstants.refreshTokenKey), isNull);
        expect(Get.currentRoute, equals(AppRoutes.login));

        controller.dispose();
        Get.reset();
      },
    );

    testWidgets(
      'does NOT clear tokens or redirect to Login on 401 mobile client authentication token error',
      (tester) async {
        Get.testMode = false;
        final storage = GetStorage();
        await storage.write(AppConstants.tokenKey, 'valid_user_token');
        await storage.write(AppConstants.refreshTokenKey, 'valid_user_refresh');

        final mockSubmitUseCase = MockSubmitOnboardingUseCase();
        when(() => mockSubmitUseCase(
              name: any(named: 'name'),
              phone: any(named: 'phone'),
              phoneCountryCode: any(named: 'phoneCountryCode'),
              newPassword: any(named: 'newPassword'),
              vehicleType: any(named: 'vehicleType'),
              vehicleTypes: any(named: 'vehicleTypes'),
              vehicleName: any(named: 'vehicleName'),
              vehicleNumber: any(named: 'vehicleNumber'),
              vehicleColor: any(named: 'vehicleColor'),
              vehicleYear: any(named: 'vehicleYear'),
              drivingLicenseNo: any(named: 'drivingLicenseNo'),
              selectedZones: any(named: 'selectedZones'),
              selectedLocations: any(named: 'selectedLocations'),
              address: any(named: 'address'),
              emergencyContact: any(named: 'emergencyContact'),
              payoutInfo: any(named: 'payoutInfo'),
              profileImagePath: any(named: 'profileImagePath'),
              drivingLicenseDocPath: any(named: 'drivingLicenseDocPath'),
              nationalIdDocPath: any(named: 'nationalIdDocPath'),
              nationalIdPath: any(named: 'nationalIdPath'),
              vehicleInsuranceDocPath: any(named: 'vehicleInsuranceDocPath'),
            )).thenAnswer(
          (_) async => const Left(
            ServerFailure(
              message: 'Missing or invalid mobile client authentication token.',
              statusCode: 401,
            ),
          ),
        );

        final controller = AuthController(
          loginUseCase: MockLoginUseCase(),
          loginWithPasswordUseCase: MockLoginWithPasswordUseCase(),
          loginWithEmailPasswordUseCase: MockLoginWithEmailPasswordUseCase(),
          sendPhoneOtpUseCase: MockSendPhoneOtpUseCase(),
          verifyPhoneOtpUseCase: MockVerifyPhoneOtpUseCase(),
          verifyOtpUseCase: MockVerifyOtpUseCase(),
          registerRiderUseCase: MockRegisterRiderUseCase(),
          submitOnboardingUseCase: mockSubmitUseCase,
          selfRegisterUseCase: MockSelfRegisterUseCase(),
          verifyRegistrationOtpUseCase: MockVerifyRegistrationOtpUseCase(),
          resendRegistrationOtpUseCase: MockResendRegistrationOtpUseCase(),
          resetPasswordUseCase: MockResetPasswordUseCase(),
          deviceInfoService: MockDeviceInfoService(),
        );

        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: AppRoutes.onboarding,
            getPages: [
              GetPage(name: AppRoutes.onboarding, page: () => const Scaffold(body: Text('Onboarding Screen'))),
              GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login Screen'))),
            ],
          ),
        );

        controller.fullNameController.text = 'Test Rider';
        controller.onboardingPhoneController.text = '+919749617626';
        controller.vehicleType.value = '2_WHEELER';
        controller.selectedPaymentOption.value = PaymentOption.orangeMoney;
        controller.mobileNumberController.text = '8927602437';

        await controller.submitFullOnboarding();
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(storage.read<String>(AppConstants.tokenKey), equals('valid_user_token'));
        expect(storage.read<String>(AppConstants.refreshTokenKey), equals('valid_user_refresh'));
        expect(Get.currentRoute, equals(AppRoutes.onboarding));

        controller.dispose();
        Get.reset();
      },
    );
  });
}
