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

class MockGetRiderRevenueUseCase extends Mock implements GetRiderRevenueUseCase {}

class MockGetEarningsBreakdownUseCase extends Mock
    implements GetEarningsBreakdownUseCase {}

class MockRequestPayoutUseCase extends Mock implements RequestPayoutUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetRiderRevenueUseCase mockGetRevenue;
  late MockGetEarningsBreakdownUseCase mockGetEarnings;
  late MockRequestPayoutUseCase mockRequestPayout;
  late EarningsController controller;

  const sampleSummary = RiderRevenueSummaryEntity(
    totalDeliveredRevenue: 125000,
    pendingInProgressRevenue: 35000,
    deliveredCount: 5,
    inProgressCount: 2,
    totalDeliveriesCount: 7,
    currency: 'NLe',
  );

  final sampleDelivery = RiderRevenueDeliveryEntity(
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

  final sampleData = RiderRevenueDataEntity(
    summary: sampleSummary,
    filters: const RiderRevenueFiltersEntity(),
    count: 1,
    deliveries: [sampleDelivery],
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

    controller = EarningsController(
      getRiderRevenueUseCase: mockGetRevenue,
      getEarningsBreakdownUseCase: mockGetEarnings,
      requestPayoutUseCase: mockRequestPayout,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('EarningsController Part 6 Tests', () {
    test('loadRevenue successfully populates revenueData', () async {
      await controller.loadRevenue();

      expect(controller.revenueData.value, isNotNull);
      expect(controller.revenueData.value?.summary.totalDeliveredRevenue, equals(125000));
      expect(controller.revenueData.value?.summary.pendingInProgressRevenue, equals(35000));
      expect(controller.revenueData.value?.deliveries.first.orderNumber, equals('meeem00000042'));
    });

    test('setStatusFilter changes selectedStatus and triggers loadRevenue', () async {
      controller.setStatusFilter('delivered');

      expect(controller.selectedStatus.value, equals('delivered'));
      verify(() => mockGetRevenue(
            status: 'delivered',
            period: 'all',
            search: '',
          )).called(1);
    });

    test('setPeriodFilter changes selectedPeriod and triggers loadRevenue', () async {
      controller.setPeriodFilter('week');

      expect(controller.selectedPeriod.value, equals('week'));
      verify(() => mockGetRevenue(
            status: 'all',
            period: 'week',
            search: '',
          )).called(1);
    });

    test('setSearchQuery updates searchQuery and triggers reload', () async {
      controller.setSearchQuery('42');

      expect(controller.searchQuery.value, equals('42'));
      verify(() => mockGetRevenue(
            status: 'all',
            period: 'all',
            search: '42',
          )).called(1);
    });
  });
}
