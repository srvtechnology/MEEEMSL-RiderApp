import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/payout_info_entity.dart';
import '../../repositories/profile_repository.dart';

class GetPayoutInfoUseCase {
  final ProfileRepository repository;

  GetPayoutInfoUseCase(this.repository);

  Future<Either<Failure, PayoutInfoEntity?>> call() {
    return repository.getPayoutInfo();
  }
}
