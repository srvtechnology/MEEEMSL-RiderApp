import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.type,
    required super.model,
    required super.licensePlate,
    required super.color,
    required super.year,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      type: json['type'] as String? ?? 'Motorcycle',
      model: json['model'] as String? ?? 'Vehicle',
      licensePlate: json['licensePlate'] as String? ?? 'N/A',
      color: json['color'] as String? ?? 'Black',
      year: json['year']?.toString() ?? '2024',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'year': year,
    };
  }

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      type: entity.type,
      model: entity.model,
      licensePlate: entity.licensePlate,
      color: entity.color,
      year: entity.year,
    );
  }
}
