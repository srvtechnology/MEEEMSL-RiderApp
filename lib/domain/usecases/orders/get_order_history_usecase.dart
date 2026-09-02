import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderHistoryUseCase {
  final OrderRepository repository;
  GetOrderHistoryUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({String? statusFilter}) {
    return repository.getOrderHistory(statusFilter: statusFilter);
  }
}
