import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/earnings_repository.dart';

class RequestPayoutUseCase {
  final EarningsRepository repository;
  RequestPayoutUseCase(this.repository);

  Future<Either<Failure, bool>> call(double amount, String paymentMethod) {
    return repository.requestPayout(amount, paymentMethod);
  }
}
