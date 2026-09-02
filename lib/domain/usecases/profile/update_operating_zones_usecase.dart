import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/profile_repository.dart';

class UpdateOperatingZonesUseCase {
  final ProfileRepository repository;

  UpdateOperatingZonesUseCase(this.repository);

  Future<Either<Failure, bool>> call(List<String> zoneIds) {
    return repository.updateOperatingZones(zoneIds);
  }
}
