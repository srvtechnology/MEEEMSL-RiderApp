import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(RiderEntity rider) {
    return repository.updateProfile(rider);
  }
}
