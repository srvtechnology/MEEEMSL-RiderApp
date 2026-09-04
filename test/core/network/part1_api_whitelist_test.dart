import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/api_interceptor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiEndpoints.isPart1Endpoint Whitelist', () {
    test('returns true for all documented endpoints in MOBILE_RIDER_APP_API_DOC_PART_1.md', () {
      // 2. Rider Registration & OTP Verification
      expect(ApiEndpoints.isPart1Endpoint('/auth/register'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/verify-otp'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/resend-otp'), isTrue);

      // 3. Rider Login & Session Lifecycle
      expect(ApiEndpoints.isPart1Endpoint('/auth/login'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/phone-otp/send-otp'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/phone-otp/verify-otp'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/refresh'), isTrue);

      // 4. Forgot & Reset Password Flow
      expect(ApiEndpoints.isPart1Endpoint('/auth/forgot-password/send-otp'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/auth/forgot-password/reset'), isTrue);

      // 5. First-Time Onboarding Flow
      expect(ApiEndpoints.isPart1Endpoint('/onboarding'), isTrue);

      // 6. Rider Profile Management
      expect(ApiEndpoints.isPart1Endpoint('/profile'), isTrue);

      // 7. Rider Settings & Preferences
      expect(ApiEndpoints.isPart1Endpoint('/settings'), isTrue);

      // 8. Delivery Zones & Hierarchical Locations
      expect(ApiEndpoints.isPart1Endpoint('/zones'), isTrue);

      // 9. Multi-Device Push Token Management
      expect(ApiEndpoints.isPart1Endpoint('/device-token'), isTrue);
    });

    test('returns true for full base URLs targeting Part 1 endpoints', () {
      expect(
        ApiEndpoints.isPart1Endpoint('https://www.meeemsl.com/mobileapi/rider/profile'),
        isTrue,
      );
      expect(
        ApiEndpoints.isPart1Endpoint('https://development.meeemsl.com/mobileapi/rider/zones'),
        isTrue,
      );
      expect(
        ApiEndpoints.isPart1Endpoint('https://www.meeemsl.com/mobileapi/rider/auth/login'),
        isTrue,
      );
      expect(
        ApiEndpoints.isPart1Endpoint('https://www.meeemsl.com/mobileapi/rider/settings'),
        isTrue,
      );
      expect(
        ApiEndpoints.isPart1Endpoint('https://www.meeemsl.com/mobileapi/rider/device-token'),
        isTrue,
      );
    });

    test('returns false for non-Part 1 endpoints (specifically requested by user)', () {
      // Specifically highlighted by the user:
      expect(
        ApiEndpoints.isPart1Endpoint(
          'https://www.meeemsl.com/mobileapi/rider/earnings/breakdown?period=weekly',
        ),
        isFalse,
      );
      expect(ApiEndpoints.isPart1Endpoint('/earnings/breakdown'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/earnings/breakdown?period=weekly'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/earnings/payout/request'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/earnings/payout/info'), isFalse);

      // Order management (Not in Part 1)
      expect(ApiEndpoints.isPart1Endpoint('/orders/active'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/incoming'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/accept'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/decline'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/status/update'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/history'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/orders/details/123'), isFalse);

      // Dashboard & Tracking (Not in Part 1)
      expect(ApiEndpoints.isPart1Endpoint('/dashboard/summary'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/rider/status/toggle'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/rider/location/update'), isFalse);

      // Standalone Document/Vehicle Endpoints (Not in Part 1)
      expect(ApiEndpoints.isPart1Endpoint('/profile/documents'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/profile/documents/upload'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/profile/operating-zones'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/profile/vehicle/update'), isFalse);

      // Others
      expect(ApiEndpoints.isPart1Endpoint('/auth/logout'), isFalse);
      expect(ApiEndpoints.isPart1Endpoint('/notifications'), isFalse);
    });
  });

  group('ApiInterceptor Non-Part 1 Request Blocking', () {
    late Dio dio;

    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => '.',
      );
      await GetStorage.init();
      dio = Dio(BaseOptions(
        baseUrl: 'https://www.meeemsl.com/mobileapi/rider',
      ));
      dio.interceptors.add(ApiInterceptor(dio));
    });

    test('intercepts earnings breakdown without network call and serves mock response', () async {
      final response = await dio.get(
        'https://www.meeemsl.com/mobileapi/rider/earnings/breakdown?period=weekly',
      );

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
      expect(response.data['success'], isTrue);
      expect(response.data['data']['todayEarnings'], equals(148.50));
      expect(response.data['data']['weeklyEarnings'], equals(892.20));
    });

    test('intercepts active orders without network call and serves mock response', () async {
      final response = await dio.get('/orders/active');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
      expect(response.data['success'], isTrue);
      expect(response.data['data'], isList);
    });

    test('intercepts dashboard summary without network call and serves mock response', () async {
      final response = await dio.get('/dashboard/summary');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
      expect(response.data['success'], isTrue);
      expect(response.data['data']['todayEarnings'], equals(148.50));
    });

    test('intercepts payout info without network call and serves mock response', () async {
      final response = await dio.get('/earnings/payout/info');

      expect(response.statusCode, 200);
      expect(response.data, isNotNull);
      expect(response.data['success'], isTrue);
      expect(response.data['data']['methodType'], equals('bank'));
    });
  });
}
