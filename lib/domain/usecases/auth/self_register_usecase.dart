import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/registration_result_entity.dart';
import '../../repositories/auth_repository.dart';

class SelfRegisterUseCase {
  final AuthRepository repository;

  SelfRegisterUseCase(this.repository);

  Future<Either<Failure, RegistrationResultEntity>> call({
    required String name,
    required String phone,
    String? phoneCountryCode,
    String? email,
    required String password,
    String? vehicleType,
    String? vehicleNumber,
    String? drivingLicense,
    String? deviceId,
    String? platform,
  }) {
    return repository.selfRegister(
      name: name,
      phone: phone,
      phoneCountryCode: phoneCountryCode,
      email: email,
      password: password,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      drivingLicense: drivingLicense,
      deviceId: deviceId,
      platform: platform,
    );
  }
}
