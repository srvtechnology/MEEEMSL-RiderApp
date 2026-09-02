import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class DashboardRepository {
  Future<Either<Failure, bool>> toggleOnlineStatus(bool isOnline);
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary();
  Future<Either<Failure, void>> updateLiveLocation(double lat, double lng);
}
