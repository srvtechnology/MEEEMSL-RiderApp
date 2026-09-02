import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/registration_result_entity.dart';
import '../../repositories/auth_repository.dart';

class SelfRegisterUseCase {
  final AuthRepository repository;

  SelfRegisterUseCase(this.repository);

  Future<Either<Failure, RegistrationResultEntity>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String phoneCountryCode,
  }) {
    return repository.selfRegister(
      name: name,
      email: email,
      password: password,
      phone: phone,
      phoneCountryCode: phoneCountryCode,
    );
  }
}
