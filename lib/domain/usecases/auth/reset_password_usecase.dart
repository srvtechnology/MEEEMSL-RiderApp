import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, bool>> sendResetCode(String identity) {
    return repository.forgotPassword(identity);
  }

  Future<Either<Failure, bool>> confirmReset(String identity, String otp, String newPassword) {
    return repository.resetPassword(identity, otp, newPassword);
  }
}
