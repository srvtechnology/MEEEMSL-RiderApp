import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetActiveOrdersUseCase {
  final OrderRepository repository;
  GetActiveOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getActiveOrders();
  }
}
