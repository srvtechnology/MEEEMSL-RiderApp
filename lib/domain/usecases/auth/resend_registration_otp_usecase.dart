import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/registration_result_entity.dart';
import '../../repositories/auth_repository.dart';

class ResendRegistrationOtpUseCase {
  final AuthRepository repository;

  ResendRegistrationOtpUseCase(this.repository);

  Future<Either<Failure, ResendOtpResultEntity>> call({
    required String email,
  }) {
    return repository.resendRegistrationOtp(email: email);
  }
}
