import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class GetSavedAuthUseCase {
  final AuthRepository repository;
  GetSavedAuthUseCase(this.repository);

  Future<Either<Failure, RiderEntity?>> call() {
    return repository.getSavedRider();
  }
}
