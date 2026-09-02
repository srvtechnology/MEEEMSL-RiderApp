import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/payout_info_entity.dart';
import '../../repositories/profile_repository.dart';

class UpdatePayoutInfoUseCase {
  final ProfileRepository repository;

  UpdatePayoutInfoUseCase(this.repository);

  Future<Either<Failure, PayoutInfoEntity>> call(PayoutInfoEntity payoutInfo) {
    return repository.updatePayoutInfo(payoutInfo);
  }
}
