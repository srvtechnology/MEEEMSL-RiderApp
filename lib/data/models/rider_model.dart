import 'dart:convert';
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
    super.adminFeedback,
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
        rider['approval_status'] as String? ??
        json['status'] as String? ??
        json['approvalStatus'] as String? ??
        json['approval_status'] as String? ??
        user?['status'] as String? ??
        user?['approvalStatus'] as String? ??
        'APPROVED';
    final isSuspendedVal = (rider['isSuspended'] as bool?) ??
        (rider['is_suspended'] as bool?) ??
        (json['isSuspended'] as bool?) ??
        (json['is_suspended'] as bool?) ??
        (user?['isSuspended'] as bool?) ??
        (statusStr.toUpperCase() == 'SUSPENDED');
    final isApprovedVal = (rider['isApproved'] as bool?) ??
        (rider['is_approved'] as bool?) ??
        (json['isApproved'] as bool?) ??
        (json['is_approved'] as bool?) ??
        (user?['isApproved'] as bool?) ??
        ((statusStr.toUpperCase() == 'APPROVED' || statusStr.toUpperCase() == 'ACTIVE') && !isSuspendedVal);

    // Safely parse onboardingCompleted (supports bool, String, num, and defaults to false)
    final rawOnboarding = rider['onboardingCompleted'] ??
        rider['onboarding_completed'] ??
        rider['isOnboarded'] ??
        rider['is_onboarded'] ??
        rider['isOnboardingCompleted'] ??
        json['onboardingCompleted'] ??
        json['onboarding_completed'] ??
        json['isOnboarded'] ??
        user?['onboardingCompleted'] ??
        user?['onboarding_completed'] ??
        user?['isOnboarded'];
    final bool onboardingCompletedVal;
    if (rawOnboarding is bool) {
      onboardingCompletedVal = rawOnboarding;
    } else if (rawOnboarding is String) {
      onboardingCompletedVal = rawOnboarding.toLowerCase() == 'true' ||
          rawOnboarding.toLowerCase() == 'completed' ||
          rawOnboarding == '1';
    } else if (rawOnboarding is num) {
      onboardingCompletedVal = rawOnboarding == 1;
    } else {
      onboardingCompletedVal = false;
    }

    // Safely parse isFirstLogin
    final rawFirstLogin = rider['isFirstLogin'] ??
        rider['is_first_login'] ??
        json['isFirstLogin'] ??
        json['is_first_login'] ??
        user?['isFirstLogin'] ??
        user?['is_first_login'];
    final bool isFirstLoginVal;
    if (rawFirstLogin is bool) {
      isFirstLoginVal = rawFirstLogin;
    } else if (rawFirstLogin is String) {
      isFirstLoginVal = rawFirstLogin.toLowerCase() == 'true' || rawFirstLogin == '1';
    } else if (rawFirstLogin is num) {
      isFirstLoginVal = rawFirstLogin == 1;
    } else {
      isFirstLoginVal = false;
    }

    List<String> parseStringList(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (raw is String) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty) return const [];
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is List) {
              return decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
            }
          } catch (_) {}
        }
        return trimmed.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
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

    final statsMap = (rider['stats'] is Map<String, dynamic>)
        ? rider['stats'] as Map<String, dynamic>
        : (json['stats'] is Map<String, dynamic>)
            ? json['stats'] as Map<String, dynamic>
            : null;

    final walletMap = (rider['wallet'] is Map<String, dynamic>)
        ? rider['wallet'] as Map<String, dynamic>
        : (json['wallet'] is Map<String, dynamic>)
            ? json['wallet'] as Map<String, dynamic>
            : null;

    final ratingVal = (rider['rating'] as num?)?.toDouble() ??
        (rider['avgRating'] as num?)?.toDouble() ??
        (rider['averageRating'] as num?)?.toDouble() ??
        (statsMap?['rating'] as num?)?.toDouble() ??
        (json['rating'] as num?)?.toDouble() ??
        (json['avgRating'] as num?)?.toDouble() ??
        5.0;

    final totalTripsVal = (rider['totalTrips'] as num?)?.toInt() ??
        (rider['totalDeliveries'] as num?)?.toInt() ??
        (rider['completedDeliveriesCount'] as num?)?.toInt() ??
        (rider['completedDeliveries'] as num?)?.toInt() ??
        (rider['completedOrders'] as num?)?.toInt() ??
        (rider['tripsCount'] as num?)?.toInt() ??
        (rider['total_trips'] as num?)?.toInt() ??
        (statsMap?['completedDeliveriesCount'] as num?)?.toInt() ??
        (statsMap?['totalDeliveries'] as num?)?.toInt() ??
        (json['totalTrips'] as num?)?.toInt() ??
        (json['totalDeliveries'] as num?)?.toInt() ??
        0;

    final walletBalanceVal = (rider['walletBalance'] as num?)?.toDouble() ??
        (rider['wallet_balance'] as num?)?.toDouble() ??
        (rider['balance'] as num?)?.toDouble() ??
        (rider['totalEarnings'] as num?)?.toDouble() ??
        (rider['earnings'] as num?)?.toDouble() ??
        (walletMap?['balance'] as num?)?.toDouble() ??
        (walletMap?['amount'] as num?)?.toDouble() ??
        (statsMap?['totalEarnings'] as num?)?.toDouble() ??
        (json['walletBalance'] as num?)?.toDouble() ??
        (json['balance'] as num?)?.toDouble() ??
        (json['totalEarnings'] as num?)?.toDouble() ??
        0.0;

    return RiderModel(
      id: rider['id'] as String? ?? json['id'] as String? ?? user?['id'] as String? ?? '',
      name: nameVal,
      phone: phoneVal,
      email: emailVal,
      avatar: avatarVal,
      rating: ratingVal,
      totalTrips: totalTripsVal,
      isOnline: (rider['isOnline'] as bool?) ?? (json['isOnline'] as bool?) ?? false,
      walletBalance: walletBalanceVal,
      approvalStatus: statusStr,
      isApproved: isApprovedVal,
      isSuspended: isSuspendedVal,
      status: statusStr,
      onboardingCompleted: onboardingCompletedVal,
      isFirstLogin: isFirstLoginVal,
      adminFeedback: rider['adminFeedback'] as String? ?? json['adminFeedback'] as String?,
      vehicleTypes: ((rider['vehicleTypes'] ?? json['vehicleTypes']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['2_WHEELER'],
      vehicleType: rider['vehicleType'] as String? ?? json['vehicleType'] as String? ?? '2_WHEELER',
      vehicleName: rider['vehicleName'] as String? ?? json['vehicleName'] as String?,
      vehicleNumber: rider['vehicleNumber'] as String? ??
          rider['vehicle_number'] as String? ??
          json['vehicleNumber'] as String? ??
          json['vehicle_number'] as String? ??
          (rider['vehicle'] is Map
              ? (rider['vehicle']['licensePlate'] as String? ?? rider['vehicle']['vehicleNumber'] as String?)
              : null),
      drivingLicenseNo: rider['drivingLicenseNo'] as String? ??
          rider['driving_license_no'] as String? ??
          rider['drivingLicense'] as String? ??
          json['drivingLicenseNo'] as String? ??
          json['driving_license_no'] as String? ??
          json['drivingLicense'] as String?,
      profileImage: rider['profileImage'] as String? ?? json['profileImage'] as String? ?? avatarVal,
      drivingLicenseDoc: rider['drivingLicenseDoc'] as String? ?? json['drivingLicenseDoc'] as String?,
      nationalIdDoc: rider['nationalIdDoc'] as String? ?? json['nationalIdDoc'] as String?,
      vehicleInsuranceDoc: rider['vehicleInsuranceDoc'] as String? ?? json['vehicleInsuranceDoc'] as String?,
      selectedZones: parseStringList(
        rider['selectedZones'] ??
            rider['selected_zones'] ??
            rider['operatingZones'] ??
            rider['operating_zones'] ??
            rider['zones'] ??
            json['selectedZones'] ??
            json['selected_zones'] ??
            json['operatingZones'] ??
            json['zones'],
      ),
      selectedLocations: parseStringList(
        rider['selectedLocations'] ??
            rider['selected_locations'] ??
            rider['locations'] ??
            json['selectedLocations'] ??
            json['selected_locations'],
      ),
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
              : (rider['paymentOption'] != null ||
                      rider['bankName'] != null ||
                      rider['mobileMoneyOption'] != null ||
                      rider['accountNumber'] != null ||
                      rider['mobileNumber'] != null ||
                      rider['preferredPayoutMethod'] != null)
                  ? PayoutInfoModel.fromJson(rider)
                  : (json['paymentOption'] != null ||
                          json['bankName'] != null ||
                          json['mobileMoneyOption'] != null ||
                          json['accountNumber'] != null ||
                          json['mobileNumber'] != null ||
                          json['preferredPayoutMethod'] != null)
                      ? PayoutInfoModel.fromJson(json)
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
      'adminFeedback': adminFeedback,
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
      if (payoutInfo != null) ...PayoutInfoModel.fromEntity(payoutInfo!).toPayload(),
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
      adminFeedback: entity.adminFeedback,
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
