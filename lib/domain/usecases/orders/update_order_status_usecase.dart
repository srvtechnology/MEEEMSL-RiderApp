import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
    String? cancellationReason,
  }) {
    return repository.updateOrderStatus(
      orderId,
      status,
      proofPhotoUrl: proofPhotoUrl,
      customerOtp: customerOtp,
      cancellationReason: cancellationReason,
    );
  }
}
