import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/login_response_entity.dart';
import '../../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  final AuthRepository repository;

  VerifyEmailOtpUseCase(this.repository);

  Future<Either<Failure, LoginResponseEntity>> call({
    required String email,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) {
    return repository.verifyEmailOtp(
      email: email,
      otp: otp,
      deviceId: deviceId,
      platform: platform,
      deviceToken: deviceToken,
      userAgent: userAgent,
    );
  }
}
