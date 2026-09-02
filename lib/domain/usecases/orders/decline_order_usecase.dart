import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/order_repository.dart';

class DeclineOrderUseCase {
  final OrderRepository repository;
  DeclineOrderUseCase(this.repository);

  Future<Either<Failure, bool>> call(String orderId, String reason) {
    return repository.declineOrder(orderId, reason);
  }
}
