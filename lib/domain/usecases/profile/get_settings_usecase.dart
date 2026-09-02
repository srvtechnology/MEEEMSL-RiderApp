import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_settings_entity.dart';
import '../../repositories/profile_repository.dart';

class GetSettingsUseCase {
  final ProfileRepository repository;

  GetSettingsUseCase(this.repository);

  Future<Either<Failure, RiderSettingsEntity>> call() {
    return repository.getSettings();
  }
}
