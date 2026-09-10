import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/data/datasources/order_remote_datasource.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioClient dioClient;
  late OrderRemoteDataSourceImpl dataSource;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
  });

  setUp(() {
    dioClient = DioClient();
    dioClient.dio.interceptors.clear();
    dioClient.dio.interceptors.add(MockInterceptor());
    dataSource = OrderRemoteDataSourceImpl(dioClient);
  });

  group('OrderRemoteDataSource Part 8 Tests', () {
    test('ApiEndpoints.isPart8Endpoint validates /orders/:id/accept, /orders/:id/reject, /orders/:id/status', () {
      expect(ApiEndpoints.isPart8Endpoint('/orders/cuid_123/accept'), isTrue);
      expect(ApiEndpoints.isPart8Endpoint('/orders/cuid_123/reject'), isTrue);
      expect(ApiEndpoints.isPart8Endpoint('/orders/cuid_123/status'), isTrue);
      expect(ApiEndpoints.isPart8Endpoint('https://www.meeemsl.com/mobileapi/rider/orders/cuid_123/status'), isTrue);

      expect(ApiEndpoints.isPart8Endpoint('/orders'), isFalse);
      expect(ApiEndpoints.isPart8Endpoint('/profile'), isFalse);
      expect(ApiEndpoints.isDocumentedEndpoint('/orders/cuid_123/status'), isTrue);
    });

    test('cancelTrip posts CANCELLED_BY_RIDER with cancellationReason', () async {
      final cancelled = await dataSource.cancelTrip(
        'cuid_assignment_id',
        'Vehicle breakdown',
      );

      expect(cancelled.status, OrderStatus.cancelled);
    });

    test('updateOrderStatus with DELIVERED sends otp and proofImage', () async {
      final delivered = await dataSource.updateOrderStatus(
        'cuid_assignment_id',
        OrderStatus.delivered,
        customerOtp: '582910',
        proofPhotoUrl: 'https://example.com/delivered_parcel.jpg',
      );

      expect(delivered.status, OrderStatus.delivered);
      expect(delivered.deliveryOtp, '582910');
    });
  });
}
