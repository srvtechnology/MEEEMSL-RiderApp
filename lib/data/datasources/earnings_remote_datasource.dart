import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/earnings_entity.dart';
import '../models/earnings_model.dart';
import '../models/transaction_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(String period);
  Future<bool> requestPayout(double amount, String paymentMethod);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final DioClient _dioClient;

  EarningsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<EarningsModel> getEarnings(String period) async {
    double todayEarnings = 0.0;
    double weeklyEarnings = 0.0;
    double monthlyEarnings = 0.0;
    double totalAvailable = 0.0;
    int completedTrips = 0;
    final Map<String, double> weekdayEarnings = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };
    final List<TransactionModel> transactions = [];

    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'completed'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          completedTrips = data.length;
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final weekStart = now.subtract(const Duration(days: 7));
          final monthStart = now.subtract(const Duration(days: 30));

          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final earnings = (item['riderEarnings'] as num?)?.toDouble() ??
                  (item['order']?['deliveryFee'] as num?)?.toDouble() ??
                  0.0;
              final dateStr = item['deliveredAt'] ?? item['createdAt'] ?? item['updatedAt'];
              final date = dateStr != null ? (DateTime.tryParse(dateStr.toString()) ?? now) : now;
              final orderNum = item['order']?['orderNumber']?.toString() ??
                  item['orderNumber']?.toString() ??
                  '#${item['id']}';

              totalAvailable += earnings;

              if (date.isAfter(todayStart)) {
                todayEarnings += earnings;
              }
              if (date.isAfter(weekStart)) {
                weeklyEarnings += earnings;
                final dayKey = _weekdayString(date.weekday);
                weekdayEarnings[dayKey] = (weekdayEarnings[dayKey] ?? 0.0) + earnings;
              }
              if (date.isAfter(monthStart)) {
                monthlyEarnings += earnings;
              }

              transactions.add(
                TransactionModel(
                  id: item['id']?.toString() ?? 'tx_${transactions.length}',
                  orderNumber: orderNum.startsWith('#') ? orderNum : '#$orderNum',
                  amount: earnings,
                  tip: 0.0,
                  date: date,
                  type: 'trip_earnings',
                  status: 'completed',
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    final dailyData = weekdayEarnings.entries
        .map((e) => DailyChartData(day: e.key, amount: e.value))
        .toList();

    return EarningsModel(
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      monthlyEarnings: monthlyEarnings,
      availablePayout: totalAvailable,
      completedTrips: completedTrips,
      basePay: totalAvailable,
      tips: 0.0,
      surgeBonuses: 0.0,
      dailyData: dailyData,
      recentTransactions: transactions,
    );
  }

  static String _weekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
    }
  }

  @override
  Future<bool> requestPayout(double amount, String paymentMethod) async {
    return true;
  }
}
