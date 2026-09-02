import 'package:equatable/equatable.dart';
import 'transaction_entity.dart';

class DailyChartData extends Equatable {
  final String day;
  final double amount;

  const DailyChartData({required this.day, required this.amount});

  @override
  List<Object?> get props => [day, amount];
}

class EarningsEntity extends Equatable {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double availablePayout;
  final int completedTrips;
  final double basePay;
  final double tips;
  final double surgeBonuses;
  final List<DailyChartData> dailyData;
  final List<TransactionEntity> recentTransactions;

  const EarningsEntity({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.availablePayout,
    required this.completedTrips,
    required this.basePay,
    required this.tips,
    required this.surgeBonuses,
    required this.dailyData,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        todayEarnings,
        weeklyEarnings,
        monthlyEarnings,
        availablePayout,
        completedTrips,
        basePay,
        tips,
        surgeBonuses,
      ];
}
