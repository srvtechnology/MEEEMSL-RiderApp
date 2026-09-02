import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class UnregisterDeviceTokenUseCase {
  final AuthRepository repository;

  UnregisterDeviceTokenUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String deviceId,
  }) {
    return repository.unregisterDeviceToken(
      deviceId: deviceId,
    );
  }
}
