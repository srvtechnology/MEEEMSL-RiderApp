import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderDetailsUseCase {
  final OrderRepository repository;
  GetOrderDetailsUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}
