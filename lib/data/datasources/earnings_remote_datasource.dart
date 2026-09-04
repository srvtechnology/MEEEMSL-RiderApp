import '../../core/network/dio_client.dart';
import '../../domain/entities/earnings_entity.dart';
import '../models/earnings_model.dart';
import '../models/transaction_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(String period);
  Future<bool> requestPayout(double amount, String paymentMethod);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  // ignore: unused_field
  final DioClient _dioClient;

  EarningsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<EarningsModel> getEarnings(String period) async {
    // Note: Earnings breakdown API is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // Returns local data without making network calls to server.
    return EarningsModel(
      todayEarnings: 148.50,
      weeklyEarnings: 892.20,
      monthlyEarnings: 3420.00,
      availablePayout: 240.00,
      completedTrips: 45,
      basePay: 720.00,
      tips: 92.20,
      surgeBonuses: 80.00,
      dailyData: const [
        DailyChartData(day: 'Mon', amount: 45.0),
        DailyChartData(day: 'Tue', amount: 62.5),
        DailyChartData(day: 'Wed', amount: 38.0),
        DailyChartData(day: 'Thu', amount: 84.0),
        DailyChartData(day: 'Fri', amount: 95.0),
        DailyChartData(day: 'Sat', amount: 120.0),
        DailyChartData(day: 'Sun', amount: 80.0),
      ],
      recentTransactions: [
        TransactionModel(
          id: 'tx_1',
          orderNumber: '#MM-8839',
          amount: 14.80,
          tip: 2.50,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'trip_earnings',
          status: 'completed',
        ),
        TransactionModel(
          id: 'tx_2',
          orderNumber: '#MM-8831',
          amount: 12.50,
          tip: 3.00,
          date: DateTime.now().subtract(const Duration(hours: 5)),
          type: 'trip_earnings',
          status: 'completed',
        ),
        TransactionModel(
          id: 'tx_3',
          orderNumber: '#MM-8812',
          amount: 18.20,
          tip: 4.00,
          date: DateTime.now().subtract(const Duration(hours: 8)),
          type: 'trip_earnings',
          status: 'completed',
        ),
      ],
    );
  }

  @override
  Future<bool> requestPayout(double amount, String paymentMethod) async {
    // Note: Payout request API is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // Processed locally without making network calls to server.
    return true;
  }
}
