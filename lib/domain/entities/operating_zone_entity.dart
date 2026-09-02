import 'package:equatable/equatable.dart';

class DeliveryLocationEntity extends Equatable {
  final String id;
  final String zoneId;
  final String name;
  final String code;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isActive;
  final bool isSelected;

  const DeliveryLocationEntity({
    required this.id,
    required this.zoneId,
    required this.name,
    this.code = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.radiusKm = 5.0,
    this.isActive = true,
    this.isSelected = false,
  });

  DeliveryLocationEntity copyWith({
    String? id,
    String? zoneId,
    String? name,
    String? code,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isActive,
    bool? isSelected,
  }) {
    return DeliveryLocationEntity(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      name: name ?? this.name,
      code: code ?? this.code,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, zoneId, name, code, latitude, longitude, radiusKm, isActive, isSelected];
}

class OperatingZoneEntity extends Equatable {
  final String id;
  final String name;
  final String district;
  final String description;
  final bool isActive;
  final bool isSelected;
  final double surgeMultiplier;
  final int activeRiders;
  final List<DeliveryLocationEntity> locations;

  const OperatingZoneEntity({
    required this.id,
    required this.name,
    this.district = '',
    this.description = '',
    this.isActive = true,
    this.isSelected = false,
    this.surgeMultiplier = 1.0,
    this.activeRiders = 0,
    this.locations = const [],
  });

  OperatingZoneEntity copyWith({
    String? id,
    String? name,
    String? district,
    String? description,
    bool? isActive,
    bool? isSelected,
    double? surgeMultiplier,
    int? activeRiders,
    List<DeliveryLocationEntity>? locations,
  }) {
    return OperatingZoneEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isSelected: isSelected ?? this.isSelected,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      activeRiders: activeRiders ?? this.activeRiders,
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        district,
        description,
        isActive,
        isSelected,
        surgeMultiplier,
        activeRiders,
        locations,
      ];
}
