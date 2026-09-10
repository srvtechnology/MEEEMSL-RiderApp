import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> toggleOnlineStatus(bool isOnline) async {
    try {
      final status = await remoteDataSource.toggleOnline(isOnline);
      await localDataSource.setIsOnline(status);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRiderStatus() async {
    try {
      final statusData = await remoteDataSource.getRiderStatus();
      final isOnline = statusData['isOnline'] as bool? ?? false;
      await localDataSource.setIsOnline(isOnline);
      return Right(statusData);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary() async {
    try {
      final summary = await remoteDataSource.getSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLiveLocation(double lat, double lng) async {
    try {
      await remoteDataSource.updateLocation(lat, lng);
      return const Right(null);
    } catch (_) {
      return const Right(null);
    }
  }
}
