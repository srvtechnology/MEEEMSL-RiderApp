import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/dashboard/toggle_online_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/get_incoming_order_usecase.dart';
import '../../../../domain/usecases/orders/accept_order_usecase.dart';
import '../../../../domain/usecases/orders/decline_order_usecase.dart';
import '../widgets/incoming_order_modal.dart';
import '../../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetIncomingOrderUseCase getIncomingOrderUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final DeclineOrderUseCase declineOrderUseCase;

  DashboardController({
    required this.toggleOnlineStatusUseCase,
    required this.getDashboardSummaryUseCase,
    required this.getActiveOrdersUseCase,
    required this.getIncomingOrderUseCase,
    required this.acceptOrderUseCase,
    required this.declineOrderUseCase,
  });

  // State Observables
  final isOnline = true.obs;
  final isLoading = false.obs;
  final todayEarnings = 148.50.obs;
  final todayDeliveries = 9.obs;
  final totalDeliveries = 1420.obs;
  final approvalStatus = 'Approved'.obs;
  final acceptanceRate = 96.5.obs;
  final rating = 4.92.obs;
  final onlineHours = 5.8.obs;
  
  final activeOrder = Rxn<OrderEntity>();
  final incomingOrder = Rxn<OrderEntity>();
  final countdownSeconds = AppConstants.incomingOrderTimeoutSeconds.obs;
  Timer? _countdownTimer;

  LocationService? get _locationService =>
      Get.isRegistered<LocationService>() ? Get.find<LocationService>() : null;
  NotificationService? get _notificationService =>
      Get.isRegistered<NotificationService>() ? Get.find<NotificationService>() : null;

  @override
  void onInit() {
    super.onInit();
    ever(activeOrder, (OrderEntity? order) {
      _locationService?.setActiveOrderId(order?.id);
    });
    loadDashboardData();
    if (isOnline.value) {
      _locationService?.startTracking();
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    final summaryResult = await getDashboardSummaryUseCase();
    summaryResult.fold(
      (failure) => null,
      (data) {
        todayEarnings.value = (data['todayEarnings'] as num?)?.toDouble() ?? 148.50;
        todayDeliveries.value = (data['todayDeliveries'] as num?)?.toInt() ?? 9;
        totalDeliveries.value = (data['totalTrips'] as num?)?.toInt() ?? 1420;
        acceptanceRate.value = (data['acceptanceRate'] as num?)?.toDouble() ?? 96.5;
        rating.value = (data['rating'] as num?)?.toDouble() ?? 4.92;
        onlineHours.value = (data['onlineHours'] as num?)?.toDouble() ?? 5.8;
      },
    );

    final activeResult = await getActiveOrdersUseCase();
    activeResult.fold(
      (failure) => null,
      (orders) {
        if (orders.isNotEmpty) {
          activeOrder.value = orders.first;
        }
      },
    );
    isLoading.value = false;
  }

  Future<void> toggleOnline() async {
    final newStatus = !isOnline.value;
    final result = await toggleOnlineStatusUseCase(newStatus);
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (status) {
        isOnline.value = status;
        if (status) {
          _locationService?.startTracking();
        } else {
          _locationService?.stopTracking();
        }
        Get.snackbar(
          status ? "You're Online!" : "You're Offline",
          status ? "Ready to receive new orders • Background GPS active" : "You won't receive delivery alerts",
          snackPosition: SnackPosition.TOP,
          backgroundColor: status ? const Color(0xFFE8F8EE) : const Color(0xFFF1F5F9),
          colorText: status ? const Color(0xFF009624) : const Color(0xFF0F172A),
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  // Simulated New Order Ping Trigger
  Future<void> simulateIncomingOrder() async {
    if (!isOnline.value) {
      Get.snackbar('Offline', 'Go online first to receive orders');
      return;
    }
    final result = await getIncomingOrderUseCase();
    result.fold(
      (failure) => null,
      (order) {
        if (order != null) {
          incomingOrder.value = order;
          _notificationService?.playOrderAlertFeedback();
          _showIncomingOrderModal(order);
        }
      },
    );
  }

  void _showIncomingOrderModal(OrderEntity order) {
    _countdownTimer?.cancel();
    countdownSeconds.value = AppConstants.incomingOrderTimeoutSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
        if (Get.isBottomSheetOpen == true) {
          Get.back(); // close modal
        }
        incomingOrder.value = null;
        Get.snackbar('Missed Request', 'The order request has expired.', snackPosition: SnackPosition.TOP);
      }
    });

    Get.bottomSheet(
      IncomingOrderModal(order: order),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }

  Future<void> acceptIncomingOrder() async {
    final order = incomingOrder.value;
    if (order == null) return;

    _countdownTimer?.cancel();
    if (Get.isBottomSheetOpen == true) {
      Get.back(); // close bottom sheet
    }

    isLoading.value = true;
    final result = await acceptOrderUseCase(order.id);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (accepted) {
        activeOrder.value = accepted;
        incomingOrder.value = null;
        Get.toNamed(AppRoutes.activeOrder);
      },
    );
  }

  Future<void> declineIncomingOrder(String reason) async {
    final order = incomingOrder.value;
    if (order == null) return;

    _countdownTimer?.cancel();
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    await declineOrderUseCase(order.id, reason);
    incomingOrder.value = null;
    Get.snackbar('Declined', 'Order declined ($reason)', snackPosition: SnackPosition.BOTTOM);
  }
}
