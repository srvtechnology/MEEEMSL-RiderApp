import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  GetDashboardSummaryUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getDashboardSummary();
  }
}
