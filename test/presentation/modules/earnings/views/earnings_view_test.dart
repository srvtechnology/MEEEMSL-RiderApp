import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/theme/app_theme.dart';
import 'package:meeem_rider/domain/entities/rider_ledger_entity.dart';
import 'package:meeem_rider/domain/entities/rider_revenue_entity.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_balance_transactions_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_payout_requests_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/get_rider_revenue_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/request_payout_usecase.dart';
import 'package:meeem_rider/domain/usecases/earnings/submit_payout_request_usecase.dart';
import 'package:meeem_rider/presentation/modules/earnings/controllers/earnings_controller.dart';
import 'package:meeem_rider/presentation/modules/earnings/views/earnings_view.dart';
import 'package:meeem_rider/presentation/modules/earnings/widgets/payout_request_bottom_sheet.dart';
import 'package:meeem_rider/presentation/modules/earnings/widgets/revenue_delivery_card.dart';
import 'package:meeem_rider/presentation/modules/earnings/widgets/revenue_kpi_card.dart';

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

  final prepaidDeliveredOrder = RiderRevenueDeliveryEntity(
    id: 'assign-1',
    assignmentId: 'assign-1',
    orderId: 'order-1',
    orderNumber: 'ORD-20261110-001',
    status: 'DELIVERED',
    statusCategory: 'DELIVERED',
    isDelivered: true,
    paymentMethod: 'AFRIMONEY',
    settlementStatus: 'YET_TO_PAY',
    offeredAt: DateTime(2026, 11, 10, 13, 40),
    deliveredAt: DateTime(2026, 11, 10, 14, 22),
    distanceKm: 4.2,
    deliveryCharge: 75,
    totalAmount: 75,
    store: const RevenueStoreEntity(
      name: 'Freetown Electronics',
      address: '14 Wilkinson Road, Freetown',
    ),
    customer: const RevenueCustomerEntity(
      name: 'Mariama Sesay',
      dropAddress: '22 Lumley Beach Road, Freetown',
    ),
    items: const [
      RevenueOrderItemEntity(
        id: 'item-1',
        name: 'Wireless Headphones',
        variantName: 'Black',
        quantity: 1,
        price: 750,
        shippingAmount: 75,
      ),
    ],
    totalItemsCount: 1,
  );

  final codDeliveredOrder = RiderRevenueDeliveryEntity(
    id: 'assign-2',
    assignmentId: 'assign-2',
    orderId: 'order-2',
    orderNumber: 'ORD-20261110-002',
    status: 'DELIVERED',
    statusCategory: 'DELIVERED',
    isDelivered: true,
    paymentMethod: 'COD',
    settlementStatus: 'COD_COLLECTED_BY_RIDER',
    codAmountCollected: 850,
    offeredAt: DateTime(2026, 11, 10, 11, 30),
    deliveredAt: DateTime(2026, 11, 10, 12, 10),
    distanceKm: 3.1,
    deliveryCharge: 50,
    totalAmount: 50,
    store: const RevenueStoreEntity(
      name: 'Wilkinson Health Pharmacy',
      address: '8 Wilkinson Road, Freetown',
    ),
    customer: const RevenueCustomerEntity(
      name: 'Mohamed Conteh',
      dropAddress: '4 Sanders Street, Central Freetown',
    ),
    items: const [
      RevenueOrderItemEntity(
        id: 'item-2',
        name: 'Vitamin C 1000mg',
        quantity: 2,
        price: 400,
        shippingAmount: 50,
      ),
    ],
    totalItemsCount: 2,
  );

  final inProgressOrder = RiderRevenueDeliveryEntity(
    id: 'assign-3',
    assignmentId: 'assign-3',
    orderId: 'order-3',
    orderNumber: 'ORD-20261110-003',
    status: 'OUT_FOR_DELIVERY',
    statusCategory: 'IN_PROGRESS',
    isDelivered: false,
    paymentMethod: 'AFRIMONEY',
    settlementStatus: 'PENDING',
    offeredAt: DateTime(2026, 11, 10, 15, 0),
    distanceKm: 6.1,
    deliveryCharge: 100,
    totalAmount: null,
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
        id: 'item-3',
        name: 'Summer Floral Midi Dress',
        quantity: 1,
        price: 500,
        shippingAmount: 100,
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
    count: 3,
    deliveries: [prepaidDeliveredOrder, codDeliveredOrder, inProgressOrder],
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
        note: 'Prepaid AfriMoney delivery fee credited for Order #ORD-20261110-001',
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
        note: 'Disbursed SLE 300.00 via AfriMoney. Ref: AFRI-PAY-99881',
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
        sellerNote: 'Weekly delivery fee withdrawal',
        payoutMethod: 'AfriMoney',
        payoutAccountSnapshot:
            'Method: Mobile Money • Holder: John Kamara • Mobile: 077123456 • Wallet: AfriMoney',
        payoutReference: 'AFRI-PAY-99881',
        adminNote: 'Sent to AfriMoney 077123456',
        requestedAt: DateTime(2026, 11, 9, 15, 0),
        disbursedAt: DateTime(2026, 11, 9, 17, 0),
      ),
    ],
  );

  void registerController({
    RiderRevenueDataEntity? revenueOverride,
    RiderPayoutStatusEntity? payoutOverride,
  }) {
    when(() => mockGetRevenue(
          status: any(named: 'status'),
          period: any(named: 'period'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => Right(revenueOverride ?? sampleData));

    when(() => mockGetEarnings(any()))
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Disabled')));

    when(() => mockGetLedger()).thenAnswer((_) async => Right(sampleLedger));
    when(() => mockGetPayouts())
        .thenAnswer((_) async => Right(payoutOverride ?? samplePayoutStatus));

    Get.put<EarningsController>(EarningsController(
      getRiderRevenueUseCase: mockGetRevenue,
      getEarningsBreakdownUseCase: mockGetEarnings,
      requestPayoutUseCase: mockRequestPayout,
      getBalanceTransactionsUseCase: mockGetLedger,
      getPayoutRequestsUseCase: mockGetPayouts,
      submitPayoutRequestUseCase: mockSubmitPayout,
    ));
  }

  setUp(() {
    Get.reset();
    mockGetRevenue = MockGetRiderRevenueUseCase();
    mockGetEarnings = MockGetEarningsBreakdownUseCase();
    mockRequestPayout = MockRequestPayoutUseCase();
    mockGetLedger = MockGetBalanceTransactionsUseCase();
    mockGetPayouts = MockGetPayoutRequestsUseCase();
    mockSubmitPayout = MockSubmitPayoutRequestUseCase();
  });

  tearDown(() {
    Get.closeAllSnackbars();
    Get.reset();
  });

  testWidgets(
      'EarningsView renders 4 KPI cards, settlement badges, and switches across Deliveries, Ledger, and Payouts tabs',
      (WidgetTester tester) async {
    registerController();

    await tester.pumpWidget(
      const GetMaterialApp(home: EarningsView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. All 4 top-level KPI cards + In-Progress Potential card
    expect(find.byType(WithdrawableWalletCard), findsOneWidget);
    expect(find.text('Withdrawable Wallet'), findsOneWidget);
    expect(find.text('Request Payout'), findsOneWidget);
    expect(find.text('Total Delivery Earnings'), findsOneWidget);
    expect(find.text('Prepaid (AfriMoney)'), findsOneWidget);
    expect(find.text('COD Earnings & Cash'), findsOneWidget);
    expect(find.text('Collected in Cash at Doorstep'), findsOneWidget);
    expect(find.text('Cash Collected: NLe 6,850'), findsOneWidget);
    expect(find.text('In-Progress Potential'), findsOneWidget);
    expect(find.byType(RevenueKpiCard), findsNWidgets(4));

    // Pending banner should NOT be shown when hasPendingPayoutRequest == false
    expect(find.byKey(const Key('pending_payout_amber_banner')), findsNothing);

    // Request Payout CTA should be enabled
    final ctaBtn = tester.widget<ElevatedButton>(
      find.byKey(const Key('request_payout_cta_button')),
    );
    expect(ctaBtn.onPressed, isNotNull);

    // 2. Delivery Settlement Breakdown cards with Payment Method & Settlement Status badges
    expect(find.byType(RevenueDeliveryCard), findsNWidgets(3));
    expect(find.text('#ORD-20261110-001'), findsOneWidget);
    expect(find.text('#ORD-20261110-002'), findsOneWidget);
    expect(find.text('AFRIMONEY (Prepaid)'), findsNWidgets(2));
    expect(find.text('COD (Cash)'), findsOneWidget);
    expect(find.text('Yet to Pay (In Wallet)'), findsOneWidget);
    expect(find.text('COD Collected (Cash in Hand)'), findsOneWidget);
    expect(find.text('COD Cash Collected (Doorstep)'), findsOneWidget);
    expect(find.text('Pending (Upon Delivery)'), findsOneWidget);

    // 3. Switch to Ledger tab
    await tester.ensureVisible(find.byKey(const Key('section_tab_ledger')));
    await tester.tap(find.byKey(const Key('section_tab_ledger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Ledger Audit Trail'), findsOneWidget);
    expect(find.text('Prepaid Delivery Credited'), findsOneWidget);
    expect(find.text('COD Delivery Fee Collected'), findsOneWidget);
    expect(find.text('CASH IN HAND • 0 Wallet Change'), findsOneWidget);
    expect(find.text('Payout Disbursed'), findsOneWidget);

    // 4. Switch to Payouts tab
    await tester.ensureVisible(find.byKey(const Key('section_tab_payouts')));
    await tester.tap(find.byKey(const Key('section_tab_payouts')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Payout Request History'), findsOneWidget);
    expect(find.text('DISBURSED'), findsOneWidget);
    expect(find.text('Ref: AFRI-PAY-99881'), findsOneWidget);
  });

  testWidgets(
      'Disables Request Payout button and displays amber banner when hasPendingPayoutRequest is true',
      (WidgetTester tester) async {
    final pendingReq = RiderPayoutRequestEntity(
      id: 'req-pending-1',
      requestedAmount: 450,
      status: 'PENDING',
      payoutMethod: 'AfriMoney',
      requestedAt: DateTime(2026, 11, 10, 16, 30),
    );

    final pendingSummary = RiderRevenueSummaryEntity(
      netBalance: 450,
      availablePayoutBalance: 450,
      totalDeliveredRevenue: 1200,
      prepaidDeliveredRevenue: 750,
      codDeliveredRevenue: 450,
      codCashCollectedTotal: 6850,
      pendingInProgressRevenue: 0,
      deliveredCount: 12,
      inProgressCount: 0,
      totalDeliveriesCount: 12,
      currency: 'NLe',
      hasPendingPayoutRequest: true,
      pendingPayoutRequest: pendingReq,
    );

    registerController(
      revenueOverride: RiderRevenueDataEntity(
        summary: pendingSummary,
        filters: const RiderRevenueFiltersEntity(),
        count: 1,
        deliveries: [prepaidDeliveredOrder],
      ),
      payoutOverride: RiderPayoutStatusEntity(
        netBalance: 450,
        payoutMethod: 'AfriMoney',
        pendingRequest: pendingReq,
        history: [pendingReq],
      ),
    );

    await tester.pumpWidget(
      const GetMaterialApp(home: EarningsView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Amber pending banner must be visible
    expect(find.byKey(const Key('pending_payout_amber_banner')), findsOneWidget);
    expect(find.text('Payout Request Pending Disbursement'), findsOneWidget);

    // Request Payout CTA must be disabled
    final ctaBtn = tester.widget<ElevatedButton>(
      find.byKey(const Key('request_payout_cta_button')),
    );
    expect(ctaBtn.onPressed, isNull);
  });

  testWidgets('Disables Request Payout button when netBalance <= 0',
      (WidgetTester tester) async {
    registerController(
      revenueOverride: RiderRevenueDataEntity(
        summary: const RiderRevenueSummaryEntity(
          netBalance: 0,
          availablePayoutBalance: 0,
          totalDeliveredRevenue: 450,
          prepaidDeliveredRevenue: 0,
          codDeliveredRevenue: 450,
          codCashCollectedTotal: 3200,
          pendingInProgressRevenue: 0,
          deliveredCount: 5,
          inProgressCount: 0,
          totalDeliveriesCount: 5,
          currency: 'NLe',
          hasPendingPayoutRequest: false,
        ),
        filters: const RiderRevenueFiltersEntity(),
        count: 1,
        deliveries: [codDeliveredOrder],
      ),
      payoutOverride: const RiderPayoutStatusEntity(
        netBalance: 0,
        history: [],
      ),
    );

    await tester.pumpWidget(
      const GetMaterialApp(home: EarningsView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final ctaBtn = tester.widget<ElevatedButton>(
      find.byKey(const Key('request_payout_cta_button')),
    );
    expect(ctaBtn.onPressed, isNull);
  });

  testWidgets('Request Payout bottom sheet opens and submits sellerNote cleanly',
      (WidgetTester tester) async {
    registerController();
    final createdReq = RiderPayoutRequestEntity(
      id: 'req-new',
      requestedAmount: 450,
      status: 'PENDING',
      sellerNote: 'Send to AfriMoney 077123456',
      payoutMethod: 'AfriMoney',
      requestedAt: DateTime(2026, 11, 10, 17, 0),
    );
    when(() => mockSubmitPayout(sellerNote: any(named: 'sellerNote')))
        .thenAnswer((_) async => Right(createdReq));

    await tester.pumpWidget(
      const GetMaterialApp(home: EarningsView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const Key('request_payout_cta_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PayoutRequestBottomSheet), findsOneWidget);
    expect(find.text('Request Wallet Payout'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(PayoutRequestBottomSheet),
        matching: find.byType(TextField),
      ),
      'Send to AfriMoney 077123456',
    );
    await tester.pump();

    await tester.tap(find.text('Submit Payout Request'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => mockSubmitPayout(sellerNote: 'Send to AfriMoney 077123456')).called(1);

    // Let GetX snackbar animation and 3-second dismissal timer finish cleanly
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('UI Overflow & Dark Mode Stress Test on 320px narrow screen across all 3 tabs',
      (WidgetTester tester) async {
    // Smallest supported mobile width: 320x568
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final largeSummary = RiderRevenueSummaryEntity(
      netBalance: 12450000.50,
      availablePayoutBalance: 12450000.50,
      totalDeliveredRevenue: 28950000.75,
      prepaidDeliveredRevenue: 19200000.50,
      codDeliveredRevenue: 9750000.25,
      codCashCollectedTotal: 84500000.00,
      pendingInProgressRevenue: 1250000.00,
      deliveredCount: 412,
      inProgressCount: 15,
      totalDeliveriesCount: 427,
      currency: 'NLe',
      hasPendingPayoutRequest: true,
      pendingPayoutRequest: RiderPayoutRequestEntity(
        id: 'req-large',
        requestedAmount: 12450000.50,
        status: 'PENDING',
        payoutMethod: 'Sierra Leone Commercial Bank',
        requestedAt: DateTime(2026, 11, 10, 16, 30),
      ),
    );

    registerController(
      revenueOverride: RiderRevenueDataEntity(
        summary: largeSummary,
        riderBankDetails: const RiderBankDetailsEntity(
          paymentOption: 'Bank Account',
          preferredPayoutMethod: 'Sierra Leone Commercial Bank',
          accountHolderName: 'Ibrahim Koroma',
          bankName: 'Sierra Leone Commercial Bank',
          accountNumber: '0040011223344',
        ),
        filters: const RiderRevenueFiltersEntity(),
        count: 3,
        deliveries: [prepaidDeliveredOrder, codDeliveredOrder, inProgressOrder],
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.darkTheme,
        home: const EarningsView(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Switch through all 3 tabs on narrow 320px dark-mode screen
    await tester.ensureVisible(find.byKey(const Key('section_tab_ledger')));
    await tester.tap(find.byKey(const Key('section_tab_ledger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.ensureVisible(find.byKey(const Key('section_tab_payouts')));
    await tester.tap(find.byKey(const Key('section_tab_payouts')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Zero Flutter layout/overflow exceptions!
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Accessibility 1.5x Text Scaling + Open Keyboard Stress Test on 320px screen (all tabs + bottom sheet)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    registerController();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.5),
        ),
        child: const GetMaterialApp(home: EarningsView()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Switch through Ledger & Payouts at 1.5x font scale on 320px screen
    await tester.ensureVisible(find.byKey(const Key('section_tab_ledger')));
    await tester.tap(find.byKey(const Key('section_tab_ledger')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.ensureVisible(find.byKey(const Key('section_tab_payouts')));
    await tester.tap(find.byKey(const Key('section_tab_payouts')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Also render PayoutRequestBottomSheet under 320x568 with 220px virtual keyboard + 1.4x font scale
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          viewInsets: EdgeInsets.only(bottom: 220),
          textScaler: TextScaler.linear(1.4),
        ),
        child: GetMaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: PayoutRequestBottomSheet(
                availableBalance: 12450000.50,
                currency: 'NLe',
                payoutMethod: 'AfriMoney',
                payoutAccountSnapshot:
                    'Method: Mobile Money • Holder: John Kamara • Mobile: 077123456 • Wallet: AfriMoney',
                hasConfiguredPayoutAccount: false,
                onSubmitted: (_) async => true,
                onManagePayoutAccount: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Submit CTA must still be rendered & visible even with 220px keyboard open
    expect(find.text('Submit Payout Request'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
