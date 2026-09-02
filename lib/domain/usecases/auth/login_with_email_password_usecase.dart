import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/login_response_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginWithEmailPasswordUseCase {
  final AuthRepository repository;

  LoginWithEmailPasswordUseCase(this.repository);

  Future<Either<Failure, LoginResponseEntity>> call({
    required String email,
    required String password,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) {
    return repository.loginWithEmailPassword(
      email: email,
      password: password,
      deviceId: deviceId,
      platform: platform,
      deviceToken: deviceToken,
      userAgent: userAgent,
    );
  }
}
