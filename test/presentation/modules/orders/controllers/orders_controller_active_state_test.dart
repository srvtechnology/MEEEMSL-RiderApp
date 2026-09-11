import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/cancel_trip_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_history_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_details_usecase.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';

class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
class MockCancelTripUseCase extends Mock implements CancelTripUseCase {}
class MockGetOrderHistoryUseCase extends Mock implements GetOrderHistoryUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}
class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}
class MockToggleOnlineStatusUseCase extends Mock implements ToggleOnlineStatusUseCase {}
class MockGetIncomingOrderUseCase extends Mock implements GetIncomingOrderUseCase {}
class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}
class MockDeclineOrderUseCase extends Mock implements DeclineOrderUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;
  late MockCancelTripUseCase mockCancelTrip;
  late MockGetOrderHistoryUseCase mockGetHistory;
  late MockGetOrderDetailsUseCase mockGetDetails;
  late OrdersController ordersController;

  OrderEntity buildTestOrder({
    required String id,
    String? assignmentId,
    required OrderStatus status,
  }) {
    return OrderEntity(
      id: id,
      assignmentId: assignmentId,
      orderNumber: 'meeem00000064',
      status: status,
      customerName: 'Pranabesh',
      customerPhone: '+232 76 123456',
      customerAvatar: '',
      pickupName: 'Apex Electronics',
      pickupAddress: '124 Siaka Stevens St',
      pickupPhone: '+232 76 654321',
      dropoffAddress: 'Cooch Behar',
      pickupLat: 8.484,
      pickupLng: -13.234,
      dropoffLat: 8.460,
      dropoffLng: -13.250,
      items: const [],
      subtotal: 1000.0,
      riderEarnings: 150.0,
      distanceKm: 2.5,
      estimatedDurationMin: 15,
      createdAt: DateTime.now(),
    );
  }

  setUp(() {
    Get.reset();
    Get.testMode = true;

    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockUpdateStatus = MockUpdateOrderStatusUseCase();
    mockCancelTrip = MockCancelTripUseCase();
    mockGetHistory = MockGetOrderHistoryUseCase();
    mockGetDetails = MockGetOrderDetailsUseCase();

    when(() => mockGetActiveOrders()).thenAnswer((_) async => const Right([]));
    when(() => mockGetHistory(statusFilter: any(named: 'statusFilter'))).thenAnswer((_) async => const Right([]));

    ordersController = OrdersController(
      getActiveOrdersUseCase: mockGetActiveOrders,
      updateOrderStatusUseCase: mockUpdateStatus,
      cancelTripUseCase: mockCancelTrip,
      getOrderHistoryUseCase: mockGetHistory,
      getOrderDetailsUseCase: mockGetDetails,
    );
    Get.put<OrdersController>(ordersController);
  });

  tearDown(() {
    Get.reset();
  });

  group('OrdersController Active Delivery State Progression Tests', () {
    test('advanceActiveOrderStatus advances from accepted to atPickup and syncs with DashboardController', () async {
      final initialOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.accepted);
      ordersController.setActiveOrder(initialOrder);

      final updatedOrder = initialOrder.copyWith(status: OrderStatus.atPickup);
      when(() => mockUpdateStatus('asgn_64', OrderStatus.atPickup))
          .thenAnswer((_) async => Right(updatedOrder));

      final mockSummary = MockGetDashboardSummaryUseCase();
      when(() => mockSummary()).thenAnswer((_) async => const Right({}));
      final dashController = DashboardController(
        toggleOnlineStatusUseCase: MockToggleOnlineStatusUseCase(),
        getDashboardSummaryUseCase: mockSummary,
        getActiveOrdersUseCase: mockGetActiveOrders,
        getIncomingOrderUseCase: MockGetIncomingOrderUseCase(),
        acceptOrderUseCase: MockAcceptOrderUseCase(),
        declineOrderUseCase: MockDeclineOrderUseCase(),
      );
      dashController.activeOrder.value = initialOrder;
      Get.put<DashboardController>(dashController);

      await ordersController.advanceActiveOrderStatus();

      expect(ordersController.selectedOrder.value?.status, OrderStatus.atPickup);
      expect(ordersController.activeOrders.first.status, OrderStatus.atPickup);
      expect(dashController.activeOrder.value?.status, OrderStatus.atPickup);
    });

    test('advanceActiveOrderStatus advances from atPickup to pickedUp', () async {
      final initialOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.atPickup);
      ordersController.setActiveOrder(initialOrder);

      final updatedOrder = initialOrder.copyWith(status: OrderStatus.pickedUp);
      when(() => mockUpdateStatus('asgn_64', OrderStatus.pickedUp))
          .thenAnswer((_) async => Right(updatedOrder));

      await ordersController.advanceActiveOrderStatus();

      expect(ordersController.selectedOrder.value?.status, OrderStatus.pickedUp);
      expect(ordersController.selectedOrder.value?.status.nextStepActionTitle,
          'Swipe to Start Delivery to Customer');
    });

    test('advanceActiveOrderStatus advances from pickedUp to outForDelivery', () async {
      final initialOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.pickedUp);
      ordersController.setActiveOrder(initialOrder);

      final updatedOrder = initialOrder.copyWith(status: OrderStatus.outForDelivery);
      when(() => mockUpdateStatus('asgn_64', OrderStatus.outForDelivery))
          .thenAnswer((_) async => Right(updatedOrder));

      await ordersController.advanceActiveOrderStatus();

      expect(ordersController.selectedOrder.value?.status, OrderStatus.outForDelivery);
      expect(ordersController.selectedOrder.value?.status.nextStepActionTitle,
          'Swipe to Complete Delivery (Enter OTP)');
    });

    test('loadOrders does not regress active order status when backend returns stale replica status', () async {
      // Local state has progressed to pickedUp (Step 3)
      final localOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.pickedUp);
      ordersController.setActiveOrder(localOrder);

      // Backend replica momentarily returns older status atPickup (Step 2)
      final staleBackendOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.atPickup);
      when(() => mockGetActiveOrders()).thenAnswer((_) async => Right([staleBackendOrder]));

      await ordersController.loadOrders();

      // Must preserve local pickedUp status and NOT regress to atPickup
      expect(ordersController.selectedOrder.value?.status, OrderStatus.pickedUp);
    });

    test('preserves in-memory active order during transient empty response', () async {
      final localOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.pickedUp);
      ordersController.setActiveOrder(localOrder);

      // Backend returns empty response (e.g. network blip or temporary filter)
      when(() => mockGetActiveOrders()).thenAnswer((_) async => const Right([]));

      await ordersController.loadOrders();

      expect(ordersController.selectedOrder.value, isNotNull);
      expect(ordersController.selectedOrder.value?.id, 'ord_64');
      expect(ordersController.selectedOrder.value?.status, OrderStatus.pickedUp);
    });

    test('failure from updateOrderStatusUseCase does not crash or corrupt selectedOrder', () async {
      final currentOrder = buildTestOrder(id: 'ord_64', assignmentId: 'asgn_64', status: OrderStatus.atPickup);
      ordersController.setActiveOrder(currentOrder);

      when(() => mockUpdateStatus('asgn_64', OrderStatus.pickedUp))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Network Timeout')));

      await ordersController.advanceActiveOrderStatus();

      expect(ordersController.selectedOrder.value?.status, OrderStatus.atPickup);
      expect(ordersController.isLoading.value, isFalse);
    });
  });
}
