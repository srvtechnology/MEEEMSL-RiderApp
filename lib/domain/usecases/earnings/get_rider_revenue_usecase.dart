import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_revenue_entity.dart';
import '../../repositories/earnings_repository.dart';

class GetRiderRevenueUseCase {
  final EarningsRepository repository;

  GetRiderRevenueUseCase(this.repository);

  Future<Either<Failure, RiderRevenueDataEntity>> call({
    String status = 'all',
    String period = 'all',
    String search = '',
  }) {
    return repository.getRiderRevenue(
      status: status,
      period: period,
      search: search,
    );
  }
}
