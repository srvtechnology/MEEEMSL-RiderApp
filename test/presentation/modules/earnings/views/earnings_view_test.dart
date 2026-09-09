import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/rider_revenue_entity.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_rider_revenue_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/request_payout_usecase.dart';
import 'package:meeem_rider/presentation/modules/earnings/controllers/earnings_controller.dart';
import 'package:meeem_rider/presentation/modules/earnings/views/earnings_view.dart';
import 'package:meeem_rider/presentation/modules/earnings/widgets/revenue_delivery_card.dart';
import 'package:meeem_rider/presentation/modules/earnings/widgets/revenue_kpi_card.dart';

class MockGetRiderRevenueUseCase extends Mock implements GetRiderRevenueUseCase {}
class MockGetEarningsBreakdownUseCase extends Mock implements GetEarningsBreakdownUseCase {}
class MockRequestPayoutUseCase extends Mock implements RequestPayoutUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetRiderRevenueUseCase mockGetRevenue;
  late MockGetEarningsBreakdownUseCase mockGetEarnings;
  late MockRequestPayoutUseCase mockRequestPayout;

  const sampleSummary = RiderRevenueSummaryEntity(
    totalDeliveredRevenue: 125000,
    pendingInProgressRevenue: 35000,
    deliveredCount: 5,
    inProgressCount: 2,
    totalDeliveriesCount: 7,
    currency: 'NLe',
  );

  final deliveredOrder = RiderRevenueDeliveryEntity(
    id: 'cly1234567890',
    assignmentId: 'cly1234567890',
    orderId: 'order_abc123',
    orderNumber: 'meeem00000042',
    status: 'DELIVERED',
    statusCategory: 'DELIVERED',
    isDelivered: true,
    offeredAt: DateTime.now().subtract(const Duration(hours: 3)),
    deliveredAt: DateTime.now().subtract(const Duration(hours: 2)),
    deliveryOtp: '482910',
    deliveryProofImage: 'https://example.com/proof.jpg',
    distanceKm: 4.2,
    deliveryCharge: 25000,
    totalAmount: 25000,
    store: const RevenueStoreEntity(
      name: 'Kroo Town Electronics',
      address: '14 Kroo Town Road, Central, Freetown',
    ),
    customer: const RevenueCustomerEntity(
      name: 'Amadu Kamara',
      dropAddress: '22 Siaka Stevens Street, Freetown',
    ),
    items: const [
      RevenueOrderItemEntity(
        id: 'item_line_01',
        name: 'Heavy Duty Shockproof Case',
        quantity: 1,
        price: 120000,
        shippingAmount: 15000,
      ),
    ],
    totalItemsCount: 1,
  );

  final inProgressOrder = RiderRevenueDeliveryEntity(
    id: 'cly9876543210',
    assignmentId: 'cly9876543210',
    orderId: 'order_def456',
    orderNumber: 'meeem00000045',
    status: 'OUT_FOR_DELIVERY',
    statusCategory: 'IN_PROGRESS',
    isDelivered: false,
    offeredAt: DateTime.now().subtract(const Duration(minutes: 40)),
    distanceKm: 6.1,
    deliveryCharge: 35000,
    totalAmount: null, // Critical Part 6 rule: null when in-progress
    store: const RevenueStoreEntity(
      name: 'Lumley Fashion Store',
      address: '55 Lumley Beach Road, Freetown',
    ),
    customer: const RevenueCustomerEntity(
      name: 'Fatmata Sesay',
      dropAddress: '12 Wilkinson Road, Freetown',
    ),
    items: const [
      RevenueOrderItemEntity(
        id: 'item_line_03',
        name: 'Summer Floral Midi Dress',
        quantity: 1,
        price: 250000,
        shippingAmount: 35000,
      ),
    ],
    totalItemsCount: 1,
  );

  final sampleData = RiderRevenueDataEntity(
    summary: sampleSummary,
    filters: const RiderRevenueFiltersEntity(),
    count: 2,
    deliveries: [deliveredOrder, inProgressOrder],
  );

  setUp(() {
    Get.reset();
    mockGetRevenue = MockGetRiderRevenueUseCase();
    mockGetEarnings = MockGetEarningsBreakdownUseCase();
    mockRequestPayout = MockRequestPayoutUseCase();

    when(() => mockGetRevenue(
          status: any(named: 'status'),
          period: any(named: 'period'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => Right(sampleData));

    when(() => mockGetEarnings(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Disabled')));

    Get.put<EarningsController>(EarningsController(
      getRiderRevenueUseCase: mockGetRevenue,
      getEarningsBreakdownUseCase: mockGetEarnings,
      requestPayoutUseCase: mockRequestPayout,
    ));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('EarningsView renders KPI cards, status tabs, period chips, and delivery cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: EarningsView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Top KPI Summary Cards (Section 5.1)
    expect(find.byType(RevenueKpiCard), findsNWidgets(2));
    expect(find.text('Total Delivered Revenue'), findsOneWidget);
    expect(find.text('In-Progress Potential'), findsOneWidget);
    expect(find.text('NLe 125,000'), findsOneWidget);
    expect(find.text('NLe 35,000'), findsNWidgets(2));

    // 2. Status Tabs (Section 5.2)
    expect(find.text('All (7)'), findsOneWidget);
    expect(find.text('Delivered (5)'), findsOneWidget);
    expect(find.text('In Progress (2)'), findsOneWidget);

    // 3. Period Chips (Section 5.2)
    expect(find.text('All Time'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);

    // 4. Delivery Cards (Section 5.3)
    expect(find.byType(RevenueDeliveryCard), findsNWidgets(2));
    expect(find.text('#meeem00000042'), findsOneWidget);
    expect(find.text('#meeem00000045'), findsOneWidget);

    // 5. Section 5.4 Total Realized Amount Rule:
    // Green badge for Delivered: "Total Earned: Nle 25,000"
    expect(find.textContaining('Total Earned'), findsOneWidget);

    // Amber badge for In-Progress: "Pending (Upon Delivery)"
    expect(find.text('Pending (Upon Delivery)'), findsOneWidget);
  });
}
