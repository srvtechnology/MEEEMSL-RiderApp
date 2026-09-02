import 'package:equatable/equatable.dart';
import 'vehicle_entity.dart';
import 'payout_info_entity.dart';

class RiderEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatar;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final double walletBalance;
  final String approvalStatus; // pending, approved, under_review, rejected
  final VehicleEntity? vehicle;
  final PayoutInfoEntity? payoutInfo;
  final List<String> operatingZones;

  const RiderEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatar,
    required this.rating,
    required this.totalTrips,
    required this.isOnline,
    required this.walletBalance,
    required this.approvalStatus,
    this.vehicle,
    this.payoutInfo,
    this.operatingZones = const [],
  });

  RiderEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    double? rating,
    int? totalTrips,
    bool? isOnline,
    double? walletBalance,
    String? approvalStatus,
    VehicleEntity? vehicle,
    PayoutInfoEntity? payoutInfo,
    List<String>? operatingZones,
  }) {
    return RiderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isOnline: isOnline ?? this.isOnline,
      walletBalance: walletBalance ?? this.walletBalance,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      vehicle: vehicle ?? this.vehicle,
      payoutInfo: payoutInfo ?? this.payoutInfo,
      operatingZones: operatingZones ?? this.operatingZones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatar,
        rating,
        totalTrips,
        isOnline,
        walletBalance,
        approvalStatus,
        vehicle,
        payoutInfo,
        operatingZones,
      ];
}
