import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/vehicle_entity.dart';
import '../../repositories/profile_repository.dart';

class UpdateVehicleUseCase {
  final ProfileRepository repository;

  UpdateVehicleUseCase(this.repository);

  Future<Either<Failure, VehicleEntity>> call(VehicleEntity vehicle) {
    return repository.updateVehicle(vehicle);
  }
}
