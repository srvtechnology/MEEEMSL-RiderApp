import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/phone_otp_result_entity.dart';
import '../../repositories/auth_repository.dart';

class SendPhoneOtpUseCase {
  final AuthRepository repository;

  SendPhoneOtpUseCase(this.repository);

  Future<Either<Failure, SendPhoneOtpResultEntity>> call(String phone) {
    return repository.sendPhoneOtp(phone);
  }
}
