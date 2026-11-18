import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/earnings_entity.dart';
import '../../domain/entities/rider_ledger_entity.dart';
import '../../domain/entities/rider_revenue_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl({required this.remoteDataSource});

  RateLimitFailure _mapRateLimit(RateLimitException e) {
    return RateLimitFailure(
      message: e.message,
      cooldownSeconds: e.cooldownSeconds,
      retryAfter: e.retryAfter,
      type: e.type,
    );
  }

  @override
  Future<Either<Failure, EarningsEntity>> getEarningsBreakdown(String period) async {
    try {
      final earnings = await remoteDataSource.getEarnings(period);
      return Right(earnings);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPayout(double amount, String paymentMethod) async {
    try {
      final result = await remoteDataSource.requestPayout(amount, paymentMethod);
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderRevenueDataEntity>> getRiderRevenue({
    String status = 'all',
    String period = 'all',
    String search = '',
  }) async {
    try {
      final revenue = await remoteDataSource.getRiderRevenue(
        status: status,
        period: period,
        search: search,
      );
      return Right(revenue);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderBalanceLedgerEntity>> getBalanceTransactions() async {
    try {
      final ledger = await remoteDataSource.getBalanceTransactions();
      return Right(ledger);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderPayoutStatusEntity>> getPayoutRequests() async {
    try {
      final status = await remoteDataSource.getPayoutRequests();
      return Right(status);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderPayoutRequestEntity>> submitPayoutRequest({
    String? sellerNote,
  }) async {
    try {
      final request = await remoteDataSource.submitPayoutRequest(
        sellerNote: sellerNote,
      );
      return Right(request);
    } on RateLimitException catch (e) {
      return Left(_mapRateLimit(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
