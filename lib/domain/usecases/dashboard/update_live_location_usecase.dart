import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class UpdateLiveLocationUseCase {
  final DashboardRepository repository;
  UpdateLiveLocationUseCase(this.repository);

  Future<Either<Failure, void>> call(double lat, double lng) {
    return repository.updateLiveLocation(lat, lng);
  }
}
