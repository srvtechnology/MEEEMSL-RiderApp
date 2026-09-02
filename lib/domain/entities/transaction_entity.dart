import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String orderNumber;
  final double amount;
  final double tip;
  final DateTime date;
  final String type; // trip_earnings, withdrawal, bonus
  final String status; // completed, pending, failed

  const TransactionEntity({
    required this.id,
    required this.orderNumber,
    required this.amount,
    required this.tip,
    required this.date,
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [id, orderNumber, amount, tip, date, type, status];
}
