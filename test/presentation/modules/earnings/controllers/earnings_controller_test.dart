import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/rider_ledger_entity.dart';
import 'package:meeem_rider/domain/entities/rider_revenue_entity.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_balance_transactions_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_payout_requests_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_rider_revenue_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/request_payout_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/submit_payout_request_usecase.dart';
import 'package:meeem_rider/presentation/modules/earnings/controllers/earnings_controller.dart';

class MockGetRiderRevenueUseCase extends Mock implements GetRiderRevenueUseCase {}

class MockGetEarningsBreakdownUseCase extends Mock
    implements GetEarningsBreakdownUseCase {}

class MockRequestPayoutUseCase extends Mock implements RequestPayoutUseCase {}

class MockGetBalanceTransactionsUseCase extends Mock
    implements GetBalanceTransactionsUseCase {}

class MockGetPayoutRequestsUseCase extends Mock
    implements GetPayoutRequestsUseCase {}

class MockSubmitPayoutRequestUseCase extends Mock
    implements SubmitPayoutRequestUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetRiderRevenueUseCase mockGetRevenue;
  late MockGetEarningsBreakdownUseCase mockGetEarnings;
  late MockRequestPayoutUseCase mockRequestPayout;
  late MockGetBalanceTransactionsUseCase mockGetLedger;
  late MockGetPayoutRequestsUseCase mockGetPayouts;
  late MockSubmitPayoutRequestUseCase mockSubmitPayout;
  late EarningsController controller;

  const sampleSummary = RiderRevenueSummaryEntity(
    netBalance: 450,
    availablePayoutBalance: 450,
    totalDeliveredRevenue: 1200,
    prepaidDeliveredRevenue: 750,
    codDeliveredRevenue: 450,
    codCashCollectedTotal: 6850,
    pendingInProgressRevenue: 200,
    deliveredCount: 12,
    inProgressCount: 2,
    totalDeliveriesCount: 14,
    currency: 'NLe',
    hasPendingPayoutRequest: false,
  );

  final sampleDelivery = RiderRevenueDeliveryEntity(
    id: 'cly1234567890',
    assignmentId: 'cly1234567890',
    orderId: 'order_abc123',
    orderNumber: 'meeem00000042',
    status: 'DELIVERED',
    statusCategory: 'DELIVERED',
    isDelivered: true,
    paymentMethod: 'AFRIMONEY',
    settlementStatus: 'YET_TO_PAY',
    offeredAt: DateTime.now().subtract(const Duration(hours: 3)),
    deliveredAt: DateTime.now().subtract(const Duration(hours: 2)),
    deliveryOtp: '482910',
    deliveryProofImage: 'https://example.com/proof.jpg',
    distanceKm: 4.2,
    deliveryCharge: 75,
    totalAmount: 75,
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
        price: 750,
        shippingAmount: 75,
      ),
    ],
    totalItemsCount: 1,
  );

  final sampleData = RiderRevenueDataEntity(
    summary: sampleSummary,
    riderBankDetails: const RiderBankDetailsEntity(
      paymentOption: 'Mobile Money',
      preferredPayoutMethod: 'AfriMoney',
      accountHolderName: 'John Kamara',
      mobileNumber: '077123456',
      mobileMoneyOption: 'AfriMoney',
    ),
    filters: const RiderRevenueFiltersEntity(),
    count: 1,
    deliveries: [sampleDelivery],
  );

  final sampleLedger = RiderBalanceLedgerEntity(
    netBalance: 450,
    balanceCreditsTotal: 1200,
    balanceDebitsTotal: 300,
    transactions: [
      RiderBalanceTransactionEntity(
        id: 'tx-1',
        amount: 75,
        kind: 'CREDIT',
        reason: 'DELIVERY_FULFILLED',
        note: 'Prepaid AfriMoney delivery fee credited',
        createdAt: DateTime(2026, 11, 10, 14, 22),
        orderNumber: 'ORD-20261110-001',
        paymentMethod: 'AFRIMONEY',
        settlementStatus: 'YET_TO_PAY',
      ),
      RiderBalanceTransactionEntity(
        id: 'tx-2',
        amount: 50,
        kind: 'CREDIT',
        reason: 'COD_DELIVERY_COLLECTED',
        note: 'COD delivery completed (Cash in Hand)',
        createdAt: DateTime(2026, 11, 10, 12, 10),
        orderNumber: 'ORD-20261110-002',
        paymentMethod: 'COD',
        settlementStatus: 'COD_COLLECTED_BY_RIDER',
      ),
      RiderBalanceTransactionEntity(
        id: 'tx-3',
        amount: 300,
        kind: 'DEBIT',
        reason: 'PAYOUT_DISBURSED',
        note: 'Disbursed via AfriMoney. Ref: AFRI-PAY-99881',
        createdAt: DateTime(2026, 11, 9, 17, 0),
      ),
    ],
  );

  final samplePayoutStatus = RiderPayoutStatusEntity(
    netBalance: 450,
    payoutMethod: 'AfriMoney',
    payoutAccountSnapshot:
        'Method: Mobile Money • Holder: John Kamara • Mobile: 077123456 • Wallet: AfriMoney',
    pendingRequest: null,
    history: [
      RiderPayoutRequestEntity(
        id: 'req-1',
        requestedAmount: 300,
        status: 'DISBURSED',
        payoutMethod: 'AfriMoney',
        payoutReference: 'AFRI-PAY-99881',
        requestedAt: DateTime(2026, 11, 9, 15, 0),
        disbursedAt: DateTime(2026, 11, 9, 17, 0),
      ),
    ],
  );

  setUp(() {
    Get.reset();
    mockGetRevenue = MockGetRiderRevenueUseCase();
    mockGetEarnings = MockGetEarningsBreakdownUseCase();
    mockRequestPayout = MockRequestPayoutUseCase();
    mockGetLedger = MockGetBalanceTransactionsUseCase();
    mockGetPayouts = MockGetPayoutRequestsUseCase();
    mockSubmitPayout = MockSubmitPayoutRequestUseCase();

    when(() => mockGetRevenue(
          status: any(named: 'status'),
          period: any(named: 'period'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => Right(sampleData));

    when(() => mockGetEarnings(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Disabled')));

    when(() => mockGetLedger()).thenAnswer((_) async => Right(sampleLedger));
    when(() => mockGetPayouts()).thenAnswer((_) async => Right(samplePayoutStatus));

    controller = EarningsController(
      getRiderRevenueUseCase: mockGetRevenue,
      getEarningsBreakdownUseCase: mockGetEarnings,
      requestPayoutUseCase: mockRequestPayout,
      getBalanceTransactionsUseCase: mockGetLedger,
      getPayoutRequestsUseCase: mockGetPayouts,
      submitPayoutRequestUseCase: mockSubmitPayout,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('EarningsController Ledger, Wallet & Payout Tests', () {
    test('loadAll populates revenue, balance ledger, and payout status', () async {
      await controller.loadAll();

      expect(controller.revenueData.value, isNotNull);
      expect(controller.effectiveNetBalance, equals(450));
      expect(controller.canRequestPayout, isTrue);
      expect(controller.hasPendingPayout, isFalse);
      expect(controller.ledgerData.value?.transactions.length, equals(3));
      expect(controller.payoutStatus.value?.history.length, equals(1));
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

    test('filteredLedgerTransactions filters by reason cleanly', () async {
      await controller.loadBalanceTransactions();

      expect(controller.filteredLedgerTransactions.length, equals(3));

      controller.setLedgerFilter('COD_DELIVERY_COLLECTED');
      expect(controller.filteredLedgerTransactions.length, equals(1));
      expect(controller.filteredLedgerTransactions.first.isCodCollected, isTrue);

      controller.setLedgerFilter('PAYOUT_DISBURSED');
      expect(controller.filteredLedgerTransactions.length, equals(1));
      expect(controller.filteredLedgerTransactions.first.isDebit, isTrue);
    });

    test('submitPayoutRequest succeeds, sets pending state, and disables CTA', () async {
      await controller.loadAll();

      final pendingReq = RiderPayoutRequestEntity(
        id: 'req-2',
        requestedAmount: 450,
        status: 'PENDING',
        sellerNote: 'Send to AfriMoney 077123456',
        payoutMethod: 'AfriMoney',
        requestedAt: DateTime(2026, 11, 10, 16, 30),
      );

      when(() => mockSubmitPayout(sellerNote: any(named: 'sellerNote')))
          .thenAnswer((_) async => Right(pendingReq));
      when(() => mockGetPayouts()).thenAnswer((_) async => RiderPayoutStatusEntity(
            netBalance: 450,
            payoutMethod: 'AfriMoney',
            pendingRequest: pendingReq,
            history: [pendingReq, ...samplePayoutStatus.history],
          ).let((s) => Right(s)));

      final ok = await controller.submitPayoutRequest(
        sellerNote: 'Send to AfriMoney 077123456',
      );

      expect(ok, isTrue);
      expect(controller.hasPendingPayout, isTrue);
      expect(controller.canRequestPayout, isFalse);
      expect(controller.activePendingPayoutRequest?.id, equals('req-2'));
      verify(() => mockSubmitPayout(sellerNote: 'Send to AfriMoney 077123456')).called(1);
    });

    test('submitPayoutRequest blocks when netBalance <= 0 without calling API', () async {
      controller.revenueData.value = RiderRevenueDataEntity(
        summary: const RiderRevenueSummaryEntity(
          netBalance: 0,
          totalDeliveredRevenue: 450,
          codDeliveredRevenue: 450,
          pendingInProgressRevenue: 0,
          deliveredCount: 5,
          inProgressCount: 0,
          totalDeliveriesCount: 5,
        ),
        filters: const RiderRevenueFiltersEntity(),
        count: 0,
        deliveries: const [],
      );

      expect(controller.canRequestPayout, isFalse);
      final ok = await controller.submitPayoutRequest();
      expect(ok, isFalse);
      verifyNever(() => mockSubmitPayout(sellerNote: any(named: 'sellerNote')));
    });
  });
}

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
