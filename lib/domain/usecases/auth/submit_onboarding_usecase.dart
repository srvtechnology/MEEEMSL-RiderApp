import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class SubmitOnboardingUseCase {
  final AuthRepository repository;

  SubmitOnboardingUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call({
    required List<String> vehicleTypes,
    required String vehicleName,
    required String vehicleNumber,
    required String drivingLicenseNo,
    required List<String> selectedZones,
    required List<String> selectedLocations,
    required Map<String, dynamic> address,
    required Map<String, dynamic> emergencyContact,
    required Map<String, dynamic> payoutInfo,
    String? profileImagePath,
    String? drivingLicenseFrontPath,
    String? drivingLicenseBackPath,
    String? nationalIdPath,
  }) {
    return repository.submitOnboarding(
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
      drivingLicenseFrontPath: drivingLicenseFrontPath,
      drivingLicenseBackPath: drivingLicenseBackPath,
      nationalIdPath: nationalIdPath,
    );
  }
}
