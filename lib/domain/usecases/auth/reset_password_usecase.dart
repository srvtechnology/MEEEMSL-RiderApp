import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reset_password_result_entity.dart';
import '../../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, SendResetOtpResultEntity>> sendResetCode(String identity, [String? phoneCountryCode]) {
    return repository.forgotPassword(identity, phoneCountryCode);
  }

  Future<Either<Failure, bool>> confirmReset(String identity, String otp, String newPassword, [String? phoneCountryCode]) {
    return repository.resetPassword(identity, otp, newPassword, phoneCountryCode);
  }
}
