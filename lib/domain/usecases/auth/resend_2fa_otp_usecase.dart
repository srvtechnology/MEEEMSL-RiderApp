import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/two_factor_resend_result_entity.dart';
import '../../repositories/auth_repository.dart';

class Resend2faOtpUseCase {
  final AuthRepository repository;

  Resend2faOtpUseCase(this.repository);

  Future<Either<Failure, TwoFactorResendResultEntity>> call({
    required String preAuthToken,
  }) {
    return repository.resend2faOtp(
      preAuthToken: preAuthToken,
    );
  }
}
