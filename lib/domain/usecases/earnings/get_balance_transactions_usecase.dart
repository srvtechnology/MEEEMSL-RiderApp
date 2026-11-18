import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_ledger_entity.dart';
import '../../repositories/earnings_repository.dart';

class GetBalanceTransactionsUseCase {
  final EarningsRepository repository;

  GetBalanceTransactionsUseCase(this.repository);

  Future<Either<Failure, RiderBalanceLedgerEntity>> call() {
    return repository.getBalanceTransactions();
  }
}
