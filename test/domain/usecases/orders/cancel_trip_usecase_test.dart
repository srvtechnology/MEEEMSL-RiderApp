import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/repositories/order_repository.dart';
import 'package:meeem_rider/domain/usecases/orders/cancel_trip_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late CancelTripUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = CancelTripUseCase(mockRepository);
  });

  const testOrderId = 'cuid_order_test';
  const testReason = 'Vehicle breakdown';
  final testOrder = OrderEntity(
    id: testOrderId,
    orderNumber: 'meeem00000042',
    status: OrderStatus.cancelled,
    customerName: 'Customer',
    customerPhone: '',
    customerAvatar: '',
    pickupName: 'Store',
    pickupAddress: '',
    pickupPhone: '',
    dropoffAddress: '',
    pickupLat: 0.0,
    pickupLng: 0.0,
    dropoffLat: 0.0,
    dropoffLng: 0.0,
    items: const [],
    subtotal: 0.0,
    riderEarnings: 0.0,
    distanceKm: 0.0,
    estimatedDurationMin: 0,
    createdAt: DateTime.now(),
  );

  test('CancelTripUseCase calls repository.cancelTrip with orderId and cancellationReason', () async {
    when(() => mockRepository.cancelTrip(testOrderId, testReason))
        .thenAnswer((_) async => Right(testOrder));

    final result = await useCase(testOrderId, testReason);

    expect(result, Right(testOrder));
    verify(() => mockRepository.cancelTrip(testOrderId, testReason)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('CancelTripUseCase returns ServerFailure when repository fails', () async {
    when(() => mockRepository.cancelTrip(testOrderId, testReason))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Cancellation failed')));

    final result = await useCase(testOrderId, testReason);

    expect(result, const Left(ServerFailure(message: 'Cancellation failed')));
    verify(() => mockRepository.cancelTrip(testOrderId, testReason)).called(1);
  });
}
