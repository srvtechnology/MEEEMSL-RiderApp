import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/error/exceptions.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/core/utils/formatters.dart';
import 'package:meeem_rider/data/datasources/earnings_remote_datasource.dart';
import 'package:meeem_rider/data/models/rider_ledger_model.dart';
import 'package:meeem_rider/data/models/rider_revenue_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioClient dioClient;
  late EarningsRemoteDataSourceImpl dataSource;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('earnings_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    await GetStorage.init();
  });

  setUp(() {
    MockInterceptor.resetPayoutMockState();
    dioClient = DioClient();
    dioClient.dio.interceptors.clear();
    dioClient.dio.interceptors.add(MockInterceptor());
    dataSource = EarningsRemoteDataSourceImpl(dioClient);
  });

  group('ApiEndpoints Payment Ledger Whitelist', () {
    test('whitelists /revenue, /balance-transactions, and /payout-requests', () {
      expect(ApiEndpoints.isDocumentedEndpoint('/revenue'), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint('/balance-transactions'), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint('/payout-requests'), isTrue);
      expect(
        ApiEndpoints.isDocumentedEndpoint(
          'https://www.meeemsl.com/mobileapi/rider/balance-transactions',
        ),
        isTrue,
      );
      expect(
        ApiEndpoints.isDocumentedEndpoint(
          'https://www.meeemsl.com/mobileapi/rider/payout-requests',
        ),
        isTrue,
      );
    });
  });

  group('Formatters.formatRevenueAmount precision checks', () {
    test('rounds floating-point edge values without decimal artifacts', () {
      expect(Formatters.formatRevenueAmount(449.996), equals('NLe 450'));
      expect(Formatters.formatRevenueAmount(450.5), equals('NLe 450.50'));
      expect(Formatters.formatRevenueAmount(125000.0), equals('NLe 125,000'));
      expect(Formatters.formatRevenueAmount(0.0), equals('NLe 0'));
      expect(Formatters.formatRevenueAmount(-300.25), equals('-NLe 300.25'));
    });
  });

  group('Decimal String Parsing Safety (Prisma Decimal)', () {
    test('parses numeric strings cleanly in revenue and ledger models', () {
      final summary = RiderRevenueSummaryModel.fromJson({
        'netBalance': '450.50',
        'availablePayoutBalance': '450.50',
        'totalDeliveredRevenue': '1200.00',
        'prepaidDeliveredRevenue': '750.00',
        'codDeliveredRevenue': '450.00',
        'codCashCollectedTotal': '6850.25',
        'pendingInProgressRevenue': '200.00',
        'deliveredCount': '12',
        'inProgressCount': '2',
        'totalDeliveriesCount': '14',
        'currency': 'NLe',
        'hasPendingPayoutRequest': false,
      });

      expect(summary.netBalance, equals(450.50));
      expect(summary.codCashCollectedTotal, equals(6850.25));
      expect(summary.deliveredCount, equals(12));

      final ledger = RiderBalanceLedgerModel.fromJson({
        'netBalance': '450.50',
        'balanceCreditsTotal': '1200.00',
        'balanceDebitsTotal': '300.00',
        'transactions': [
          {
            'id': 'tx-1',
            'amount': '75.50',
            'kind': 'CREDIT',
            'reason': 'DELIVERY_FULFILLED',
            'createdAt': '2026-11-10T14:22:00.000Z',
          }
        ],
      });
      expect(ledger.netBalance, equals(450.50));
      expect(ledger.transactions.first.amount, equals(75.50));
    });
  });

  group('EarningsRemoteDataSource Rider Revenue, Ledger & Payout Tests', () {
    test('getRiderRevenue fetches full wallet KPIs, bank details, and deliveries', () async {
      final data = await dataSource.getRiderRevenue();

      expect(data.summary.currency, equals('NLe'));
      expect(data.summary.netBalance, equals(25000.0));
      expect(data.summary.availablePayoutBalance, equals(25000.0));
      expect(data.summary.prepaidDeliveredRevenue, equals(55000.0));
      expect(data.summary.codDeliveredRevenue, equals(20000.0));
      expect(data.summary.codCashCollectedTotal, equals(190000.0));
      expect(data.summary.totalDeliveredRevenue, equals(75000.0));
      expect(data.summary.pendingInProgressRevenue, equals(35000.0));
      expect(data.summary.deliveredCount, greaterThanOrEqualTo(3));
      expect(data.summary.inProgressCount, greaterThanOrEqualTo(1));
      expect(data.summary.hasPendingPayoutRequest, isFalse);

      expect(data.riderBankDetails, isNotNull);
      expect(data.riderBankDetails!.preferredPayoutMethod, equals('AfriMoney'));
      expect(data.riderBankDetails!.mobileNumber, equals('077123456'));

      expect(data.deliveries, isNotEmpty);
      final prepaidYetToPay = data.deliveries.firstWhere((d) => d.orderNumber == 'meeem00000042');
      expect(prepaidYetToPay.paymentMethod, equals('AFRIMONEY'));
      expect(prepaidYetToPay.settlementStatus, equals('YET_TO_PAY'));
      expect(prepaidYetToPay.codAmountCollected, isNull);

      final codDelivery = data.deliveries.firstWhere((d) => d.orderNumber == 'meeem00000038');
      expect(codDelivery.paymentMethod, equals('COD'));
      expect(codDelivery.settlementStatus, equals('COD_COLLECTED_BY_RIDER'));
      expect(codDelivery.codAmountCollected, equals(190000.0));

      final paidOutDelivery = data.deliveries.firstWhere((d) => d.orderNumber == 'meeem00000031');
      expect(paidOutDelivery.settlementStatus, equals('PAID_OUT'));
      expect(paidOutDelivery.payoutReference, equals('AFRI-PAY-99881'));
      expect(paidOutDelivery.payoutMethod, equals('AfriMoney'));
      expect(paidOutDelivery.payoutDisbursedAt, isNotNull);
    });

    test('getRiderRevenue filters by status = delivered', () async {
      final data = await dataSource.getRiderRevenue(status: 'delivered');

      expect(data.deliveries, isNotEmpty);
      for (final delivery in data.deliveries) {
        expect(delivery.isDelivered, isTrue);
        expect(delivery.totalAmount, isNotNull);
      }
    });

    test('getRiderRevenue filters by status = inprogress and totalAmount is null', () async {
      final data = await dataSource.getRiderRevenue(status: 'inprogress');

      expect(data.deliveries, isNotEmpty);
      for (final delivery in data.deliveries) {
        expect(delivery.isDelivered, isFalse);
        expect(delivery.totalAmount, isNull);
        expect(delivery.deliveryCharge, greaterThan(0));
      }
    });

    test('getRiderRevenue searches by orderNumber', () async {
      final data = await dataSource.getRiderRevenue(search: 'meeem00000042');

      expect(data.deliveries, isNotEmpty);
      expect(data.deliveries.first.orderNumber, equals('meeem00000042'));
    });

    test('getBalanceTransactions fetches credits, debits, and chronological ledger', () async {
      final ledger = await dataSource.getBalanceTransactions();

      expect(ledger.netBalance, equals(25000.0));
      expect(ledger.balanceCreditsTotal, greaterThan(0));
      expect(ledger.balanceDebitsTotal, equals(30000.0));
      expect(ledger.transactions.length, greaterThanOrEqualTo(3));

      expect(ledger.transactions.any((t) => t.isPrepaidDelivery && t.isCredit), isTrue);
      expect(ledger.transactions.any((t) => t.isCodCollected && !t.affectsWalletBalance), isTrue);
      expect(ledger.transactions.any((t) => t.isPayoutDisbursed && t.isDebit), isTrue);
    });

    test('getPayoutRequests and submitPayoutRequest follow Section 6 rules', () async {
      final initial = await dataSource.getPayoutRequests();
      expect(initial.netBalance, equals(25000.0));
      expect(initial.pendingRequest, isNull);
      expect(initial.payoutMethod, equals('AfriMoney'));
      expect(initial.history, isNotEmpty);

      // Submit valid payout request
      final created = await dataSource.submitPayoutRequest(
        sellerNote: 'Please send to AfriMoney 077123456',
      );
      expect(created.status, equals('PENDING'));
      expect(created.requestedAmount, equals(25000.0));
      expect(created.sellerNote, equals('Please send to AfriMoney 077123456'));

      // Subsequent GET reflects pending request
      final after = await dataSource.getPayoutRequests();
      expect(after.hasPendingRequest, isTrue);
      expect(after.pendingRequest?.id, equals(created.id));

      // Duplicate POST while pending returns 400 ServerException
      expect(
        () => dataSource.submitPayoutRequest(sellerNote: 'Duplicate'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('already pending')),
        ),
      );
    });

    test('submitPayoutRequest fails with 400 when netBalance <= 0', () async {
      MockInterceptor.resetPayoutMockState(netBalanceOverride: 0.0);

      expect(
        () => dataSource.submitPayoutRequest(),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('Insufficient balance')),
        ),
      );
    });
  });
}
