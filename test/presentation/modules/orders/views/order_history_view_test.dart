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
import 'package:meeem_rider/presentation/modules/orders/views/order_history_view.dart';

class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
class MockCancelTripUseCase extends Mock implements CancelTripUseCase {}
class MockGetOrderHistoryUseCase extends Mock implements GetOrderHistoryUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;
  late MockCancelTripUseCase mockCancelTrip;
  late MockGetOrderHistoryUseCase mockGetHistory;
  late MockGetOrderDetailsUseCase mockGetDetails;
  late OrdersController controller;

  final activeOrder = OrderEntity(
    id: 'ord_active_1',
    orderNumber: 'meeem00000042',
    status: OrderStatus.outForDelivery,
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
    subtotal: 450000,
    riderEarnings: 14.80,
    distanceKm: 2.1,
    estimatedDurationMin: 15,
    createdAt: DateTime.now(),
  );

  final deliveredOrder = OrderEntity(
    id: 'ord_delivered_1',
    orderNumber: 'meeem00000030',
    status: OrderStatus.delivered,
    customerName: 'Amadu Kamara',
    customerPhone: '+232 78 112233',
    customerAvatar: '',
    pickupName: 'Tokeh Seafood Shack',
    pickupAddress: 'Beach Road, Tokeh',
    pickupPhone: '+232 77 223344',
    dropoffAddress: 'Baw Baw Point #2',
    pickupLat: 8.350,
    pickupLng: -13.150,
    dropoffLat: 8.360,
    dropoffLng: -13.160,
    items: const [],
    subtotal: 420000,
    riderEarnings: 15.00,
    distanceKm: 3.5,
    estimatedDurationMin: 25,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final cancelledOrder = OrderEntity(
    id: 'ord_cancelled_1',
    orderNumber: 'meeem00000015',
    status: OrderStatus.cancelled,
    customerName: 'Kallon S.',
    customerPhone: '+232 79 334455',
    customerAvatar: '',
    pickupName: 'Freetown Fresh Market',
    pickupAddress: '88 Circular Road',
    pickupPhone: '+232 76 556677',
    dropoffAddress: 'Hill Station',
    pickupLat: 8.470,
    pickupLng: -13.220,
    dropoffLat: 8.450,
    dropoffLng: -13.230,
    items: const [],
    subtotal: 210000,
    riderEarnings: 0.0,
    distanceKm: 4.0,
    estimatedDurationMin: 30,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  setUp(() {
    Get.reset();

    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockUpdateStatus = MockUpdateOrderStatusUseCase();
    mockCancelTrip = MockCancelTripUseCase();
    mockGetHistory = MockGetOrderHistoryUseCase();
    mockGetDetails = MockGetOrderDetailsUseCase();

    when(() => mockGetActiveOrders()).thenAnswer((_) async => Right([activeOrder]));
    when(() => mockGetHistory(statusFilter: any(named: 'statusFilter')))
        .thenAnswer((_) async => Right([deliveredOrder, cancelledOrder]));

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

  testWidgets('renders My Deliveries title, all 4 filter chips, and both active + delivered orders under All', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: OrderHistoryView()));
    await tester.pumpAndSettle();

    expect(find.text('My Deliveries'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Active'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Delivered'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Cancelled'), findsOneWidget);

    // Both active and delivered orders should be listed under 'All'
    expect(find.text('#meeem00000042'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('MEEEM Super Store'), findsOneWidget);

    expect(find.text('#meeem00000030'), findsOneWidget);
    expect(find.text('Tokeh Seafood Shack'), findsOneWidget);
  });

  testWidgets('tapping Delivered chip filters to only delivered orders', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: OrderHistoryView()));
    await tester.pumpAndSettle();

    // Tap 'Delivered' ChoiceChip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Delivered'));
    await tester.pumpAndSettle();

    // Only delivered order visible
    expect(find.text('#meeem00000030'), findsOneWidget);
    expect(find.text('#meeem00000042'), findsNothing);
  });

  testWidgets('renders rich empty state with refresh button when no orders match filter', (tester) async {
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
    Get.replace<OrdersController>(controller);

    await tester.pumpWidget(const GetMaterialApp(home: OrderHistoryView()));
    await tester.pumpAndSettle();

    expect(find.text('No orders found'), findsOneWidget);
    expect(find.text('Refresh Deliveries'), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

    // Tap Refresh Deliveries button
    await tester.tap(find.text('Refresh Deliveries'));
    await tester.pump();
    verify(() => mockGetActiveOrders()).called(greaterThanOrEqualTo(1));
  });
}
