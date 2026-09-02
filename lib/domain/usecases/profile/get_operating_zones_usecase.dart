import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/operating_zone_entity.dart';
import '../../repositories/profile_repository.dart';

class GetOperatingZonesUseCase {
  final ProfileRepository repository;

  GetOperatingZonesUseCase(this.repository);

  Future<Either<Failure, List<OperatingZoneEntity>>> call() {
    return repository.getOperatingZones();
  }
}
