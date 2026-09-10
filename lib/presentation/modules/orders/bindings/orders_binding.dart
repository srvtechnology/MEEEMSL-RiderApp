import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/order_remote_datasource.dart';
import '../../../../data/repositories/order_repository_impl.dart';
import '../../../../domain/repositories/order_repository.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/cancel_trip_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();

    if (!Get.isRegistered<OrderRemoteDataSource>()) {
      Get.lazyPut<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(dioClient));
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(() => OrderRepositoryImpl(
        remoteDataSource: Get.find<OrderRemoteDataSource>(),
      ));
    }

    if (!Get.isRegistered<GetActiveOrdersUseCase>()) {
      Get.lazyPut(() => GetActiveOrdersUseCase(Get.find<OrderRepository>()));
    }
    if (!Get.isRegistered<UpdateOrderStatusUseCase>()) {
      Get.lazyPut(() => UpdateOrderStatusUseCase(Get.find<OrderRepository>()));
    }
    if (!Get.isRegistered<CancelTripUseCase>()) {
      Get.lazyPut(() => CancelTripUseCase(Get.find<OrderRepository>()));
    }
    if (!Get.isRegistered<GetOrderHistoryUseCase>()) {
      Get.lazyPut(() => GetOrderHistoryUseCase(Get.find<OrderRepository>()));
    }
    if (!Get.isRegistered<GetOrderDetailsUseCase>()) {
      Get.lazyPut(() => GetOrderDetailsUseCase(Get.find<OrderRepository>()));
    }

    if (!Get.isRegistered<OrdersController>()) {
      Get.lazyPut<OrdersController>(() => OrdersController(
        getActiveOrdersUseCase: Get.find<GetActiveOrdersUseCase>(),
        updateOrderStatusUseCase: Get.find<UpdateOrderStatusUseCase>(),
        cancelTripUseCase: Get.find<CancelTripUseCase>(),
        getOrderHistoryUseCase: Get.find<GetOrderHistoryUseCase>(),
        getOrderDetailsUseCase: Get.find<GetOrderDetailsUseCase>(),
      ));
    }
  }
}
