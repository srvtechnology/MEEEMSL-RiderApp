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
    super.isApproved,
    super.isSuspended,
    super.status,
    super.onboardingCompleted,
    super.isFirstLogin,
    super.vehicleTypes,
    super.vehicleType,
    super.vehicleName,
    super.vehicleNumber,
    super.drivingLicenseNo,
    super.profileImage,
    super.drivingLicenseDoc,
    super.nationalIdDoc,
    super.vehicleInsuranceDoc,
    super.selectedZones,
    super.selectedLocations,
    super.vehicle,
    super.payoutInfo,
    super.operatingZones,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? json['approvalStatus'] as String? ?? 'APPROVED';
    final isSuspendedVal = json['isSuspended'] as bool? ?? (statusStr == 'SUSPENDED');
    final isApprovedVal = json['isApproved'] as bool? ?? (statusStr == 'APPROVED' && !isSuspendedVal);

    // Safely parse onboardingCompleted (supports bool, String, num, and defaults to false)
    final rawOnboarding = json['onboardingCompleted'];
    final bool onboardingCompletedVal;
    if (rawOnboarding is bool) {
      onboardingCompletedVal = rawOnboarding;
    } else if (rawOnboarding is String) {
      onboardingCompletedVal = rawOnboarding.toLowerCase() == 'true';
    } else if (rawOnboarding is num) {
      onboardingCompletedVal = rawOnboarding == 1;
    } else {
      onboardingCompletedVal = false;
    }

    // Safely parse isFirstLogin
    final rawFirstLogin = json['isFirstLogin'];
    final bool isFirstLoginVal;
    if (rawFirstLogin is bool) {
      isFirstLoginVal = rawFirstLogin;
    } else if (rawFirstLogin is String) {
      isFirstLoginVal = rawFirstLogin.toLowerCase() == 'true';
    } else if (rawFirstLogin is num) {
      isFirstLoginVal = rawFirstLogin == 1;
    } else {
      isFirstLoginVal = false;
    }

    return RiderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? json['profileImage'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      approvalStatus: statusStr,
      isApproved: isApprovedVal,
      isSuspended: isSuspendedVal,
      status: statusStr,
      onboardingCompleted: onboardingCompletedVal,
      isFirstLogin: isFirstLoginVal,
      vehicleTypes: (json['vehicleTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['2_WHEELER'],
      vehicleType: json['vehicleType'] as String? ?? '2_WHEELER',
      vehicleName: json['vehicleName'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      drivingLicenseNo: json['drivingLicenseNo'] as String?,
      profileImage: json['profileImage'] as String? ?? json['avatar'] as String?,
      drivingLicenseDoc: json['drivingLicenseDoc'] as String?,
      nationalIdDoc: json['nationalIdDoc'] as String?,
      vehicleInsuranceDoc: json['vehicleInsuranceDoc'] as String?,
      selectedZones: (json['selectedZones'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      selectedLocations: (json['selectedLocations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : (json['vehicleType'] != null || json['vehicleName'] != null || json['vehicleNumber'] != null)
              ? VehicleModel(
                  type: json['vehicleType'] as String? ?? '2_WHEELER',
                  model: json['vehicleName'] as String? ?? '',
                  licensePlate: json['vehicleNumber'] as String? ?? '',
                  color: json['vehicleColor'] as String? ?? '',
                  year: json['vehicleYear']?.toString() ?? '',
                )
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
      'isApproved': isApproved,
      'isSuspended': isSuspended,
      'status': status,
      'onboardingCompleted': onboardingCompleted,
      'isFirstLogin': isFirstLogin,
      'vehicleTypes': vehicleTypes,
      'vehicleType': vehicleType,
      'vehicleName': vehicleName,
      'vehicleNumber': vehicleNumber,
      'drivingLicenseNo': drivingLicenseNo,
      'profileImage': profileImage,
      'drivingLicenseDoc': drivingLicenseDoc,
      'nationalIdDoc': nationalIdDoc,
      'vehicleInsuranceDoc': vehicleInsuranceDoc,
      'selectedZones': selectedZones,
      'selectedLocations': selectedLocations,
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
      isApproved: entity.isApproved,
      isSuspended: entity.isSuspended,
      status: entity.status,
      onboardingCompleted: entity.onboardingCompleted,
      isFirstLogin: entity.isFirstLogin,
      vehicleTypes: entity.vehicleTypes,
      vehicleType: entity.vehicleType,
      vehicleName: entity.vehicleName,
      vehicleNumber: entity.vehicleNumber,
      drivingLicenseNo: entity.drivingLicenseNo,
      profileImage: entity.profileImage,
      drivingLicenseDoc: entity.drivingLicenseDoc,
      nationalIdDoc: entity.nationalIdDoc,
      vehicleInsuranceDoc: entity.vehicleInsuranceDoc,
      selectedZones: entity.selectedZones,
      selectedLocations: entity.selectedLocations,
      vehicle: entity.vehicle,
      payoutInfo: entity.payoutInfo,
      operatingZones: entity.operatingZones,
    );
  }
}
