import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginWithPasswordUseCase {
  final AuthRepository repository;

  LoginWithPasswordUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(String email, String password) {
    return repository.loginWithPassword(email, password);
  }
}
