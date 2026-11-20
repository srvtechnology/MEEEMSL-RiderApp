import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/email_otp_result_entity.dart';
import '../../repositories/auth_repository.dart';

class SendEmailOtpUseCase {
  final AuthRepository repository;

  SendEmailOtpUseCase(this.repository);

  Future<Either<Failure, SendEmailOtpResultEntity>> call(String email) {
    return repository.sendEmailOtp(email);
  }
}
