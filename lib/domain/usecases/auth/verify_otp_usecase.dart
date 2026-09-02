import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(String phone, String otp) {
    return repository.verifyOtp(phone, otp);
  }
}
