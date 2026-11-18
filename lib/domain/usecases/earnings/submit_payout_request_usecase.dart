import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_ledger_entity.dart';
import '../../repositories/earnings_repository.dart';

class SubmitPayoutRequestUseCase {
  final EarningsRepository repository;

  SubmitPayoutRequestUseCase(this.repository);

  Future<Either<Failure, RiderPayoutRequestEntity>> call({String? sellerNote}) {
    return repository.submitPayoutRequest(sellerNote: sellerNote);
  }
}
