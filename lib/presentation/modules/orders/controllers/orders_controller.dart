import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/order_model.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/cancel_trip_usecase.dart';
import '../../../../domain/usecases/orders/get_order_history_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../earnings/controllers/earnings_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../widgets/delivery_proof_dialog.dart';
import '../widgets/pickup_proof_dialog.dart';
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
  final isTransitioningStatus = false.obs;
  final activeOrders = <OrderEntity>[].obs;
  final orderHistory = <OrderEntity>[].obs;
  final selectedOrder = Rxn<OrderEntity>();
  final historyFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      Get.closeAllSnackbars();
    } catch (_) {}
    final storage = Get.isRegistered<GetStorage>() ? Get.find<GetStorage>() : null;
    if (storage != null) {
      try {
        final raw = storage.read(AppConstants.activeOrderKey);
        if (raw != null && raw is Map) {
          final cached = OrderModel.fromJson(Map<String, dynamic>.from(raw));
          if (cached.status != OrderStatus.delivered && cached.status != OrderStatus.cancelled) {
            selectedOrder.value = cached;
            activeOrders.assignAll([cached]);
          }
        }

        final historyRaw = storage.read(AppConstants.orderHistoryKey);
        if (historyRaw is List) {
          final cachedHistory = <OrderEntity>[];
          for (final item in historyRaw) {
            if (item is Map) {
              try {
                cachedHistory.add(OrderModel.fromJson(Map<String, dynamic>.from(item)));
              } catch (_) {}
            }
          }
          if (cachedHistory.isNotEmpty) {
            orderHistory.assignAll(cachedHistory);
          }
        }
      } catch (_) {}
    }

    ever(selectedOrder, (OrderEntity? order) {
      if (Get.isRegistered<LocationService>()) {
        Get.find<LocationService>().setActiveOrderId(order?.id);
      }
    });
    loadOrders();
  }

  void setActiveOrder(OrderEntity order) {
    try {
      Get.closeAllSnackbars();
    } catch (_) {}
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
    if (selectedOrder.value == null && orderHistory.isEmpty) {
      isLoading.value = true;
    }
    await Future.wait([
      _loadActiveOrders(),
      _loadHistory(),
    ]);
    isLoading.value = false;
  }

  Future<void> refreshOrders() => loadOrders();

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
              final mergedPhotos = matching.pickupProofPhotos.isNotEmpty
                  ? matching.pickupProofPhotos
                  : (selectedOrder.value?.pickupProofPhotos ?? const <String>[]);
              if (matching.status.index >= selectedOrder.value!.status.index) {
                selectedOrder.value = matching.copyWith(pickupProofPhotos: mergedPhotos);
              } else {
                // Prevent status regression from stale backend read replica
                selectedOrder.value = matching.copyWith(
                  status: selectedOrder.value!.status,
                  pickupProofPhotos: mergedPhotos,
                );
              }
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
    final filterVal = historyFilter.value;
    final result = await getOrderHistoryUseCase(
      statusFilter: (filterVal == 'all' || filterVal.isEmpty) ? null : filterVal,
    );
    result.fold(
      (failure) {
        debugPrint('[OrdersController] _loadHistory failure: ${failure.message}');
      },
      (orders) {
        final combined = <OrderEntity>[];
        final seenKeys = <String>{};

        void addUnique(List<OrderEntity> list) {
          for (final o in list) {
            final key = o.id.isNotEmpty ? o.id : (o.assignmentId ?? o.orderNumber);
            if (!seenKeys.contains(key)) {
              seenKeys.add(key);
              combined.add(o);
            }
          }
        }

        // Under 'all' or 'active', ensure any active order in memory/storage is visible at top
        if (historyFilter.value == 'all' || historyFilter.value == 'active') {
          addUnique(activeOrders);
          if (selectedOrder.value != null &&
              selectedOrder.value!.status != OrderStatus.delivered &&
              selectedOrder.value!.status != OrderStatus.cancelled) {
            addUnique([selectedOrder.value!]);
          }
        }

        addUnique(orders);

        final filter = historyFilter.value.toLowerCase().trim();
        if (filter == 'all' || filter.isEmpty) {
          orderHistory.assignAll(combined);
        } else if (filter == 'delivered' || filter == 'completed') {
          orderHistory.assignAll(combined.where((o) => o.status == OrderStatus.delivered).toList());
        } else if (filter == 'cancelled') {
          orderHistory.assignAll(combined.where((o) => o.status == OrderStatus.cancelled).toList());
        } else if (filter == 'active') {
          orderHistory.assignAll(combined.where((o) =>
              o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList());
        } else {
          orderHistory.assignAll(combined.where((o) => o.status.name.toLowerCase() == filter).toList());
        }
      },
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
        // Step 3: Requires Package Pickup Proof Photos (1 to 5 photos)
        if (Get.overlayContext != null || Get.context != null) {
          Get.dialog(PickupProofDialog(
            order: current,
            onConfirmed: (photoPaths) => _confirmPackagePickup(current.id, photoPaths),
          ));
          return;
        }
        nextStatus = OrderStatus.pickedUp;
        break;
      case OrderStatus.pickedUp:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        // Step 5: Requires Proof of Delivery (Customer OTP + optional Photo)
        if (Get.overlayContext != null || Get.context != null) {
          Get.dialog(DeliveryProofDialog(
            order: current,
            onConfirmed: (photoUrl, otp) => _completeDelivery(current.id, photoUrl, otp),
          ));
          return;
        }
        nextStatus = OrderStatus.delivered;
        break;
      default:
        return;
    }

    isTransitioningStatus.value = true;
    isLoading.value = true;
    final targetId = (current.assignmentId != null && current.assignmentId!.isNotEmpty)
        ? current.assignmentId!
        : current.id;
    final result = await updateOrderStatusUseCase(targetId, nextStatus);
    isLoading.value = false;
    isTransitioningStatus.value = false;

    result.fold(
      (failure) {
        if (Get.overlayContext != null) {
          Get.snackbar(
            'Status Update Failed',
            failure.message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFFB91C1C),
          );
        }
      },
      (updated) {
        setActiveOrder(updated);
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.activeOrder.value = updated;
          dash.isOnline.value = true;
        }
        if (Get.isRegistered<LocationService>()) {
          Get.find<LocationService>().startTracking();
        }
        if (Get.isRegistered<GetStorage>()) {
          try {
            Get.find<GetStorage>().write(AppConstants.isOnlineKey, true);
          } catch (_) {}
        }
        _loadActiveOrders();
        if (Get.overlayContext != null) {
          Get.snackbar(
            'Status Updated',
            '${updated.status.stepNumberText}: ${updated.status.displayName}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
            colorText: const Color(0xFF009624),
          );
        }
      },
    );
  }

  Future<bool> _confirmPackagePickup(String orderId, List<String> photoPaths) async {
    if (photoPaths.length < 2) {
      if (Get.overlayContext != null) {
        Get.snackbar(
          'Photos Required',
          'Please capture at least 2 photos before confirming package pickup.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFEE2E2),
          colorText: const Color(0xFFB91C1C),
        );
      }
      return false;
    }

    final current = selectedOrder.value;
    final targetId = (current != null && current.assignmentId != null && current.assignmentId!.isNotEmpty)
        ? current.assignmentId!
        : orderId;

    isTransitioningStatus.value = true;
    isLoading.value = true;
    final result = await updateOrderStatusUseCase(
      targetId,
      OrderStatus.pickedUp,
      pickupPhotos: photoPaths,
    );
    isLoading.value = false;
    isTransitioningStatus.value = false;

    return result.fold(
      (failure) {
        if (Get.overlayContext != null) {
          Get.snackbar(
            'Pickup Update Failed',
            failure.message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFFEE2E2),
            colorText: const Color(0xFFB91C1C),
          );
        }
        return false;
      },
      (updated) {
        setActiveOrder(updated);
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.activeOrder.value = updated;
          dash.isOnline.value = true;
        }
        if (Get.isRegistered<LocationService>()) {
          Get.find<LocationService>().startTracking();
        }
        if (Get.isRegistered<GetStorage>()) {
          try {
            Get.find<GetStorage>().write(AppConstants.isOnlineKey, true);
          } catch (_) {}
        }
        _loadActiveOrders();
        if (Get.overlayContext != null) {
          Get.snackbar(
            'Package Collected & Verified',
            '${updated.status.stepNumberText}: ${updated.status.displayName}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
            colorText: const Color(0xFF009624),
          );
        }
        return true;
      },
    );
  }

  Future<void> _completeDelivery(String orderId, String? photoUrl, String? otp) async {
    final current = selectedOrder.value;
    final targetId = (current != null && current.assignmentId != null && current.assignmentId!.isNotEmpty)
        ? current.assignmentId!
        : orderId;
    isTransitioningStatus.value = true;
    isLoading.value = true;
    final result = await updateOrderStatusUseCase(
      targetId,
      OrderStatus.delivered,
      proofPhotoUrl: photoUrl,
      customerOtp: otp,
    );
    isLoading.value = false;
    isTransitioningStatus.value = false;

    result.fold(
      (failure) => Get.snackbar('Delivery Failed', failure.message),
      (updated) {
        selectedOrder.value = null;
        _loadActiveOrders();
        _loadHistory();

        // Immediately clear dashboard active order so card vanishes at once
        // (without waiting for loadDashboardData async round-trip)
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.activeOrder.value = null;
          dash.loadDashboardData();
        }

        // Immediately refresh Rider Revenue & Earnings Engine (Part 6 Section 6 & 8 #8)
        if (Get.isRegistered<EarningsController>()) {
          Get.find<EarningsController>().loadRevenue(showLoading: false);
          Get.find<EarningsController>().loadEarnings();
        }

        // Immediately refresh Profile stats as well
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadAllProfileData();
        }

        Get.offNamed(AppRoutes.main);
        if (Get.overlayContext != null) {
          Get.snackbar('🎉 Delivered Successfully!', 'Great job! Delivery charge credited to your realized revenue.',
              snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
        }
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

    isTransitioningStatus.value = true;
    isLoading.value = true;
    final result = cancelTripUseCase != null
        ? await cancelTripUseCase!(current.id, reason)
        : await updateOrderStatusUseCase(
            current.id,
            OrderStatus.cancelled,
            cancellationReason: reason,
          );
    isLoading.value = false;
    isTransitioningStatus.value = false;

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
