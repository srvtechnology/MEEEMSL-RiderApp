import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class AcceptOrderUseCase {
  final OrderRepository repository;
  AcceptOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId, {OrderEntity? cachedOrder}) {
    return repository.acceptOrder(orderId, cachedOrder: cachedOrder);
  }
}
