import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

/// Conforms to MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8 Section 4
class CancelTripUseCase {
  final OrderRepository repository;

  CancelTripUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId, String cancellationReason) {
    return repository.cancelTrip(orderId, cancellationReason);
  }
}
