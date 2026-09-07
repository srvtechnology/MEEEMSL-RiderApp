import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('OrderRemoteDataSource Part 2 Implementation Tests', () {
    test('3.1 getActiveOrders fetches active orders from /orders?tab=active', () async {
      final orders = await dataSource.getActiveOrders();
      expect(orders, isNotEmpty);
      expect(orders.first.status, equals(OrderStatus.accepted));
      expect(orders.first.pickupName, contains('MEEEM Super Store'));
    });

    test('3.1 & 2.1 getIncomingOrder fetches offered orders from /orders?tab=offered', () async {
      final order = await dataSource.getIncomingOrder();
      expect(order, isNotNull);
      expect(order!.status, equals(OrderStatus.pending));
      expect(order.pickupName, contains('Electronics Hub'));
    });

    test('3.1 getOrderHistory fetches completed orders from /orders?tab=completed', () async {
      final history = await dataSource.getOrderHistory(statusFilter: 'completed');
      expect(history, isNotEmpty);
      expect(history.first.status, equals(OrderStatus.delivered));
    });

    test('3.2 getOrderDetails fetches snapshot for single order from /orders/:id', () async {
      final details = await dataSource.getOrderDetails('cuid_assignment_id');
      expect(details, isNotNull);
      expect(details.orderNumber, equals('meeem00000042'));
      expect(details.deliveryOtp, equals('582910'));
    });

    test('4.1 acceptOrder calls /orders/:id/accept and updates status to ACCEPTED', () async {
      final accepted = await dataSource.acceptOrder('cuid_assignment_id');
      expect(accepted.status, equals(OrderStatus.accepted));
    });

    test('4.2 declineOrder calls /orders/:id/reject with reason', () async {
      final result = await dataSource.declineOrder('cuid_assignment_id', 'Vehicle puncture');
      expect(result, isTrue);
    });

    test('5.1 updateOrderStatus calls /orders/:id/status for AT_PICKUP and OUT_FOR_DELIVERY', () async {
      final atPickup = await dataSource.updateOrderStatus(
        'cuid_assignment_id',
        OrderStatus.atPickup,
      );
      expect(atPickup.status, equals(OrderStatus.atPickup));

      final outForDelivery = await dataSource.updateOrderStatus(
        'cuid_assignment_id',
        OrderStatus.outForDelivery,
      );
      expect(outForDelivery.status, equals(OrderStatus.outForDelivery));
    });

    test('5.2 updateOrderStatus calls /orders/:id/status for DELIVERED with 6-digit OTP and proofImage', () async {
      final delivered = await dataSource.updateOrderStatus(
        'cuid_assignment_id',
        OrderStatus.delivered,
        customerOtp: '582910',
        proofPhotoUrl: 'https://example.com/proof.jpg',
      );
      expect(delivered.status, equals(OrderStatus.delivered));
      expect(delivered.deliveryOtp, equals('582910'));
    });

    test('6.1 updateOrderStatus calls /orders/:id/status for CANCELLED_BY_RIDER with cancellationReason', () async {
      final cancelled = await dataSource.updateOrderStatus(
        'cuid_assignment_id',
        OrderStatus.cancelled,
        cancellationReason: 'Motorbike tire puncture',
      );
      expect(cancelled.status, equals(OrderStatus.cancelled));
    });
  });
}
