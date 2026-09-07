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
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../widgets/incoming_order_modal.dart';
import '../../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetIncomingOrderUseCase getIncomingOrderUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final DeclineOrderUseCase declineOrderUseCase;
  final UpdateOrderStatusUseCase? updateOrderStatusUseCase;

  DashboardController({
    required this.toggleOnlineStatusUseCase,
    required this.getDashboardSummaryUseCase,
    required this.getActiveOrdersUseCase,
    required this.getIncomingOrderUseCase,
    required this.acceptOrderUseCase,
    required this.declineOrderUseCase,
    this.updateOrderStatusUseCase,
  });

  UpdateOrderStatusUseCase? get _orderStatusUseCase =>
      updateOrderStatusUseCase ??
      (Get.isRegistered<UpdateOrderStatusUseCase>()
          ? Get.find<UpdateOrderStatusUseCase>()
          : null);

  AuthLocalDataSource? get _authLocalDataSource =>
      Get.isRegistered<AuthLocalDataSource>()
          ? Get.find<AuthLocalDataSource>()
          : null;

  String get riderName {
    final rider = _authLocalDataSource?.getSavedRider();
    final user = _authLocalDataSource?.getSavedUser();
    return rider?.name ?? user?.name ?? 'Ibrahim Koroma';
  }

  String get riderInitials {
    final name = riderName.trim();
    if (name.isEmpty) return 'R';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get riderZone {
    final rider = _authLocalDataSource?.getSavedRider();
    final locs = rider?.selectedLocations;
    if (locs != null && locs.isNotEmpty) {
      return locs.take(2).join(', ');
    }
    final zones = rider?.selectedZones;
    if (zones != null && zones.isNotEmpty) {
      return zones.first;
    }
    return 'Western Area (Freetown)';
  }

  String get vehicleTypeInfo {
    final rider = _authLocalDataSource?.getSavedRider();
    final v = rider?.vehicleType ?? rider?.vehicleName;
    if (v != null && v.isNotEmpty) {
      return v.replaceAll('_', ' ');
    }
    return '2-Wheeler (≤15kg)';
  }

  LocationService? get locationService => _locationService;

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

  /// Advances the status of the active delivery order per Section 5.1
  Future<void> advanceActiveOrderMilestone() async {
    final current = activeOrder.value;
    if (current == null) return;

    if (current.status == OrderStatus.outForDelivery) {
      // Step 5 requires customer OTP handover verification in active order view
      Get.toNamed(AppRoutes.activeOrder);
      return;
    }

    final useCase = _orderStatusUseCase;
    if (useCase == null) {
      Get.toNamed(AppRoutes.activeOrder);
      return;
    }

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
      default:
        return;
    }

    isLoading.value = true;
    final result = await useCase(current.id, nextStatus);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Status Update Error', failure.message,
          snackPosition: SnackPosition.TOP),
      (updated) {
        activeOrder.value = updated;
        Get.snackbar(
          'Milestone Updated',
          '${updated.status.stepNumberText}: ${updated.status.displayName}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE8F8EE),
          colorText: const Color(0xFF009624),
        );
      },
    );
  }

  /// Cancels active delivery and re-dispatches order per Section 6.1
  Future<void> emergencyCancelActiveOrder(String reason) async {
    final current = activeOrder.value;
    if (current == null) return;

    final useCase = _orderStatusUseCase;
    isLoading.value = true;
    if (useCase != null) {
      await useCase(current.id, OrderStatus.cancelled);
    }
    isLoading.value = false;
    activeOrder.value = null;
    _locationService?.setActiveOrderId(null);

    Get.snackbar(
      '🚨 Order Reassigned',
      'Order #${current.orderNumber} has been auto-reassigned to the nearest available rider ($reason).',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFEE2E2),
      colorText: const Color(0xFFB91C1C),
      duration: const Duration(seconds: 4),
    );
  }
}
