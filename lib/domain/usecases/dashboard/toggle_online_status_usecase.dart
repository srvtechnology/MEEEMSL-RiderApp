import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class ToggleOnlineStatusUseCase {
  final DashboardRepository repository;
  ToggleOnlineStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(bool isOnline) {
    return repository.toggleOnlineStatus(isOnline);
  }
}
