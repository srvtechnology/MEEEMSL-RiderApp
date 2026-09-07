import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../widgets/delivery_proof_dialog.dart';
import '../../../routes/app_routes.dart';

class OrdersController extends GetxController {
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  OrdersController({
    required this.getActiveOrdersUseCase,
    required this.updateOrderStatusUseCase,
    required this.getOrderHistoryUseCase,
    required this.getOrderDetailsUseCase,
  });

  // State Observables
  final isLoading = false.obs;
  final activeOrders = <OrderEntity>[].obs;
  final orderHistory = <OrderEntity>[].obs;
  final selectedOrder = Rxn<OrderEntity>();
  final historyFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedOrder, (OrderEntity? order) {
      if (Get.isRegistered<LocationService>()) {
        Get.find<LocationService>().setActiveOrderId(order?.id);
      }
    });
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    await Future.wait([
      _loadActiveOrders(),
      _loadHistory(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadActiveOrders() async {
    final result = await getActiveOrdersUseCase();
    result.fold(
      (failure) => null,
      (orders) {
        activeOrders.assignAll(orders);
        if (orders.isNotEmpty) {
          selectedOrder.value = orders.first;
        }
      },
    );
  }

  Future<void> _loadHistory() async {
    final result = await getOrderHistoryUseCase(
      statusFilter: historyFilter.value == 'all' ? null : historyFilter.value,
    );
    result.fold(
      (failure) => null,
      (orders) => orderHistory.assignAll(orders),
    );
  }

  void filterHistory(String filter) {
    historyFilter.value = filter;
    _loadHistory();
  }

  // Order Lifecycle Progression (5 Exact Steps)
  Future<void> advanceActiveOrderStatus() async {
    final current = selectedOrder.value;
    if (current == null) return;

    OrderStatus nextStatus;
    switch (current.status) {
      case OrderStatus.accepted:
        nextStatus = OrderStatus.atPickup;
        break;
      case OrderStatus.atPickup:
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        // Step 5: Requires Proof of Delivery (Customer OTP + optional Photo)
        Get.dialog(DeliveryProofDialog(
          order: current,
          onConfirmed: (photoUrl, otp) => _completeDelivery(current.id, photoUrl, otp),
        ));
        return;
      default:
        return;
    }

    isLoading.value = true;
    final result = await updateOrderStatusUseCase(current.id, nextStatus);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (updated) {
        selectedOrder.value = updated;
        _loadActiveOrders();
        Get.snackbar('Status Updated', '${updated.status.stepNumberText}: ${updated.status.displayName}',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  Future<void> _completeDelivery(String orderId, String? photoUrl, String? otp) async {
    isLoading.value = true;
    final result = await updateOrderStatusUseCase(
      orderId,
      OrderStatus.delivered,
      proofPhotoUrl: photoUrl,
      customerOtp: otp,
    );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Delivery Failed', failure.message),
      (updated) {
        selectedOrder.value = null;
        _loadActiveOrders();
        _loadHistory();
        Get.offNamed(AppRoutes.main);
        Get.snackbar('🎉 Delivered Successfully!', 'Great job! Earnings have been credited to your wallet.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  // Customer Contact Actions
  Future<void> callContact(String phone) async {
    final uri = Uri.parse('tel:\$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Calling \$phone...');
    }
  }

  Future<void> messageContact(String phone) async {
    final uri = Uri.parse('sms:\$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Opening SMS for \$phone...');
    }
  }
}
