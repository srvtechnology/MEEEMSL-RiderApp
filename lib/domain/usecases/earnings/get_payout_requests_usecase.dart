import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_ledger_entity.dart';
import '../../repositories/earnings_repository.dart';

class GetPayoutRequestsUseCase {
  final EarningsRepository repository;

  GetPayoutRequestsUseCase(this.repository);

  Future<Either<Failure, RiderPayoutStatusEntity>> call() {
    return repository.getPayoutRequests();
  }
}
