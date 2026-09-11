import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../../domain/usecases/dashboard/toggle_online_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_rider_status_usecase.dart';
import '../../../../domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import '../../../../domain/usecases/orders/get_active_orders_usecase.dart';
import '../../../../domain/usecases/orders/get_incoming_order_usecase.dart';
import '../../../../domain/usecases/orders/accept_order_usecase.dart';
import '../../../../domain/usecases/orders/decline_order_usecase.dart';
import '../../../../domain/usecases/orders/update_order_status_usecase.dart';
import '../../../../domain/usecases/orders/get_order_details_usecase.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/models/order_model.dart';
import '../widgets/incoming_order_modal.dart';
import '../../../routes/app_routes.dart';
import '../../orders/controllers/orders_controller.dart';

class DashboardController extends GetxController {
  final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  final GetRiderStatusUseCase? getRiderStatusUseCase;
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetIncomingOrderUseCase getIncomingOrderUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;
  final DeclineOrderUseCase declineOrderUseCase;
  final UpdateOrderStatusUseCase? updateOrderStatusUseCase;
  final GetOrderDetailsUseCase? getOrderDetailsUseCase;

  DashboardController({
    required this.toggleOnlineStatusUseCase,
    this.getRiderStatusUseCase,
    required this.getDashboardSummaryUseCase,
    required this.getActiveOrdersUseCase,
    required this.getIncomingOrderUseCase,
    required this.acceptOrderUseCase,
    required this.declineOrderUseCase,
    this.updateOrderStatusUseCase,
    this.getOrderDetailsUseCase,
  });

  GetRiderStatusUseCase? get _riderStatusUseCase =>
      getRiderStatusUseCase ??
      (Get.isRegistered<GetRiderStatusUseCase>()
          ? Get.find<GetRiderStatusUseCase>()
          : null);

  GetOrderDetailsUseCase? get _orderDetailsUseCase =>
      getOrderDetailsUseCase ??
      (Get.isRegistered<GetOrderDetailsUseCase>()
          ? Get.find<GetOrderDetailsUseCase>()
          : null);

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
  final isOnline = false.obs;
  final isLoading = false.obs;
  final todayEarnings = 0.0.obs;
  final todayDeliveries = 0.obs;
  final totalDeliveries = 0.obs;
  final totalEarnings = 0.0.obs;
  final completedDeliveriesCount = 0.obs;
  final approvalStatus = 'Approved'.obs;
  final acceptanceRate = 100.0.obs;
  final rating = 5.0.obs;
  final onlineHours = 0.0.obs;
  
  final activeOrder = Rxn<OrderEntity>();
  final incomingOrder = Rxn<OrderEntity>();
  final countdownSeconds = AppConstants.incomingOrderTimeoutSeconds.obs;
  Timer? _countdownTimer;

  // Guard against duplicate accept calls (double-tap or multi-path race)
  bool _isAcceptingOrder = false;
  String? _lastAcceptedOrderId;

  LocationService? get _locationService =>
      Get.isRegistered<LocationService>() ? Get.find<LocationService>() : null;
  NotificationService? get _notificationService =>
      Get.isRegistered<NotificationService>() ? Get.find<NotificationService>() : null;

  @override
  void onInit() {
    super.onInit();
    final initialOnline = _authLocalDataSource?.getIsOnline() ?? false;
    isOnline.value = initialOnline;
    if (initialOnline) {
      _locationService?.startTracking();
    } else {
      _locationService?.stopTracking();
    }

    // Step 1: Immediately restore cached active order from GetStorage so there is NO radar flicker
    final storage = Get.isRegistered<GetStorage>() ? Get.find<GetStorage>() : null;
    if (storage != null) {
      try {
        final raw = storage.read(AppConstants.activeOrderKey);
        if (raw != null && raw is Map) {
          final cached = OrderModel.fromJson(Map<String, dynamic>.from(raw));
          if (cached.status != OrderStatus.delivered && cached.status != OrderStatus.cancelled) {
            activeOrder.value = cached;
            debugPrint('[DashboardController] onInit: Restored cached active order ${cached.id} (assignment: ${cached.assignmentId}, status: ${cached.status.name})');
          }
        }
      } catch (e) {
        debugPrint('[DashboardController] onInit: Error restoring cached order: $e');
      }
    }

    // Checklist Point 4: Cross-Device Socket Sync (Single Active Driving Device policy)
    SocketService.onRiderStatusChanged = (bool isServerOnline) {
      if (!isServerOnline) {
        isOnline.value = false;
        _authLocalDataSource?.setIsOnline(false);
        _locationService?.stopTracking();
      }
    };

    SocketService.onActiveDeviceChanged = (Map<String, dynamic> data) {
      String? localDeviceId = Get.isRegistered<DeviceInfoService>()
          ? Get.find<DeviceInfoService>().cachedDeviceId
          : null;
      if (localDeviceId == null || localDeviceId.isEmpty) {
        if (Get.isRegistered<GetStorage>()) {
          try {
            localDeviceId = Get.find<GetStorage>().read<String>(AppConstants.registeredDeviceIdKey);
          } catch (_) {}
        }
      }

      final activeDeviceId = data['activeDeviceId']?.toString();
      if (activeDeviceId != null &&
          localDeviceId != null &&
          activeDeviceId.isNotEmpty &&
          localDeviceId.isNotEmpty &&
          activeDeviceId != localDeviceId) {
        const alertMsg = 'You have switched to another device. Tracking stopped on this device.';
        isOnline.value = false;
        _authLocalDataSource?.setIsOnline(false);
        if (Get.isRegistered<GetStorage>()) {
          try {
            final storage = Get.find<GetStorage>();
            storage.write(AppConstants.isOnlineKey, false);
            storage.remove('online_since_timestamp');
          } catch (_) {}
        }
        if (_locationService != null) {
          _locationService?.handleDeviceSwitched(alertMsg);
        } else {
          LocationService.showDeviceSwitchedDialog(alertMsg);
        }
      }
    };

    ever(activeOrder, (OrderEntity? order) {
      _locationService?.setActiveOrderId(order?.id);
      final storage = Get.isRegistered<GetStorage>() ? Get.find<GetStorage>() : null;
      if (storage != null) {
        try {
          if (order != null && order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) {
            storage.write(AppConstants.activeOrderKey, OrderModel.fromEntity(order).toJson());
          } else {
            storage.remove(AppConstants.activeOrderKey);
          }
        } catch (_) {}
      }
    });
    NotificationService.onNewOffer = (data, {title, body}) {
      handleIncomingOfferPush(data, fallbackTitle: title, fallbackBody: body);
    };
    NotificationService.onDirectAssignment = handleDirectAssignmentPush;
    NotificationService.onAssignmentRevoked = handleAssignmentRevokedPush;
    loadDashboardData();
  }

  @override
  void onClose() {
    NotificationService.onNewOffer = null;
    NotificationService.onDirectAssignment = null;
    NotificationService.onAssignmentRevoked = null;
    SocketService.onRiderStatusChanged = null;
    SocketService.onActiveDeviceChanged = null;
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;

    // Checklist Point 4: Sync database rider status via GET /mobileapi/rider/status on app open/restart
    final riderStatusUseCase = _riderStatusUseCase;
    String? activeAssignmentIdFromStatus;
    String? operationalStatusFromStatus;
    if (riderStatusUseCase != null) {
      final statusResult = await riderStatusUseCase();
      statusResult.fold(
        (failure) => null,
        (data) {
          final backendOnline = data['isOnline'] as bool? ?? false;
          isOnline.value = backendOnline;
          _authLocalDataSource?.setIsOnline(backendOnline);
          if (backendOnline) {
            _locationService?.startTracking();
          } else {
            _locationService?.stopTracking();
          }
          activeAssignmentIdFromStatus = data['activeAssignmentId']?.toString();
          operationalStatusFromStatus = data['operationalStatus']?.toString();
        },
      );
    }

    final summaryResult = await getDashboardSummaryUseCase();
    summaryResult.fold(
      (failure) => null,
      (data) {
        todayEarnings.value = (data['todayEarnings'] as num?)?.toDouble() ?? 0.0;
        todayDeliveries.value = (data['todayDeliveries'] as num?)?.toInt() ?? 0;
        totalDeliveries.value = (data['totalTrips'] as num?)?.toInt() ?? 0;
        totalEarnings.value = (data['totalEarnings'] as num?)?.toDouble() ?? 640.0;
        completedDeliveriesCount.value = (data['completedDeliveriesCount'] as num?)?.toInt() ?? totalDeliveries.value;
        acceptanceRate.value = (data['acceptanceRate'] as num?)?.toDouble() ?? 100.0;
        rating.value = (data['rating'] as num?)?.toDouble() ?? 5.0;
        onlineHours.value = (data['onlineHours'] as num?)?.toDouble() ?? 0.0;
      },
    );

    final activeResult = await getActiveOrdersUseCase();
    List<OrderEntity> orders = [];
    activeResult.fold(
      (failure) {
        debugPrint('[DashboardController] getActiveOrdersUseCase failure: ${failure.message}');
      },
      (data) {
        orders = List.from(data);
      },
    );

    // If activeResult returned empty, but status reports activeAssignmentId or ON_DELIVERY, attempt single order fetch
    if (orders.isEmpty && (activeAssignmentIdFromStatus != null || operationalStatusFromStatus == 'ON_DELIVERY')) {
      final idToFetch = activeAssignmentIdFromStatus ?? activeOrder.value?.assignmentId ?? activeOrder.value?.id;
      if (idToFetch != null && idToFetch.isNotEmpty && _orderDetailsUseCase != null) {
        final detailsResult = await _orderDetailsUseCase!(idToFetch);
        detailsResult.fold(
          (failure) => null,
          (fetchedOrder) {
            if (fetchedOrder.status != OrderStatus.delivered && fetchedOrder.status != OrderStatus.cancelled) {
              orders = [fetchedOrder];
            }
          },
        );
      }
    }

    debugPrint('[DashboardController] getActiveOrders resolved ${orders.length} orders. Current activeOrder: ${activeOrder.value?.id} (${activeOrder.value?.status})');
    if (orders.isNotEmpty) {
      final fetched = orders.first;
      if (activeOrder.value != null &&
          (activeOrder.value!.id == fetched.id ||
              (activeOrder.value!.assignmentId != null &&
                  activeOrder.value!.assignmentId == fetched.assignmentId))) {
        if (fetched.status.index >= activeOrder.value!.status.index) {
          activeOrder.value = fetched;
        } else {
          // Preserve active status from local progression
          activeOrder.value = fetched.copyWith(status: activeOrder.value!.status);
        }
      } else {
        activeOrder.value = fetched;
      }
      if (Get.isRegistered<OrdersController>()) {
        final ordersCtrl = Get.find<OrdersController>();
        ordersCtrl.setActiveOrder(activeOrder.value!);
      }
    } else {
      if (activeOrder.value != null &&
          activeOrder.value!.status != OrderStatus.delivered &&
          activeOrder.value!.status != OrderStatus.cancelled) {
        // Keep current in-memory active order so transient network states or empty responses don't wipe active order
        debugPrint('[DashboardController] orders empty, retaining activeOrder ${activeOrder.value!.id} (${activeOrder.value!.status.name})');
        if (Get.isRegistered<OrdersController>()) {
          final ordersCtrl = Get.find<OrdersController>();
          ordersCtrl.setActiveOrder(activeOrder.value!);
        }
      } else {
        // Check local storage one last time before clearing
        final storage = Get.isRegistered<GetStorage>() ? Get.find<GetStorage>() : null;
        OrderModel? cached;
        if (storage != null) {
          try {
            final raw = storage.read(AppConstants.activeOrderKey);
            if (raw != null && raw is Map) {
              cached = OrderModel.fromJson(Map<String, dynamic>.from(raw));
            }
          } catch (_) {}
        }

        if (cached != null && cached.status != OrderStatus.delivered && cached.status != OrderStatus.cancelled) {
          activeOrder.value = cached;
          if (Get.isRegistered<OrdersController>()) {
            Get.find<OrdersController>().setActiveOrder(cached);
          }
        } else {
          activeOrder.value = null;
          _locationService?.setActiveOrderId(null);
          if (Get.isRegistered<OrdersController>()) {
            final ordersCtrl = Get.find<OrdersController>();
            if (ordersCtrl.selectedOrder.value != null &&
                (ordersCtrl.selectedOrder.value!.status == OrderStatus.delivered ||
                 ordersCtrl.selectedOrder.value!.status == OrderStatus.cancelled)) {
              ordersCtrl.selectedOrder.value = null;
            }
          }
        }
      }
    }
    isLoading.value = false;
  }

  Future<void> toggleOnline() async {
    final newStatus = !isOnline.value;

    // If attempting to go online, verify/request location permissions first
    if (newStatus) {
      await _locationService?.checkAndRequestPermissions();
    }

    final result = await toggleOnlineStatusUseCase(newStatus);
    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (status) {
        isOnline.value = status;
        if (status) {
          _locationService?.startTracking();
          // Checklist Point 1: Stream initial GPS coordinates with isOnline: true immediately
          _locationService?.sendLocationUpdate(forceRest: true);
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
        if (Get.isSnackbarOpen == true) {
          Get.closeCurrentSnackbar();
        }
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

    // Guard: prevent duplicate calls from double-taps or concurrent push/modal paths
    final targetId = (order.assignmentId != null && order.assignmentId!.isNotEmpty)
        ? order.assignmentId!
        : order.id;
    if (_isAcceptingOrder) return;
    if (_lastAcceptedOrderId != null && _lastAcceptedOrderId == targetId) {
      debugPrint('[DashboardController] acceptIncomingOrder: already accepted $targetId, skipping duplicate call.');
      return;
    }
    _isAcceptingOrder = true;

    _countdownTimer?.cancel();
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back(); // close bottom sheet
    }

    isLoading.value = true;
    final result = await acceptOrderUseCase(targetId);
    isLoading.value = false;
    _isAcceptingOrder = false;

    result.fold(
      (failure) {
        if (Get.overlayContext != null) {
          Get.snackbar('Error', failure.message);
        }
      },
      (accepted) {
        final finalOrder = OrderEntity(
          id: (accepted.id.isNotEmpty && accepted.id != 'meeem00000042') ? accepted.id : order.id,
          assignmentId: accepted.assignmentId ?? order.assignmentId,
          orderNumber: (accepted.orderNumber.isNotEmpty && accepted.orderNumber != 'meeem00000042') ? accepted.orderNumber : order.orderNumber,
          status: OrderStatus.accepted,
          deliveryOtp: accepted.deliveryOtp.isNotEmpty ? accepted.deliveryOtp : (order.deliveryOtp.isNotEmpty ? order.deliveryOtp : '582910'),
          customerName: accepted.customerName != 'Customer' && accepted.customerName.isNotEmpty ? accepted.customerName : order.customerName,
          customerPhone: accepted.customerPhone.isNotEmpty ? accepted.customerPhone : order.customerPhone,
          customerAvatar: accepted.customerAvatar.isNotEmpty ? accepted.customerAvatar : order.customerAvatar,
          pickupName: accepted.pickupName != 'Store / Vendor' && accepted.pickupName.isNotEmpty ? accepted.pickupName : order.pickupName,
          pickupAddress: accepted.pickupAddress.isNotEmpty ? accepted.pickupAddress : order.pickupAddress,
          pickupPhone: accepted.pickupPhone.isNotEmpty ? accepted.pickupPhone : order.pickupPhone,
          dropoffAddress: accepted.dropoffAddress.isNotEmpty ? accepted.dropoffAddress : order.dropoffAddress,
          pickupLat: accepted.pickupLat != 8.484 ? accepted.pickupLat : order.pickupLat,
          pickupLng: accepted.pickupLng != -13.234 ? accepted.pickupLng : order.pickupLng,
          dropoffLat: accepted.dropoffLat != 8.460 ? accepted.dropoffLat : order.dropoffLat,
          dropoffLng: accepted.dropoffLng != -13.250 ? accepted.dropoffLng : order.dropoffLng,
          items: accepted.items.isNotEmpty ? accepted.items : order.items,
          subtotal: accepted.subtotal > 0 ? accepted.subtotal : order.subtotal,
          riderEarnings: accepted.riderEarnings > 0 ? accepted.riderEarnings : order.riderEarnings,
          distanceKm: accepted.distanceKm > 0 ? accepted.distanceKm : order.distanceKm,
          estimatedDurationMin: accepted.estimatedDurationMin > 0 ? accepted.estimatedDurationMin : order.estimatedDurationMin,
          createdAt: accepted.createdAt,
          notes: accepted.notes.isNotEmpty ? accepted.notes : order.notes,
          proofPhotoUrl: accepted.proofPhotoUrl,
          cycle: accepted.cycle ?? order.cycle,
          riderAttempt: accepted.riderAttempt ?? order.riderAttempt,
        );

        _lastAcceptedOrderId = targetId;
        activeOrder.value = finalOrder;
        incomingOrder.value = null;

        // Synchronize with OrdersController so ActiveOrderView immediately has the order
        if (Get.isRegistered<OrdersController>()) {
          final ordersCtrl = Get.find<OrdersController>();
          ordersCtrl.setActiveOrder(finalOrder);
        }

        Get.toNamed(AppRoutes.activeOrder);
      },
    );
  }

  Future<void> declineIncomingOrder(String reason) async {
    final order = incomingOrder.value;
    if (order == null) return;

    _countdownTimer?.cancel();
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    final targetId = (order.assignmentId != null && order.assignmentId!.isNotEmpty)
        ? order.assignmentId!
        : order.id;
    await declineOrderUseCase(targetId, reason);
    incomingOrder.value = null;
    if (Get.overlayContext != null) {
      Get.snackbar('Declined', 'Order declined ($reason)', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Advances the status of the active delivery order per Section 5.1
  Future<void> advanceActiveOrderMilestone() async {
    final current = activeOrder.value;
    if (current == null) return;

    if (current.status == OrderStatus.outForDelivery) {
      // Step 5 requires customer OTP handover verification in active order view
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().setActiveOrder(current);
      }
      Get.toNamed(AppRoutes.activeOrder);
      return;
    }

    final useCase = _orderStatusUseCase;
    if (useCase == null) {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().setActiveOrder(current);
      }
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
    final targetId = (current.assignmentId != null && current.assignmentId!.isNotEmpty)
        ? current.assignmentId!
        : current.id;
    final result = await useCase(targetId, nextStatus);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Status Update Error', failure.message,
          snackPosition: SnackPosition.TOP),
      (updated) {
        activeOrder.value = updated;
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().setActiveOrder(updated);
        }
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
      await useCase(current.id, OrderStatus.cancelled, cancellationReason: reason);
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

  /// Handles incoming offer push notification payload (Section 2.1)
  void handleIncomingOfferPush(Map<String, dynamic> data, {String? fallbackTitle, String? fallbackBody}) {
    if (!isOnline.value) return;

    // Guard: skip duplicate offer events for an order already shown or already active
    final incomingOfferId = (data['assignmentId']?.toString().isNotEmpty == true
            ? data['assignmentId']?.toString()
            : null) ??
        data['orderId']?.toString();
    if (incomingOfferId != null && incomingOfferId.isNotEmpty) {
      final currentIncoming = incomingOrder.value;
      if (currentIncoming != null) {
        final currentId = (currentIncoming.assignmentId?.isNotEmpty == true)
            ? currentIncoming.assignmentId
            : currentIncoming.id;
        if (currentId == incomingOfferId) {
          debugPrint('[DashboardController] handleIncomingOfferPush: duplicate offer $incomingOfferId, skipping.');
          return;
        }
      }
      if (_lastAcceptedOrderId == incomingOfferId) {
        debugPrint('[DashboardController] handleIncomingOfferPush: already accepted $incomingOfferId, skipping re-offer.');
        return;
      }
    }

    final orderId = data['orderId']?.toString() ?? 'cuid_order_${DateTime.now().millisecondsSinceEpoch}';
    final orderNumber = data['orderNumber']?.toString() ?? 'meeem00000042';
    final timeout = int.tryParse(data['timeout']?.toString() ?? '60') ?? 60;

    final assignmentId = data['assignmentId']?.toString();
    final cycle = int.tryParse(data['cycle']?.toString() ?? '');
    final riderAttempt = int.tryParse(data['riderAttempt']?.toString() ?? '');

    // Read dynamic earning and customer/store keys directly from message.data
    final earningRaw = (data['deliveryFee'] ?? data['deliveryEarning'] ?? data['earning'] ?? data['amount'] ?? '0.00').toString();
    final earning = double.tryParse(earningRaw) ?? 0.00;
    final shopName = (data['shopName'] ?? data['pickupName'] ?? 'Store').toString();
    final shopAddress = (data['shopAddress'] ?? data['pickupAddress'] ?? '').toString();
    final customerName = (data['customerName'] ?? 'Customer').toString();
    final customerAddress = (data['customerAddress'] ?? data['dropoffAddress'] ?? '').toString();
    final customerPhone = (data['customerPhone'] ?? '').toString();
    final distanceKm = double.tryParse(data['distanceKm']?.toString() ?? '2.1') ?? 2.1;

    final offer = OrderEntity(
      id: orderId,
      assignmentId: assignmentId,
      orderNumber: orderNumber,
      status: OrderStatus.pending,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAvatar: '',
      pickupName: shopName,
      pickupAddress: shopAddress,
      pickupPhone: (data['pickupPhone'] ?? '').toString(),
      dropoffAddress: customerAddress,
      pickupLat: double.tryParse(data['pickupLat']?.toString() ?? '') ?? 8.484,
      pickupLng: double.tryParse(data['pickupLng']?.toString() ?? '') ?? -13.234,
      dropoffLat: double.tryParse(data['dropoffLat']?.toString() ?? '') ?? 8.460,
      dropoffLng: double.tryParse(data['dropoffLng']?.toString() ?? '') ?? -13.250,
      items: const [],
      subtotal: double.tryParse(data['subtotal']?.toString() ?? '') ?? 0.0,
      riderEarnings: earning,
      distanceKm: distanceKm,
      estimatedDurationMin: (distanceKm * 7).ceil().clamp(5, 60),
      createdAt: DateTime.now(),
      cycle: cycle,
      riderAttempt: riderAttempt,
    );

    incomingOrder.value = offer;
    countdownSeconds.value = timeout;
    _notificationService?.playOrderAlertFeedback();
    _startCountdownTimer();
  }

  /// Handles direct manual assignment push notification payload (Section 2.2)
  void handleDirectAssignmentPush(Map<String, dynamic> data) {
    loadDashboardData();
    final orderNumber = data['orderNumber']?.toString() ?? 'meeem00000042';
    final earning = data['deliveryFee'] ?? data['deliveryEarning'] ?? data['earning'] ?? data['amount'];
    final earningText = earning != null ? ' (Earning: NLe $earning)' : '';
    Get.snackbar(
      '🛵 Direct Delivery Assignment',
      'You have been directly assigned delivery for Order #$orderNumber$earningText.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE8F8EE),
      colorText: const Color(0xFF009624),
      duration: const Duration(minutes: 1),
    );
  }

  /// Handles revocation of offer or assignment when reassigned/cancelled (Section 2.3)
  void handleAssignmentRevokedPush(Map<String, dynamic> data) {
    final revokedOrderId = data['orderId']?.toString();
    final revokedOrderNumber = data['orderNumber']?.toString();

    _countdownTimer?.cancel();

    // Immediately dismiss offer popup / card / bottom sheet if open on screen
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }

    if (incomingOrder.value != null) {
      incomingOrder.value = null;
    }

    // If active assigned order was revoked by admin/seller
    if (activeOrder.value != null &&
        (revokedOrderId == null ||
         revokedOrderId.isEmpty ||
         activeOrder.value?.id == revokedOrderId ||
         activeOrder.value?.orderNumber == revokedOrderNumber)) {
      activeOrder.value = null;
      _locationService?.setActiveOrderId(null);
      loadDashboardData();
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().loadOrders();
      }
      if (Get.currentRoute == AppRoutes.activeOrder) {
        Get.until((route) => Get.currentRoute == AppRoutes.dashboard);
      }
    }

    if (Get.overlayContext != null) {
      Get.snackbar(
        'Offer Revoked',
        revokedOrderNumber != null && revokedOrderNumber.isNotEmpty
            ? 'Delivery assignment for Order #$revokedOrderNumber was reassigned or cancelled.'
            : 'The delivery assignment offer was revoked.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFFB91C1C),
        duration: const Duration(seconds: 4),
      );
    }
  }

  void cancelCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
        if (Get.isSnackbarOpen == true) {
          Get.closeCurrentSnackbar();
        }
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        incomingOrder.value = null;
        Get.snackbar('Offer Expired', 'The 60s offer expired and cascaded to the next rider.',
            snackPosition: SnackPosition.TOP);
      }
    });
  }
}
