import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/data/datasources/earnings_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioClient dioClient;
  late EarningsRemoteDataSourceImpl dataSource;

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
    dataSource = EarningsRemoteDataSourceImpl(dioClient);
  });

  group('EarningsRemoteDataSource Part 6 Rider Revenue Tests', () {
    test('getRiderRevenue fetches full revenue summary and deliveries', () async {
      final data = await dataSource.getRiderRevenue();

      expect(data.summary, isNotNull);
      expect(data.summary.currency, equals('NLe'));
      expect(data.summary.totalDeliveredRevenue, greaterThan(0));
      expect(data.summary.pendingInProgressRevenue, greaterThan(0));
      expect(data.summary.deliveredCount, greaterThanOrEqualTo(1));
      expect(data.summary.inProgressCount, greaterThanOrEqualTo(1));

      expect(data.deliveries, isNotEmpty);
      final delivered = data.deliveries.firstWhere((d) => d.isDelivered);
      expect(delivered.status, equals('DELIVERED'));
      expect(delivered.totalAmount, isNotNull);
      expect(delivered.totalAmount, equals(delivered.deliveryCharge));
      expect(delivered.items, isNotEmpty);
      expect(delivered.items.first.shippingAmount, greaterThan(0));
    });

    test('getRiderRevenue filters by status = delivered', () async {
      final data = await dataSource.getRiderRevenue(status: 'delivered');

      expect(data.deliveries, isNotEmpty);
      for (final delivery in data.deliveries) {
        expect(delivery.isDelivered, isTrue);
        expect(delivery.totalAmount, isNotNull);
      }
    });

    test('getRiderRevenue filters by status = inprogress and totalAmount is null', () async {
      final data = await dataSource.getRiderRevenue(status: 'inprogress');

      expect(data.deliveries, isNotEmpty);
      for (final delivery in data.deliveries) {
        expect(delivery.isDelivered, isFalse);
        expect(delivery.totalAmount, isNull);
        expect(delivery.deliveryCharge, greaterThan(0));
      }
    });

    test('getRiderRevenue searches by orderNumber', () async {
      final data = await dataSource.getRiderRevenue(search: 'meeem00000042');

      expect(data.deliveries, isNotEmpty);
      expect(data.deliveries.first.orderNumber, equals('meeem00000042'));
    });
  });
}
