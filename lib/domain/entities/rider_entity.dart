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
  final String approvalStatus; // pending, approved, under_review, rejected, SUSPENDED

  // API Doc Part 1 specification fields
  final bool isApproved;
  final bool isSuspended;
  final String status;
  final bool onboardingCompleted;
  final bool isFirstLogin;
  final List<String> vehicleTypes;
  final String? vehicleType;
  final String? vehicleName;
  final String? vehicleNumber;
  final String? drivingLicenseNo;
  final String? profileImage;
  final String? drivingLicenseDoc;
  final String? nationalIdDoc;
  final String? vehicleInsuranceDoc;
  final List<String> selectedZones;
  final List<String> selectedLocations;

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
    this.isApproved = true,
    this.isSuspended = false,
    this.status = 'APPROVED',
    this.onboardingCompleted = false,
    this.isFirstLogin = false,
    this.vehicleTypes = const ['2_WHEELER'],
    this.vehicleType = '2_WHEELER',
    this.vehicleName,
    this.vehicleNumber,
    this.drivingLicenseNo,
    this.profileImage,
    this.drivingLicenseDoc,
    this.nationalIdDoc,
    this.vehicleInsuranceDoc,
    this.selectedZones = const [],
    this.selectedLocations = const [],
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
    bool? isApproved,
    bool? isSuspended,
    String? status,
    bool? onboardingCompleted,
    bool? isFirstLogin,
    List<String>? vehicleTypes,
    String? vehicleType,
    String? vehicleName,
    String? vehicleNumber,
    String? drivingLicenseNo,
    String? profileImage,
    String? drivingLicenseDoc,
    String? nationalIdDoc,
    String? vehicleInsuranceDoc,
    List<String>? selectedZones,
    List<String>? selectedLocations,
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
      isApproved: isApproved ?? this.isApproved,
      isSuspended: isSuspended ?? this.isSuspended,
      status: status ?? this.status,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      drivingLicenseNo: drivingLicenseNo ?? this.drivingLicenseNo,
      profileImage: profileImage ?? this.profileImage,
      drivingLicenseDoc: drivingLicenseDoc ?? this.drivingLicenseDoc,
      nationalIdDoc: nationalIdDoc ?? this.nationalIdDoc,
      vehicleInsuranceDoc: vehicleInsuranceDoc ?? this.vehicleInsuranceDoc,
      selectedZones: selectedZones ?? this.selectedZones,
      selectedLocations: selectedLocations ?? this.selectedLocations,
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
        isApproved,
        isSuspended,
        status,
        onboardingCompleted,
        isFirstLogin,
        vehicleTypes,
        vehicleType,
        vehicleName,
        vehicleNumber,
        drivingLicenseNo,
        profileImage,
        drivingLicenseDoc,
        nationalIdDoc,
        vehicleInsuranceDoc,
        selectedZones,
        selectedLocations,
        vehicle,
        payoutInfo,
        operatingZones,
      ];
}
