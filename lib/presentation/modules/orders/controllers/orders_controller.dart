import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/cancel_trip_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../widgets/delivery_proof_dialog.dart';
import '../widgets/cancel_delivery_dialog.dart';
import '../../../routes/app_routes.dart';

class OrdersController extends GetxController {
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final CancelTripUseCase? cancelTripUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  OrdersController({
    required this.getActiveOrdersUseCase,
    required this.updateOrderStatusUseCase,
    this.cancelTripUseCase,
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

  void setActiveOrder(OrderEntity order) {
    selectedOrder.value = order;
    final index = activeOrders.indexWhere((o) =>
        o.id == order.id ||
        (order.assignmentId != null &&
            order.assignmentId!.isNotEmpty &&
            o.assignmentId == order.assignmentId));
    if (index != -1) {
      activeOrders[index] = order;
    } else {
      activeOrders.insert(0, order);
    }
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
        if (orders.isNotEmpty) {
          activeOrders.assignAll(orders);
          if (selectedOrder.value == null ||
              selectedOrder.value!.status == OrderStatus.delivered ||
              selectedOrder.value!.status == OrderStatus.cancelled) {
            selectedOrder.value = orders.first;
          } else {
            final currentId = selectedOrder.value!.id;
            final currentAssignmentId = selectedOrder.value!.assignmentId;
            final matching = orders.where((o) =>
                o.id == currentId ||
                (currentAssignmentId != null &&
                    currentAssignmentId.isNotEmpty &&
                    o.assignmentId == currentAssignmentId)).firstOrNull;
            if (matching != null) {
              selectedOrder.value = matching;
            }
          }
        } else {
          if (selectedOrder.value != null &&
              selectedOrder.value!.status != OrderStatus.delivered &&
              selectedOrder.value!.status != OrderStatus.cancelled) {
            // Keep current in-memory active order so transient network states don't wipe active order
          } else {
            activeOrders.clear();
            selectedOrder.value = null;
          }
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
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().activeOrder.value = updated;
        }
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

        // Immediately refresh Rider Revenue & Earnings Engine (Part 6 Section 6 & 8 #8)
        if (Get.isRegistered<EarningsController>()) {
          Get.find<EarningsController>().loadRevenue(showLoading: false);
          Get.find<EarningsController>().loadEarnings();
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().loadDashboardData();
        }

        Get.offNamed(AppRoutes.main);
        Get.snackbar('🎉 Delivered Successfully!', 'Great job! Delivery charge credited to your realized revenue.',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }

  /// Opens cancellation modal per Part 8 Section 4.3 UI guidelines
  void showCancelDeliveryDialog() {
    final current = selectedOrder.value;
    if (current == null) return;
    Get.dialog(
      CancelDeliveryDialog(
        order: current,
        onConfirmed: (reason) => cancelTrip(reason),
      ),
    );
  }

  /// Emergency Trip Cancellation by Rider (Part 8 Section 4)
  Future<void> cancelTrip(String reason) async {
    final current = selectedOrder.value;
    if (current == null) return;

    // Security check (Section 1 & 4.1): Only allowed while ACCEPTED or AT_PICKUP
    if (current.status != OrderStatus.accepted && current.status != OrderStatus.atPickup) {
      Get.snackbar(
        'Cancellation Restricted',
        'Cannot cancel trip after items have been picked up. Items are in physical possession.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFB91C1C),
      );
      return;
    }

    isLoading.value = true;
    final result = cancelTripUseCase != null
        ? await cancelTripUseCase!(current.id, reason)
        : await updateOrderStatusUseCase(
            current.id,
            OrderStatus.cancelled,
            cancellationReason: reason,
          );
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar(
        'Cancellation Failed',
        failure.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFEE2E2),
      ),
      (updated) {
        selectedOrder.value = null;
        _loadActiveOrders();
        _loadHistory();

        if (Get.isRegistered<LocationService>()) {
          Get.find<LocationService>().setActiveOrderId(null);
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().loadDashboardData();
        }

        Get.offNamed(AppRoutes.main);
        Get.snackbar(
          '🚨 Trip Cancelled',
          'Order #${current.orderNumber} cancelled ($reason). Dispatched to next nearest rider.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFFB91C1C),
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  // Customer Contact Actions
  Future<void> callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Calling $phone...');
    }
  }

  Future<void> messageContact(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Contact', 'Opening SMS for $phone...');
    }
  }
}
