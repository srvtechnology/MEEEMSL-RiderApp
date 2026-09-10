import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
import 'package:meeem_rider/presentation/modules/dashboard/widgets/active_delivery_card.dart';

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

  late DashboardController controller;

  final testOrder = OrderEntity(
    id: 'cuid_order_42',
    orderNumber: 'meeem00000042',
    status: OrderStatus.atPickup,
    customerName: 'Jeet Basak',
    customerPhone: '+23276123456',
    customerAvatar: '',
    pickupName: 'Apex Electronics & Lifestyle Store',
    pickupAddress: '124 Siaka Stevens Str, Freetown',
    pickupPhone: '+23277987654',
    dropoffAddress: 'Lumley Beach Road, Freetown',
    pickupLat: 8.484,
    pickupLng: -13.234,
    dropoffLat: 8.481,
    dropoffLng: -13.240,
    items: const [],
    subtotal: 450.0,
    riderEarnings: 150.00,
    distanceKm: 2.1,
    estimatedDurationMin: 18,
    createdAt: DateTime.now(),
    notes: 'Fragile electronics',
    deliveryOtp: '582910',
  );

  late MockToggleOnlineStatusUseCase mockToggleOnline;
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockGetIncomingOrderUseCase mockGetIncomingOrder;
  late MockAcceptOrderUseCase mockAcceptOrder;
  late MockDeclineOrderUseCase mockDeclineOrder;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;

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
        'todayEarnings': 150.0,
        'todayDeliveries': 0,
        'totalTrips': 0,
      }),
    );
    when(() => mockGetActiveOrders()).thenAnswer((_) async => const Right([]));

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

  testWidgets('ActiveDeliveryCard renders without overflow on standard 360px mobile width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ActiveDeliveryCard(order: testOrder),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('#meeem00000042'), findsOneWidget);
    expect(find.text('ARRIVED AT STORE'), findsOneWidget);
    expect(find.text('Delivery Earning: Nle 150.00'), findsOneWidget);
    expect(find.text('Confirm Items Picked Up'), findsOneWidget);
  });

  testWidgets('ActiveDeliveryCard renders without overflow on narrow 320px width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ActiveDeliveryCard(order: testOrder),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('#meeem00000042'), findsOneWidget);
    expect(find.text('ARRIVED AT STORE'), findsOneWidget);
    expect(find.text('Delivery Earning: Nle 150.00'), findsOneWidget);
  });
}
