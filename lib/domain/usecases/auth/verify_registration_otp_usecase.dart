import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/registration_result_entity.dart';
import '../../repositories/auth_repository.dart';

class VerifyRegistrationOtpUseCase {
  final AuthRepository repository;

  VerifyRegistrationOtpUseCase(this.repository);

  Future<Either<Failure, VerifyRegistrationResultEntity>> call({
    required String email,
    required String otp,
  }) {
    return repository.verifyRegistrationOtp(
      email: email,
      otp: otp,
    );
  }
}
