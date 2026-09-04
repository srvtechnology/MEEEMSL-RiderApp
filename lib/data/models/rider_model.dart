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

  factory RiderModel.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? userJson]) {
    final user = userJson ?? (json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null);
    final rider = json['rider'] is Map<String, dynamic> ? json['rider'] as Map<String, dynamic> : json;

    final statusStr = rider['status'] as String? ??
        rider['approvalStatus'] as String? ??
        json['status'] as String? ??
        json['approvalStatus'] as String? ??
        'APPROVED';
    final isSuspendedVal = (rider['isSuspended'] as bool?) ??
        (json['isSuspended'] as bool?) ??
        (statusStr == 'SUSPENDED');
    final isApprovedVal = (rider['isApproved'] as bool?) ??
        (json['isApproved'] as bool?) ??
        (statusStr == 'APPROVED' && !isSuspendedVal);

    // Safely parse onboardingCompleted (supports bool, String, num, and defaults to false)
    final rawOnboarding = rider['onboardingCompleted'] ?? json['onboardingCompleted'];
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
    final rawFirstLogin = rider['isFirstLogin'] ?? json['isFirstLogin'];
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

    final nameVal = (rider['name'] as String? ?? '').isNotEmpty
        ? (rider['name'] as String)
        : (user?['name'] as String? ?? json['name'] as String? ?? '');

    final emailVal = (rider['email'] as String? ?? '').isNotEmpty
        ? (rider['email'] as String)
        : (user?['email'] as String? ?? json['email'] as String? ?? '');

    String phoneVal = (rider['phone'] as String? ?? '');
    if (phoneVal.isEmpty) {
      final uPhone = user?['phone']?.toString();
      final uCode = user?['phoneCountryCode']?.toString();
      if (uPhone != null && uPhone.isNotEmpty) {
        phoneVal = (uCode != null && !uPhone.startsWith('+')) ? '$uCode $uPhone' : uPhone;
      } else {
        phoneVal = json['phone'] as String? ?? '';
      }
    }

    final avatarVal = (rider['avatar'] as String? ?? '').isNotEmpty
        ? (rider['avatar'] as String)
        : (rider['profileImage'] as String? ?? '').isNotEmpty
            ? (rider['profileImage'] as String)
            : (user?['image'] as String? ?? json['avatar'] as String? ?? '');

    return RiderModel(
      id: rider['id'] as String? ?? json['id'] as String? ?? user?['id'] as String? ?? '',
      name: nameVal,
      phone: phoneVal,
      email: emailVal,
      avatar: avatarVal,
      rating: (rider['rating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (rider['totalTrips'] as num?)?.toInt() ?? (json['totalTrips'] as num?)?.toInt() ?? 0,
      isOnline: (rider['isOnline'] as bool?) ?? (json['isOnline'] as bool?) ?? false,
      walletBalance: (rider['walletBalance'] as num?)?.toDouble() ?? (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      approvalStatus: statusStr,
      isApproved: isApprovedVal,
      isSuspended: isSuspendedVal,
      status: statusStr,
      onboardingCompleted: onboardingCompletedVal,
      isFirstLogin: isFirstLoginVal,
      vehicleTypes: ((rider['vehicleTypes'] ?? json['vehicleTypes']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['2_WHEELER'],
      vehicleType: rider['vehicleType'] as String? ?? json['vehicleType'] as String? ?? '2_WHEELER',
      vehicleName: rider['vehicleName'] as String? ?? json['vehicleName'] as String?,
      vehicleNumber: rider['vehicleNumber'] as String? ?? json['vehicleNumber'] as String?,
      drivingLicenseNo: rider['drivingLicenseNo'] as String? ?? json['drivingLicenseNo'] as String?,
      profileImage: rider['profileImage'] as String? ?? json['profileImage'] as String? ?? avatarVal,
      drivingLicenseDoc: rider['drivingLicenseDoc'] as String? ?? json['drivingLicenseDoc'] as String?,
      nationalIdDoc: rider['nationalIdDoc'] as String? ?? json['nationalIdDoc'] as String?,
      vehicleInsuranceDoc: rider['vehicleInsuranceDoc'] as String? ?? json['vehicleInsuranceDoc'] as String?,
      selectedZones: ((rider['selectedZones'] ?? json['selectedZones']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      selectedLocations: ((rider['selectedLocations'] ?? json['selectedLocations']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      vehicle: rider['vehicle'] != null
          ? VehicleModel.fromJson(rider['vehicle'] as Map<String, dynamic>)
          : json['vehicle'] != null
              ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
              : (rider['vehicleType'] != null || rider['vehicleName'] != null || rider['vehicleNumber'] != null)
                  ? VehicleModel(
                      type: rider['vehicleType'] as String? ?? '2_WHEELER',
                      model: rider['vehicleName'] as String? ?? '',
                      licensePlate: rider['vehicleNumber'] as String? ?? '',
                      color: rider['vehicleColor'] as String? ?? '',
                      year: rider['vehicleYear']?.toString() ?? '',
                    )
                  : null,
      payoutInfo: rider['payoutInfo'] != null
          ? PayoutInfoModel.fromJson(rider['payoutInfo'] as Map<String, dynamic>)
          : json['payoutInfo'] != null
              ? PayoutInfoModel.fromJson(json['payoutInfo'] as Map<String, dynamic>)
              : null,
      operatingZones: ((rider['operatingZones'] ?? json['operatingZones']) as List<dynamic>?)
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
