import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rider_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> login(String phone);
  Future<Either<Failure, RiderEntity>> loginWithPassword(String email, String password);
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp);
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData);
  Future<Either<Failure, bool>> forgotPassword(String identity);
  Future<Either<Failure, bool>> resetPassword(String identity, String otp, String newPassword);
  Future<Either<Failure, RiderEntity?>> getSavedRider();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> refreshToken();
}

