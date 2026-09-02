import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/earnings_entity.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EarningsEntity>> getEarningsBreakdown(String period);
  Future<Either<Failure, bool>> requestPayout(double amount, String paymentMethod);
}
