import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/login_response_entity.dart';
import '../../repositories/auth_repository.dart';

class Verify2faOtpUseCase {
  final AuthRepository repository;

  Verify2faOtpUseCase(this.repository);

  Future<Either<Failure, LoginResponseEntity>> call({
    required String preAuthToken,
    required String otp,
    String? deviceId,
    String? platform,
    String? deviceToken,
    String? userAgent,
  }) {
    return repository.verify2faOtp(
      preAuthToken: preAuthToken,
      otp: otp,
      deviceId: deviceId,
      platform: platform,
      deviceToken: deviceToken,
      userAgent: userAgent,
    );
  }
}
