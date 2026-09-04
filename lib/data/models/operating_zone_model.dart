import '../../domain/entities/operating_zone_entity.dart';

class DeliveryLocationModel extends DeliveryLocationEntity {
  const DeliveryLocationModel({
    required super.id,
    required super.zoneId,
    required super.name,
    super.code = '',
    super.latitude = 0.0,
    super.longitude = 0.0,
    super.radiusKm = 5.0,
    super.isActive = true,
    super.isSelected = false,
  });

  factory DeliveryLocationModel.fromJson(Map<String, dynamic> json) {
    final locName = (json['name'] as String?) ??
        (json['regionName'] as String?) ??
        (json['region_name'] as String?) ??
        (json['locationName'] as String?) ??
        '';
    final locId = (json['id'] as String?) ?? (json['code'] as String?) ?? (locName.isNotEmpty ? locName : 'loc_${DateTime.now().millisecondsSinceEpoch}');

    return DeliveryLocationModel(
      id: locId,
      zoneId: json['zoneId'] as String? ?? '',
      name: locName.isNotEmpty ? locName : locId,
      code: json['code'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 5.0,
      isActive: json['isActive'] as bool? ?? true,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'name': name,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'isActive': isActive,
      'isSelected': isSelected,
    };
  }

  factory DeliveryLocationModel.fromEntity(DeliveryLocationEntity entity) {
    return DeliveryLocationModel(
      id: entity.id,
      zoneId: entity.zoneId,
      name: entity.name,
      code: entity.code,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radiusKm: entity.radiusKm,
      isActive: entity.isActive,
      isSelected: entity.isSelected,
    );
  }
}

class OperatingZoneModel extends OperatingZoneEntity {
  const OperatingZoneModel({
    required super.id,
    required super.name,
    super.district = '',
    super.description = '',
    super.isActive = true,
    super.isSelected = false,
    super.surgeMultiplier = 1.0,
    super.activeRiders = 0,
    super.locations = const [],
  });

  factory OperatingZoneModel.fromJson(Map<String, dynamic> json) {
    final rawLocations = (json['locations'] as List<dynamic>?) ?? (json['regions'] as List<dynamic>?) ?? [];
    final zoneId = (json['id'] as String?) ?? 'zone_1';
    final parsedLocations = rawLocations
        .map((loc) {
          if (loc is Map<String, dynamic>) {
            return DeliveryLocationModel.fromJson({
              'zoneId': zoneId,
              ...loc,
            });
          }
          return DeliveryLocationModel(id: loc.toString(), zoneId: zoneId, name: loc.toString());
        })
        .toList();

    final zoneName = (json['name'] as String?) ??
        (json['zoneName'] as String?) ??
        (json['zone_name'] as String?) ??
        (json['title'] as String?) ??
        (json['id'] as String?) ??
        'Downtown District';

    return OperatingZoneModel(
      id: zoneId,
      name: zoneName,
      district: json['district'] as String? ?? (json['description'] as String? ?? 'Central'),
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      isSelected: json['isSelected'] as bool? ?? false,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      activeRiders: (json['activeRiders'] as num?)?.toInt() ?? 0,
      locations: parsedLocations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'description': description,
      'isActive': isActive,
      'isSelected': isSelected,
      'surgeMultiplier': surgeMultiplier,
      'activeRiders': activeRiders,
      'locations': locations.map((loc) => DeliveryLocationModel.fromEntity(loc).toJson()).toList(),
    };
  }

  factory OperatingZoneModel.fromEntity(OperatingZoneEntity entity) {
    return OperatingZoneModel(
      id: entity.id,
      name: entity.name,
      district: entity.district,
      description: entity.description,
      isActive: entity.isActive,
      isSelected: entity.isSelected,
      surgeMultiplier: entity.surgeMultiplier,
      activeRiders: entity.activeRiders,
      locations: entity.locations,
    );
  }
}
