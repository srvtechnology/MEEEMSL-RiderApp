import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/repositories/order_repository.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository mockRepository;
  late GetActiveOrdersUseCase getActiveOrdersUseCase;
  late AcceptOrderUseCase acceptOrderUseCase;
  late UpdateOrderStatusUseCase updateOrderStatusUseCase;

  setUpAll(() {
    registerFallbackValue(OrderStatus.accepted);
  });

  setUp(() {
    mockRepository = MockOrderRepository();
    getActiveOrdersUseCase = GetActiveOrdersUseCase(mockRepository);
    acceptOrderUseCase = AcceptOrderUseCase(mockRepository);
    updateOrderStatusUseCase = UpdateOrderStatusUseCase(mockRepository);
  });

  final tOrder = OrderEntity(
    id: 'ord_99',
    orderNumber: '#MM-99',
    status: OrderStatus.accepted,
    customerName: 'John',
    customerPhone: '1234',
    customerAvatar: '',
    pickupName: 'Store',
    pickupAddress: 'Addr',
    pickupPhone: '5678',
    dropoffAddress: 'Drop',
    pickupLat: 0,
    pickupLng: 0,
    dropoffLat: 0,
    dropoffLng: 0,
    items: const [],
    subtotal: 20,
    riderEarnings: 10,
    distanceKm: 2,
    estimatedDurationMin: 10,
    createdAt: DateTime.now(),
  );

  test('GetActiveOrdersUseCase should fetch active orders', () async {
    when(() => mockRepository.getActiveOrders())
        .thenAnswer((_) async => Right<Failure, List<OrderEntity>>([tOrder]));

    final result = await getActiveOrdersUseCase();

    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected right'),
      (orders) => expect(orders, [tOrder]),
    );
    verify(() => mockRepository.getActiveOrders()).called(1);
  });

  test('AcceptOrderUseCase should accept order by ID', () async {
    when(() => mockRepository.acceptOrder(any()))
        .thenAnswer((_) async => Right<Failure, OrderEntity>(tOrder));

    final result = await acceptOrderUseCase('ord_99');

    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected right'),
      (order) => expect(order, tOrder),
    );
    verify(() => mockRepository.acceptOrder('ord_99')).called(1);
  });

  test('UpdateOrderStatusUseCase should update order status', () async {
    final updatedOrder = tOrder.copyWith(status: OrderStatus.delivered);
    when(() => mockRepository.updateOrderStatus(
          any(),
          any(),
          proofPhotoUrl: any(named: 'proofPhotoUrl'),
          customerOtp: any(named: 'customerOtp'),
        )).thenAnswer((_) async => Right<Failure, OrderEntity>(updatedOrder));

    final result = await updateOrderStatusUseCase('ord_99', OrderStatus.delivered);

    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Expected right'),
      (order) => expect(order.status, OrderStatus.delivered),
    );
    verify(() => mockRepository.updateOrderStatus('ord_99', OrderStatus.delivered)).called(1);
  });
}
