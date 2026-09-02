import 'package:equatable/equatable.dart';

class OperatingZoneEntity extends Equatable {
  final String id;
  final String name;
  final String district;
  final bool isSelected;
  final double surgeMultiplier;
  final int activeRiders;

  const OperatingZoneEntity({
    required this.id,
    required this.name,
    required this.district,
    this.isSelected = false,
    this.surgeMultiplier = 1.0,
    this.activeRiders = 0,
  });

  OperatingZoneEntity copyWith({
    String? id,
    String? name,
    String? district,
    bool? isSelected,
    double? surgeMultiplier,
    int? activeRiders,
  }) {
    return OperatingZoneEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      district: district ?? this.district,
      isSelected: isSelected ?? this.isSelected,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      activeRiders: activeRiders ?? this.activeRiders,
    );
  }

  @override
  List<Object?> get props => [id, name, district, isSelected, surgeMultiplier, activeRiders];
}
