import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/usecases/orders/cancel_trip_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_details_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_history_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';
import 'package:meeem_rider/presentation/modules/orders/views/active_order_view.dart';
import 'package:meeem_rider/presentation/modules/orders/widgets/cancel_delivery_dialog.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
class MockCancelTripUseCase extends Mock implements CancelTripUseCase {}
class MockGetOrderHistoryUseCase extends Mock implements GetOrderHistoryUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}
class MockToggleOnlineStatusUseCase extends Mock implements ToggleOnlineStatusUseCase {}
class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}
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
  late OrdersController controller;

  OrderEntity buildOrderWithStatus(OrderStatus status) {
    return OrderEntity(
      id: 'order_test_42',
      orderNumber: 'meeem00000042',
      status: status,
      customerName: 'Fatmata Koroma',
      customerPhone: '+232 76 998877',
      customerAvatar: '',
      pickupName: 'MEEEM Super Store',
      pickupAddress: '25 Siaka Stevens St',
      pickupPhone: '+232 76 112233',
      dropoffAddress: '14 Wilkinson Road',
      pickupLat: 8.484,
      pickupLng: -13.234,
      dropoffLat: 8.460,
      dropoffLng: -13.250,
      items: const [],
      subtotal: 450000.0,
      riderEarnings: 14.80,
      distanceKm: 2.1,
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
    when(() => mockGetHistory(statusFilter: any(named: 'statusFilter')))
        .thenAnswer((_) async => const Right([]));

    controller = OrdersController(
      getActiveOrdersUseCase: mockGetActiveOrders,
      updateOrderStatusUseCase: mockUpdateStatus,
      cancelTripUseCase: mockCancelTrip,
      getOrderHistoryUseCase: mockGetHistory,
      getOrderDetailsUseCase: mockGetDetails,
    );
    Get.put<OrdersController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('ActiveOrderView Part 8 Cancellation UI Tests', () {
    testWidgets('renders Cancel Delivery button when status is ACCEPTED', (tester) async {
      controller.selectedOrder.value = buildOrderWithStatus(OrderStatus.accepted);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );

      expect(find.byKey(const Key('active_order_cancel_button')), findsOneWidget);
      expect(find.text('Cancel Delivery'), findsOneWidget);
    });

    testWidgets('renders Cancel Delivery button when status is AT_PICKUP', (tester) async {
      controller.selectedOrder.value = buildOrderWithStatus(OrderStatus.atPickup);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );

      expect(find.byKey(const Key('active_order_cancel_button')), findsOneWidget);
      expect(find.text('Cancel Delivery'), findsOneWidget);
    });

    testWidgets('HIDES Cancel Delivery button when status is PICKED_UP (Possession Security Rule)', (tester) async {
      controller.selectedOrder.value = buildOrderWithStatus(OrderStatus.pickedUp);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );

      expect(find.byKey(const Key('active_order_cancel_button')), findsNothing);
      expect(find.text('Cancel Delivery'), findsNothing);
    });

    testWidgets('HIDES Cancel Delivery button when status is OUT_FOR_DELIVERY', (tester) async {
      controller.selectedOrder.value = buildOrderWithStatus(OrderStatus.outForDelivery);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );

      expect(find.byKey(const Key('active_order_cancel_button')), findsNothing);
      expect(find.text('Cancel Delivery'), findsNothing);
    });

    testWidgets('tapping Cancel Delivery button opens CancelDeliveryDialog', (tester) async {
      controller.selectedOrder.value = buildOrderWithStatus(OrderStatus.accepted);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );

      await tester.tap(find.byKey(const Key('active_order_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.byType(CancelDeliveryDialog), findsOneWidget);
      expect(find.text('Cancel Delivery'), findsWidgets);
      expect(find.text('Vehicle breakdown'), findsOneWidget);
    });

    testWidgets('OrdersController.cancelTrip calls CancelTripUseCase and clears active order', (tester) async {
      final order = buildOrderWithStatus(OrderStatus.accepted);
      controller.selectedOrder.value = order;

      final cancelledOrder = order.copyWith(status: OrderStatus.cancelled);
      when(() => mockCancelTrip(order.id, 'Vehicle breakdown'))
          .thenAnswer((_) async => Right(cancelledOrder));

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/test',
          getPages: [
            GetPage(
              name: '/test',
              page: () => const Scaffold(body: Text('Test Screen')),
            ),
            GetPage(
              name: AppRoutes.main,
              page: () => const Scaffold(body: Text('Main Screen')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await controller.cancelTrip('Vehicle breakdown');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      verify(() => mockCancelTrip(order.id, 'Vehicle breakdown')).called(1);
      expect(controller.selectedOrder.value, isNull);
    });

    testWidgets('ActiveOrderView falls back to DashboardController.activeOrder when selectedOrder is null', (tester) async {
      controller.selectedOrder.value = null;

      final mockToggleOnline = MockToggleOnlineStatusUseCase();
      final mockGetSummary = MockGetDashboardSummaryUseCase();
      final mockGetIncomingOrder = MockGetIncomingOrderUseCase();
      final mockAcceptOrder = MockAcceptOrderUseCase();
      final mockDeclineOrder = MockDeclineOrderUseCase();

      when(() => mockGetSummary()).thenAnswer((_) async => const Right({}));
      final dashController = DashboardController(
        toggleOnlineStatusUseCase: mockToggleOnline,
        getDashboardSummaryUseCase: mockGetSummary,
        getActiveOrdersUseCase: mockGetActiveOrders,
        getIncomingOrderUseCase: mockGetIncomingOrder,
        acceptOrderUseCase: mockAcceptOrder,
        declineOrderUseCase: mockDeclineOrder,
      );
      final activeOrder = buildOrderWithStatus(OrderStatus.accepted);
      dashController.activeOrder.value = activeOrder;
      Get.put<DashboardController>(dashController);

      await tester.pumpWidget(
        const GetMaterialApp(
          home: ActiveOrderView(),
        ),
      );
      await tester.pump();

      expect(find.text('No active delivery order'), findsNothing);
      expect(find.text('MEEEM Super Store'), findsOneWidget);
      expect(find.byKey(const Key('active_order_cancel_button')), findsOneWidget);
    });

    testWidgets('acceptIncomingOrder sets OrdersController.selectedOrder and navigates', (tester) async {
      final mockToggleOnline = MockToggleOnlineStatusUseCase();
      final mockGetSummary = MockGetDashboardSummaryUseCase();
      final mockGetIncomingOrder = MockGetIncomingOrderUseCase();
      final mockAcceptOrder = MockAcceptOrderUseCase();
      final mockDeclineOrder = MockDeclineOrderUseCase();

      when(() => mockGetSummary()).thenAnswer((_) async => const Right({}));
      final dashController = DashboardController(
        toggleOnlineStatusUseCase: mockToggleOnline,
        getDashboardSummaryUseCase: mockGetSummary,
        getActiveOrdersUseCase: mockGetActiveOrders,
        getIncomingOrderUseCase: mockGetIncomingOrder,
        acceptOrderUseCase: mockAcceptOrder,
        declineOrderUseCase: mockDeclineOrder,
      );
      Get.put<DashboardController>(dashController);

      final incoming = buildOrderWithStatus(OrderStatus.pending).copyWith(id: 'order_inc_123', assignmentId: 'asgn_123');
      dashController.incomingOrder.value = incoming;

      final accepted = incoming.copyWith(status: OrderStatus.accepted);
      when(() => mockAcceptOrder('asgn_123')).thenAnswer((_) async => Right(accepted));

      expect(controller.selectedOrder.value, isNull);

      await dashController.acceptIncomingOrder();

      expect(controller.selectedOrder.value, isNotNull);
      expect(controller.selectedOrder.value?.id, 'order_inc_123');
      expect(controller.selectedOrder.value?.status, OrderStatus.accepted);
    });
  });
}
