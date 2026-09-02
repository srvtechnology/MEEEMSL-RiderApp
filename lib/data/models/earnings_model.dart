import '../../domain/entities/earnings_entity.dart';
import 'transaction_model.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.todayEarnings,
    required super.weeklyEarnings,
    required super.monthlyEarnings,
    required super.availablePayout,
    required super.completedTrips,
    required super.basePay,
    required super.tips,
    required super.surgeBonuses,
    required super.dailyData,
    required super.recentTransactions,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyData'] as List<dynamic>?)
            ?.map((e) => DailyChartData(
                  day: e['day'] as String? ?? '',
                  amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList() ??
        [];

    final txList = (json['recentTransactions'] as List<dynamic>?)
            ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return EarningsModel(
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      availablePayout: (json['availablePayout'] as num?)?.toDouble() ?? 0.0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      basePay: (json['basePay'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      surgeBonuses: (json['surgeBonuses'] as num?)?.toDouble() ?? 0.0,
      dailyData: dailyList,
      recentTransactions: txList,
    );
  }
}
