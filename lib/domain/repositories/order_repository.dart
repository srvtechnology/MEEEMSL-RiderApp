import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getActiveOrders();
  Future<Either<Failure, OrderEntity?>> getIncomingOrder();
  Future<Either<Failure, OrderEntity>> acceptOrder(String orderId);
  Future<Either<Failure, bool>> declineOrder(String orderId, String reason);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  });
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory({String? statusFilter});
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);
}
