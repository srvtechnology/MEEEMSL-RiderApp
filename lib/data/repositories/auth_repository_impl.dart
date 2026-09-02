import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rider_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/rider_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> login(String phone) async {
    try {
      final result = await remoteDataSource.login(phone);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> loginWithPassword(String email, String password) async {
    try {
      final data = await remoteDataSource.loginWithPassword(email, password);
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final rider = data['rider'] as RiderModel;

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveRider(rider);
      await localDataSource.setIsOnline(rider.isOnline);

      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String identity) async {
    try {
      final result = await remoteDataSource.forgotPassword(identity);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String identity, String otp, String newPassword) async {
    try {
      final result = await remoteDataSource.resetPassword(identity, otp, newPassword);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp) async {
    try {
      final data = await remoteDataSource.verifyOtp(phone, otp);
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final rider = data['rider'] as RiderModel;

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveRider(rider);
      await localDataSource.setIsOnline(rider.isOnline);

      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData) async {
    try {
      final rider = await remoteDataSource.register(riderData);
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity?>> getSavedRider() async {
    try {
      final rider = localDataSource.getSavedRider();
      return Right(rider);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuth();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearAuth();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final currentRefresh = localDataSource.getRefreshToken();
      if (currentRefresh == null) {
        return const Left(AuthFailure(message: 'No refresh token stored'));
      }
      final newToken = await remoteDataSource.refreshToken(currentRefresh);
      await localDataSource.saveToken(newToken);
      return Right(newToken);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
