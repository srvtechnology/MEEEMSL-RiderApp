import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/widgets/custom_text_field.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/entities/rider_revenue_entity.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_rider_revenue_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/request_payout_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_details_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_history_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/presentation/modules/earnings/controllers/earnings_controller.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}
class MockGetOrderHistoryUseCase extends Mock implements GetOrderHistoryUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}
class MockGetRiderRevenueUseCase extends Mock implements GetRiderRevenueUseCase {}
class MockGetEarningsBreakdownUseCase extends Mock implements GetEarningsBreakdownUseCase {}
class MockRequestPayoutUseCase extends Mock implements RequestPayoutUseCase {}
class MockToggleOnlineStatusUseCase extends Mock implements ToggleOnlineStatusUseCase {}
class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}
class MockGetIncomingOrderUseCase extends Mock implements GetIncomingOrderUseCase {}
class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}
class MockDeclineOrderUseCase extends Mock implements DeclineOrderUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;
  late MockGetOrderHistoryUseCase mockGetHistory;
  late MockGetOrderDetailsUseCase mockGetDetails;

  late MockGetRiderRevenueUseCase mockGetRevenue;
  late MockGetEarningsBreakdownUseCase mockGetEarnings;
  late MockRequestPayoutUseCase mockRequestPayout;

  late MockToggleOnlineStatusUseCase mockToggleOnline;
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetIncomingOrderUseCase mockGetIncomingOrder;
  late MockAcceptOrderUseCase mockAcceptOrder;
  late MockDeclineOrderUseCase mockDeclineOrder;

  late OrdersController ordersController;

  final sampleOrder = OrderEntity(
    id: 'cuid_order_42',
    orderNumber: 'meeem00000042',
    status: OrderStatus.outForDelivery,
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
    subtotal: 450000,
    riderEarnings: 25000,
    distanceKm: 2.1,
    estimatedDurationMin: 15,
    createdAt: DateTime.now(),
    deliveryOtp: '482910',
  );

  final deliveredOrder = OrderEntity(
    id: 'cuid_order_42',
    orderNumber: 'meeem00000042',
    status: OrderStatus.delivered,
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
    subtotal: 450000,
    riderEarnings: 25000,
    distanceKm: 2.1,
    estimatedDurationMin: 15,
    createdAt: DateTime.now(),
    deliveryOtp: '482910',
  );

  const sampleRevenueData = RiderRevenueDataEntity(
    summary: RiderRevenueSummaryEntity(
      totalDeliveredRevenue: 125000,
      pendingInProgressRevenue: 0,
      deliveredCount: 5,
      inProgressCount: 0,
      totalDeliveriesCount: 5,
      currency: 'NLe',
    ),
    filters: RiderRevenueFiltersEntity(),
    count: 1,
    deliveries: [],
  );

  setUp(() {
    Get.reset();

    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockUpdateStatus = MockUpdateOrderStatusUseCase();
    mockGetHistory = MockGetOrderHistoryUseCase();
    mockGetDetails = MockGetOrderDetailsUseCase();

    mockGetRevenue = MockGetRiderRevenueUseCase();
    mockGetEarnings = MockGetEarningsBreakdownUseCase();
    mockRequestPayout = MockRequestPayoutUseCase();

    mockToggleOnline = MockToggleOnlineStatusUseCase();
    mockGetSummary = MockGetDashboardSummaryUseCase();
    mockGetIncomingOrder = MockGetIncomingOrderUseCase();
    mockAcceptOrder = MockAcceptOrderUseCase();
    mockDeclineOrder = MockDeclineOrderUseCase();

    when(() => mockGetActiveOrders()).thenAnswer((_) async => Right([sampleOrder]));
    when(() => mockGetHistory()).thenAnswer((_) async => const Right([]));
    when(() => mockUpdateStatus(
          any(),
          OrderStatus.delivered,
          proofPhotoUrl: any(named: 'proofPhotoUrl'),
          customerOtp: any(named: 'customerOtp'),
        )).thenAnswer((_) async => Right(deliveredOrder));

    when(() => mockGetRevenue(
          status: any(named: 'status'),
          period: any(named: 'period'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => const Right(sampleRevenueData));

    when(() => mockGetEarnings(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Disabled')));

    when(() => mockGetSummary()).thenAnswer((_) async => const Right({
          'todayEarnings': 25000.0,
          'todayDeliveries': 1,
          'totalTrips': 5,
          'totalEarnings': 125000.0,
        }));

    Get.put<EarningsController>(EarningsController(
      getRiderRevenueUseCase: mockGetRevenue,
      getEarningsBreakdownUseCase: mockGetEarnings,
      requestPayoutUseCase: mockRequestPayout,
    ));

    Get.put<DashboardController>(DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
    ));

    ordersController = Get.put<OrdersController>(OrdersController(
      getActiveOrdersUseCase: mockGetActiveOrders,
      updateOrderStatusUseCase: mockUpdateStatus,
      getOrderHistoryUseCase: mockGetHistory,
      getOrderDetailsUseCase: mockGetDetails,
    ));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
      'Checklist #8: Delivery OTP completion immediately refreshes revenue & credits earnings',
      (WidgetTester tester) async {
    ordersController.selectedOrder.value = sampleOrder;

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/test',
        getPages: [
          GetPage(
            name: '/test',
            page: () => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => ordersController.advanceActiveOrderStatus(),
                  child: const Text('Complete Drop'),
                ),
              ),
            ),
          ),
          GetPage(
            name: AppRoutes.main,
            page: () => const Scaffold(body: Center(child: Text('Main Screen'))),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Clear interactions after initialization
    clearInteractions(mockGetRevenue);
    clearInteractions(mockGetSummary);

    // Tap Complete Drop -> opens DeliveryProofDialog
    await tester.tap(find.text('Complete Drop'));
    await tester.pumpAndSettle();

    // Enter valid 6-digit OTP
    final otpField = find.byType(CustomTextField);
    expect(otpField, findsOneWidget);
    await tester.enterText(otpField, '482910');
    await tester.pumpAndSettle();

    // Tap Verify OTP & Complete Delivery button
    final confirmBtn = find.text('Verify OTP & Complete Delivery');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify updateOrderStatus was called with delivered status and OTP
    verify(() => mockUpdateStatus(
          sampleOrder.id,
          OrderStatus.delivered,
          proofPhotoUrl: any(named: 'proofPhotoUrl'),
          customerOtp: '482910',
        )).called(1);

    // Verify EarningsController.loadRevenue was triggered
    verify(() => mockGetRevenue(
          status: any(named: 'status'),
          period: any(named: 'period'),
          search: any(named: 'search'),
        )).called(1);

    // Verify DashboardController was reloaded
    verify(() => mockGetSummary()).called(1);

    // Pump timer for snackbar to settle and dismiss
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
