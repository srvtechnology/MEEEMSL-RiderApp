import '../../domain/entities/operating_zone_entity.dart';

class OperatingZoneModel extends OperatingZoneEntity {
  const OperatingZoneModel({
    required super.id,
    required super.name,
    required super.district,
    super.isSelected = false,
    super.surgeMultiplier = 1.0,
    super.activeRiders = 0,
  });

  factory OperatingZoneModel.fromJson(Map<String, dynamic> json) {
    return OperatingZoneModel(
      id: json['id'] as String? ?? 'zone_1',
      name: json['name'] as String? ?? 'Downtown District',
      district: json['district'] as String? ?? 'Central',
      isSelected: json['isSelected'] as bool? ?? false,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      activeRiders: (json['activeRiders'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'isSelected': isSelected,
      'surgeMultiplier': surgeMultiplier,
      'activeRiders': activeRiders,
    };
  }

  factory OperatingZoneModel.fromEntity(OperatingZoneEntity entity) {
    return OperatingZoneModel(
      id: entity.id,
      name: entity.name,
      district: entity.district,
      isSelected: entity.isSelected,
      surgeMultiplier: entity.surgeMultiplier,
      activeRiders: entity.activeRiders,
    );
  }
}
