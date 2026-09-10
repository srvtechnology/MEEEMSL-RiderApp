import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/presentation/modules/dashboard/views/dashboard_view.dart';
import 'package:meeem_rider/presentation/modules/dashboard/widgets/active_delivery_card.dart';
import 'package:meeem_rider/presentation/modules/dashboard/widgets/incoming_offer_card.dart';
import 'package:meeem_rider/presentation/modules/dashboard/widgets/telemetry_radar_card.dart';

class MockToggleOnlineStatusUseCase extends Mock
    implements ToggleOnlineStatusUseCase {}

class MockGetDashboardSummaryUseCase extends Mock
    implements GetDashboardSummaryUseCase {}

class MockGetActiveOrdersUseCase extends Mock
    implements GetActiveOrdersUseCase {}

class MockGetIncomingOrderUseCase extends Mock
    implements GetIncomingOrderUseCase {}

class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}

class MockDeclineOrderUseCase extends Mock implements DeclineOrderUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockToggleOnlineStatusUseCase mockToggleOnline;
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockGetIncomingOrderUseCase mockGetIncomingOrder;
  late MockAcceptOrderUseCase mockAcceptOrder;
  late MockDeclineOrderUseCase mockDeclineOrder;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;
  late DashboardController controller;

  final sampleOrder = OrderEntity(
    id: 'cuid_order_42',
    orderNumber: 'meeem00000042',
    status: OrderStatus.atPickup,
    customerName: 'Fatmata Koroma',
    customerPhone: '+23276123456',
    customerAvatar: '',
    pickupName: 'MEEEM Super Store',
    pickupAddress: '25 Siaka Stevens St',
    pickupPhone: '+23277987654',
    dropoffAddress: '14 Wilkinson Road, Freetown',
    pickupLat: 8.484,
    pickupLng: -13.234,
    dropoffLat: 8.481,
    dropoffLng: -13.240,
    items: const [],
    subtotal: 450.0,
    riderEarnings: 14.80,
    distanceKm: 2.1,
    estimatedDurationMin: 18,
    createdAt: DateTime.now(),
    notes: 'Fragile electronics',
    deliveryOtp: '582910',
  );

  setUp(() {
    Get.testMode = true;
    mockToggleOnline = MockToggleOnlineStatusUseCase();
    mockGetSummary = MockGetDashboardSummaryUseCase();
    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockGetIncomingOrder = MockGetIncomingOrderUseCase();
    mockAcceptOrder = MockAcceptOrderUseCase();
    mockDeclineOrder = MockDeclineOrderUseCase();
    mockUpdateStatus = MockUpdateOrderStatusUseCase();

    when(() => mockGetSummary()).thenAnswer(
      (_) async => const Right({
        'todayEarnings': 148.50,
        'todayDeliveries': 9,
        'totalTrips': 1420,
        'acceptanceRate': 96.5,
        'rating': 4.92,
        'onlineHours': 5.8,
      }),
    );
    when(() => mockGetActiveOrders()).thenAnswer((_) async => const Right([]));
    when(() => mockToggleOnline(any())).thenAnswer((_) async => const Right(true));

    controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
      updateOrderStatusUseCase: mockUpdateStatus,
    );
    Get.put<DashboardController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('DashboardView defaults to offline state on load/start',
      (WidgetTester tester) async {
    expect(controller.isOnline.value, isFalse);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("You're Offline"), findsOneWidget);
    expect(find.text('Shift is Currently Paused'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byType(TelemetryRadarCard), findsNothing);
  });

  testWidgets('DashboardView renders header and status strip without earnings/metrics components',
      (WidgetTester tester) async {
    controller.isOnline.value = true;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Rider Name & Status
    expect(find.text('Ibrahim Koroma'), findsOneWidget);
    expect(find.text("You're Online"), findsOneWidget);
    // Verify earnings card and metrics grid have been removed
    expect(find.text("Today's Earnings"), findsNothing);
    expect(find.text('Total Lifetime Earnings'), findsNothing);
    expect(find.text('Trips Today'), findsNothing);
    expect(find.text('Online Hours'), findsNothing);
  });

  testWidgets(
      'DashboardView renders TelemetryRadarCard when online with no active order',
      (WidgetTester tester) async {
    controller.isOnline.value = true;
    controller.activeOrder.value = null;
    controller.incomingOrder.value = null;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TelemetryRadarCard), findsOneWidget);
    expect(find.text('Auto-Dispatch Radar Active'), findsOneWidget);
  });

  testWidgets(
      'DashboardView renders ActiveDeliveryCard when activeOrder is present',
      (WidgetTester tester) async {
    controller.activeOrder.value = sampleOrder;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ActiveDeliveryCard), findsOneWidget);
    expect(find.text('#meeem00000042'), findsOneWidget);
    expect(find.text('MEEEM Super Store'), findsOneWidget);
    expect(find.text('Fatmata Koroma'), findsOneWidget);
    expect(find.text('Confirm Items Picked Up'), findsOneWidget);
  });

  testWidgets(
      'DashboardView renders IncomingOfferCard with countdown when incomingOrder is present',
      (WidgetTester tester) async {
    controller.incomingOrder.value = sampleOrder;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(IncomingOfferCard), findsOneWidget);
    expect(find.text('NEW WATERFALL OFFER'), findsOneWidget);
    expect(find.text('Accept Offer'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });
}
