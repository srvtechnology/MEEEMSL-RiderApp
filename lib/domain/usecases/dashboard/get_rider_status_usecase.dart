import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

/// Conforms to Checklist Point 4:
/// Syncs Rider Online/Offline status via GET /mobileapi/rider/status
class GetRiderStatusUseCase {
  final DashboardRepository repository;

  GetRiderStatusUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getRiderStatus();
  }
}
