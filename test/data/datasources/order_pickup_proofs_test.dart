import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/data/models/order_model.dart';
import 'package:meeem_rider/data/datasources/order_remote_datasource.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late OrderRemoteDataSourceImpl dataSource;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('pickup_proofs_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    await GetStorage.init();
  });

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = OrderRemoteDataSourceImpl(mockDioClient);
  });

  group('Rider Package Pickup Proofs & Model Tests', () {
    test('OrderEntity and OrderModel support pickupProofPhotos', () {
      final entity = OrderEntity(
        id: 'ord_pickup_1',
        orderNumber: 'meeem00000099',
        status: OrderStatus.pickedUp,
        customerName: 'Amina Mansaray',
        customerPhone: '+23277123456',
        customerAvatar: '',
        pickupName: 'Freetown Fashion Hub',
        pickupAddress: '15 Main Motor Rd, Brookfields',
        pickupPhone: '+23278987654',
        dropoffAddress: '24 Wilkinson Rd',
        pickupLat: 8.48,
        pickupLng: -13.23,
        dropoffLat: 8.46,
        dropoffLng: -13.25,
        items: const [],
        subtotal: 350.0,
        riderEarnings: 15.0,
        distanceKm: 3.2,
        estimatedDurationMin: 18,
        createdAt: DateTime.now(),
        pickupProofPhotos: const [
          'https://storage.googleapis.com/proof1.jpg',
          'https://storage.googleapis.com/proof2.jpg',
        ],
      );

      expect(entity.pickupProofPhotos.length, 2);
      expect(entity.pickupProofPhotos.first, 'https://storage.googleapis.com/proof1.jpg');

      final model = OrderModel.fromEntity(entity);
      expect(model.pickupProofPhotos.length, 2);

      final json = model.toJson();
      expect(json['pickupProofPhotos'], isA<List>());
      expect((json['pickupProofPhotos'] as List).length, 2);

      final fromJson = OrderModel.fromJson(json);
      expect(fromJson.pickupProofPhotos.length, 2);
      expect(fromJson.pickupProofPhotos[1], 'https://storage.googleapis.com/proof2.jpg');
    });

    test('OrderModel.fromJson parses pickupProofPhotos from backend response', () {
      final backendResponse = {
        'id': 'cmtwol9oa000h145zhs2aftv9',
        'orderNumber': 'meeem00000099',
        'status': 'PICKED_UP',
        'pickupProofPhotos': [
          'https://storage.googleapis.com/proofs/pickup-cmtwol9o-1.jpg',
          'https://storage.googleapis.com/proofs/pickup-cmtwol9o-2.jpg',
          'https://storage.googleapis.com/proofs/pickup-cmtwol9o-3.jpg',
        ],
      };

      final model = OrderModel.fromJson(backendResponse);
      expect(model.status, OrderStatus.pickedUp);
      expect(model.pickupProofPhotos.length, 3);
      expect(model.pickupProofPhotos[0], 'https://storage.googleapis.com/proofs/pickup-cmtwol9o-1.jpg');
      expect(model.pickupProofPhotos[2], 'https://storage.googleapis.com/proofs/pickup-cmtwol9o-3.jpg');
    });

    test('updateOrderStatus with PICKED_UP posts pickupPhotos and parses response', () async {
      const orderId = 'ord_pickup_100';
      final photos = [
        'https://storage.googleapis.com/proofs/pickup-cmtwol9o-1.jpg',
        'https://storage.googleapis.com/proofs/pickup-cmtwol9o-2.jpg',
      ];

      when(() => mockDio.post(
            ApiEndpoints.updateDeliveryStatus(orderId),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.updateDeliveryStatus(orderId)),
            statusCode: 200,
            data: {
              'success': true,
              'message': 'Assignment status updated to PICKED_UP',
              'data': {
                'id': orderId,
                'status': 'PICKED_UP',
                'pickupProofPhotos': photos,
              },
            },
          ));

      final result = await dataSource.updateOrderStatus(
        orderId,
        OrderStatus.pickedUp,
        pickupPhotos: photos,
      );

      expect(result.status, OrderStatus.pickedUp);
      expect(result.pickupProofPhotos.length, 2);
      expect(result.pickupProofPhotos[0], photos[0]);

      verify(() => mockDio.post(
            ApiEndpoints.updateDeliveryStatus(orderId),
            data: any(named: 'data'),
          )).called(1);
    });

    test('updateOrderStatus with PICKED_UP and local files sends FormData with ListFormat.multi', () async {
      const orderId = 'ord_pickup_101';
      final tempDir = Directory.systemTemp.createTempSync('pickup_photos_');
      final file1 = File('${tempDir.path}/proof1.jpg')..writeAsBytesSync([1, 2, 3, 4]);
      final file2 = File('${tempDir.path}/proof2.jpg')..writeAsBytesSync([5, 6, 7, 8]);
      final localPhotos = [file1.path, file2.path];

      FormData? capturedFormData;
      when(() => mockDio.post(
            ApiEndpoints.updateDeliveryStatus(orderId),
            data: any(named: 'data'),
          )).thenAnswer((invocation) async {
            capturedFormData = invocation.namedArguments[#data] as FormData;
            return Response(
              requestOptions: RequestOptions(path: ApiEndpoints.updateDeliveryStatus(orderId)),
              statusCode: 200,
              data: {
                'success': true,
                'message': 'Delivery status updated to PICKED_UP',
                'data': {
                  'id': orderId,
                  'status': 'PICKED_UP',
                  'pickupProofPhotos': [
                    'https://meeemsl-bucket.s3.us-east-1.amazonaws.com/uploads/pickup-proofs/pickup-1.jpg',
                    'https://meeemsl-bucket.s3.us-east-1.amazonaws.com/uploads/pickup-proofs/pickup-2.jpg',
                  ],
                },
              },
            );
          });

      final result = await dataSource.updateOrderStatus(
        orderId,
        OrderStatus.pickedUp,
        pickupPhotos: localPhotos,
      );

      expect(result.status, OrderStatus.pickedUp);
      expect(result.pickupProofPhotos.length, 2);
      expect(capturedFormData, isNotNull);
      expect(capturedFormData!.fields.any((f) => f.key == 'status' && f.value == 'PICKED_UP'), isTrue);
      final files = capturedFormData!.files.where((f) => f.key == 'pickupPhotos').toList();
      expect(files.length, 2);
      expect(files[0].key, 'pickupPhotos');
      expect(files[1].key, 'pickupPhotos');
    });
  });
}
