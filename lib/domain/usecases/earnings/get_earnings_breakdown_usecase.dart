import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/earnings_entity.dart';
import '../../repositories/earnings_repository.dart';

class GetEarningsBreakdownUseCase {
  final EarningsRepository repository;
  GetEarningsBreakdownUseCase(this.repository);

  Future<Either<Failure, EarningsEntity>> call(String period) {
    return repository.getEarningsBreakdown(period);
  }
}
