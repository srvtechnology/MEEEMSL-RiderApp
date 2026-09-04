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

  VehicleEntity copyWith({
    String? type,
    String? model,
    String? licensePlate,
    String? color,
    String? year,
  }) {
    return VehicleEntity(
      type: type ?? this.type,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      year: year ?? this.year,
    );
  }

  @override
  List<Object?> get props => [type, model, licensePlate, color, year];
}
