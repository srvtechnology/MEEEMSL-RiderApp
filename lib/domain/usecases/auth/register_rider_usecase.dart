import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterRiderUseCase {
  final AuthRepository repository;
  RegisterRiderUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(Map<String, dynamic> riderData) {
    return repository.register(riderData);
  }
}
