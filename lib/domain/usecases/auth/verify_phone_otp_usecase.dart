import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/login_response_entity.dart';
import '../../repositories/auth_repository.dart';

class VerifyPhoneOtpUseCase {
  final AuthRepository repository;

  VerifyPhoneOtpUseCase(this.repository);

  Future<Either<Failure, LoginResponseEntity>> call({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) {
    return repository.verifyPhoneOtp(
      phone: phone,
      otp: otp,
      deviceId: deviceId,
      platform: platform,
      deviceToken: deviceToken,
      userAgent: userAgent,
    );
  }
}
