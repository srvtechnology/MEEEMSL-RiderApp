import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class SubmitOnboardingUseCase {
  final AuthRepository repository;

  SubmitOnboardingUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call({
    String? name,
    String? phone,
    String? phoneCountryCode,
    String? newPassword,
    String? vehicleType,
    List<String>? vehicleTypes,
    String? vehicleName,
    String? vehicleNumber,
    String? drivingLicenseNo,
    required List<String> selectedZones,
    required List<String> selectedLocations,
    Map<String, dynamic>? address,
    Map<String, dynamic>? emergencyContact,
    Map<String, dynamic>? payoutInfo,
    String? profileImagePath,
    String? drivingLicenseDocPath,
    String? nationalIdDocPath,
    String? vehicleInsuranceDocPath,
    String? drivingLicenseFrontPath,
    String? drivingLicenseBackPath,
    String? nationalIdPath,
  }) {
    return repository.submitOnboarding(
      name: name,
      phone: phone,
      phoneCountryCode: phoneCountryCode,
      newPassword: newPassword,
      vehicleType: vehicleType,
      vehicleTypes: vehicleTypes,
      vehicleName: vehicleName,
      vehicleNumber: vehicleNumber,
      drivingLicenseNo: drivingLicenseNo,
      selectedZones: selectedZones,
      selectedLocations: selectedLocations,
      address: address,
      emergencyContact: emergencyContact,
      payoutInfo: payoutInfo,
      profileImagePath: profileImagePath,
      drivingLicenseDocPath: drivingLicenseDocPath,
      nationalIdDocPath: nationalIdDocPath,
      vehicleInsuranceDocPath: vehicleInsuranceDocPath,
      drivingLicenseFrontPath: drivingLicenseFrontPath,
      drivingLicenseBackPath: drivingLicenseBackPath,
      nationalIdPath: nationalIdPath,
    );
  }
}
