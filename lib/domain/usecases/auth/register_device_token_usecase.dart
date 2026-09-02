import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class RegisterDeviceTokenUseCase {
  final AuthRepository repository;

  RegisterDeviceTokenUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String token,
    required String deviceId,
    required String platform,
    String? deviceModel,
    String? appVersion,
  }) {
    return repository.registerDeviceToken(
      token: token,
      deviceId: deviceId,
      platform: platform,
      deviceModel: deviceModel,
      appVersion: appVersion,
    );
  }
}
