import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String type;
  final String model;
  final String licensePlate;
  final String color;
  final String year;

  const VehicleEntity({
    required this.type,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
  });

  @override
  List<Object?> get props => [type, model, licensePlate, color, year];
}
