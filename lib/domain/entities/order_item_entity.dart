import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String name;
  final int quantity;
  final String notes;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    this.notes = '',
  });

  @override
  List<Object?> get props => [name, quantity, notes];
}
