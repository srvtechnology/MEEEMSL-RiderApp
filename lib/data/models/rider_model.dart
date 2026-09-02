import '../../domain/entities/rider_entity.dart';
import 'vehicle_model.dart';
import 'payout_info_model.dart';

class RiderModel extends RiderEntity {
  const RiderModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.avatar,
    required super.rating,
    required super.totalTrips,
    required super.isOnline,
    required super.walletBalance,
    required super.approvalStatus,
    super.vehicle,
    super.payoutInfo,
    super.operatingZones,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      approvalStatus: json['approvalStatus'] as String? ?? 'approved',
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      payoutInfo: json['payoutInfo'] != null
          ? PayoutInfoModel.fromJson(json['payoutInfo'] as Map<String, dynamic>)
          : null,
      operatingZones: (json['operatingZones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'rating': rating,
      'totalTrips': totalTrips,
      'isOnline': isOnline,
      'walletBalance': walletBalance,
      'approvalStatus': approvalStatus,
      'vehicle': vehicle != null ? VehicleModel.fromEntity(vehicle!).toJson() : null,
      'payoutInfo': payoutInfo != null
          ? PayoutInfoModel.fromEntity(payoutInfo!).toJson()
          : null,
      'operatingZones': operatingZones,
    };
  }

  factory RiderModel.fromEntity(RiderEntity entity) {
    return RiderModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      avatar: entity.avatar,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
      isOnline: entity.isOnline,
      walletBalance: entity.walletBalance,
      approvalStatus: entity.approvalStatus,
      vehicle: entity.vehicle,
      payoutInfo: entity.payoutInfo,
      operatingZones: entity.operatingZones,
    );
  }
}
