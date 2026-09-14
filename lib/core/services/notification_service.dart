import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/auth/register_device_token_usecase.dart';
import '../../domain/usecases/auth/unregister_device_token_usecase.dart';
import '../../presentation/modules/dashboard/controllers/dashboard_controller.dart';
import '../../presentation/modules/orders/controllers/orders_controller.dart';
import 'device_info_service.dart';
import 'location_service.dart';

/// NotificationService handles FCM Push Notifications, Multi-device Token Registration,
/// Dispatch Assignment Sound Alerts, and In-app Notification Heads-up Popups.
class NotificationService extends GetxService {
  final isSoundEnabled = true.obs;
  final isVibrationEnabled = true.obs;
  final currentFcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initFirebaseMessaging();
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      // Request Push Permissions
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        currentFcmToken.value = token;
        final storage = GetStorage();
        await storage.write(AppConstants.devicePushTokenKey, token);
        registerCurrentDeviceToken();
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        currentFcmToken.value = newToken;
        final storage = GetStorage();
        storage.write(AppConstants.devicePushTokenKey, newToken);
        registerCurrentDeviceToken();
      });

      // Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        handleFcmPayload(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      // Notification Opened App Handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleFcmPayload(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });

      // Terminated state initial notification check
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          handleFcmPayload(
            message.data,
            title: message.notification?.title,
            body: message.notification?.body,
          );
        }
      });
    } catch (_) {
      // Fallback if running on simulator or without Google Play Services
      const fallbackToken = 'fcm_mock_device_token_2026';
      currentFcmToken.value = fallbackToken;
      final storage = GetStorage();
      storage.write(AppConstants.devicePushTokenKey, fallbackToken);
    }
  }

  /// Callbacks for active dashboard handling
  static void Function(Map<String, dynamic> data, {String? title, String? body})? onNewOffer;
  static void Function(Map<String, dynamic> data)? onDirectAssignment;
  static void Function(Map<String, dynamic> data)? onAssignmentRevoked;

  /// Returns true if the rider currently has an active in-flight delivery
  /// (status is accepted, atPickup, pickedUp, outForDelivery).
  static bool hasActiveDelivery() {
    // 1. Check DashboardController
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      final active = dash.activeOrder.value;
      if (active != null &&
          active.status != OrderStatus.delivered &&
          active.status != OrderStatus.cancelled) {
        return true;
      }
    }

    // 2. Check OrdersController
    if (Get.isRegistered<OrdersController>()) {
      final orders = Get.find<OrdersController>();
      if (orders.activeOrders.any((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)) {
        return true;
      }
      final selected = orders.selectedOrder.value;
      if (selected != null &&
          selected.status != OrderStatus.delivered &&
          selected.status != OrderStatus.cancelled) {
        return true;
      }
    }

    // 3. Check LocationService active order id
    if (Get.isRegistered<LocationService>()) {
      final loc = Get.find<LocationService>();
      if (loc.activeOrderId.value != null && loc.activeOrderId.value!.isNotEmpty) {
        return true;
      }
    }

    // 4. Check cached active order in GetStorage
    if (Get.isRegistered<GetStorage>()) {
      try {
        final storage = Get.find<GetStorage>();
        final raw = storage.read(AppConstants.activeOrderKey);
        if (raw != null) {
          if (raw is Map) {
            final statusStr = raw['status']?.toString().toUpperCase();
            if (statusStr != 'DELIVERED' && statusStr != 'CANCELLED') {
              return true;
            }
          } else {
            return true;
          }
        }
      } catch (_) {}
    }

    return false;
  }

  /// Checks whether an offer payload refers to an order that is already active or accepted.
  static bool isOrderAlreadyAcceptedOrActive(Map<String, dynamic> data) {
    final orderId = data['orderId']?.toString();
    final assignmentId = data['assignmentId']?.toString();
    final orderNumber = data['orderNumber']?.toString();

    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      if (dash.isOrderAcceptedOrActive(orderId) ||
          dash.isOrderAcceptedOrActive(assignmentId) ||
          dash.isOrderAcceptedOrActive(orderNumber)) {
        return true;
      }
    }
    return false;
  }

  /// Handles FCM data payload conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md Section 2:
  /// - 2.1: type == "NEW_OFFER" (Automated Waterfall Offer with 60s countdown)
  /// - 2.2: type == "MANUAL_ASSIGN" (Direct Admin/Seller Assignment)
  /// - 2.3: type == "ASSIGNMENT_REVOKED" (Offer/Assignment Cancelled or Reassigned)
  void handleFcmPayload(Map<String, dynamic> data, {String? title, String? body}) {
    final type = data['type']?.toString().toUpperCase();

    // Checklist Point 5: Single Active Driving Device FCM Push
    if (type == 'DEVICE_SWITCHED') {
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
          activeDeviceId == localDeviceId) {
        return;
      }

      final alertMessage = body ??
          (data['body']?.toString() ??
              (data['message']?.toString() ??
                  'You have switched to another device. Tracking stopped on this device.'));

      if (Get.isRegistered<LocationService>()) {
        Get.find<LocationService>().handleDeviceSwitched(alertMessage);
      } else {
        if (Get.isRegistered<GetStorage>()) {
          try {
            final storage = Get.find<GetStorage>();
            storage.write(AppConstants.isOnlineKey, false);
            storage.remove('online_since_timestamp');
          } catch (_) {}
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().isOnline.value = false;
        }
        LocationService.showDeviceSwitchedDialog(alertMessage);
      }
      return;
    }

    final earning = (data['deliveryFee'] ?? data['deliveryEarning'] ?? data['earning'] ?? data['amount'] ?? '').toString();
    final shopName = (data['shopName'] ?? data['pickupName'] ?? '').toString();
    final customerName = (data['customerName'] ?? '').toString();

    if (type == 'NEW_OFFER') {
      // Guard: Do not show or handle offer if rider is already busy delivering an active order
      // or if this offer corresponds to an order already accepted/active.
      if (hasActiveDelivery() || isOrderAlreadyAcceptedOrActive(data)) {
        debugPrint('[NotificationService] Rider currently has an active delivery or order is already active. Suppressing NEW_OFFER banner.');
        return;
      }

      if (Get.currentRoute == '/active-order') {
        debugPrint('[NotificationService] Rider is on ActiveOrderView. Suppressing NEW_OFFER banner.');
        return;
      }

      onNewOffer?.call(data, title: title, body: body);
      final earningStr = earning.isNotEmpty ? earning : '0.00';
      final earningBadgeText = 'Delivery Earning: NLe $earningStr';
      final defaultTitle = '📦 New Delivery Offer ($earningBadgeText)';
      final defaultMsg = shopName.isNotEmpty
          ? '$earningBadgeText\nPickup from $shopName${customerName.isNotEmpty ? ' for $customerName' : ''}. Tap to accept within 60s!'
          : '$earningBadgeText. Tap to accept within 60s!';

      showOrderDispatchAlert(
        title: title ?? defaultTitle,
        message: body ?? defaultMsg,
        duration: const Duration(minutes: 1),
        onTap: () {
          if (Get.currentRoute != '/dashboard') {
            Get.toNamed('/dashboard');
          }
        },
      );
      return;
    }

    if (type == 'MANUAL_ASSIGN') {
      if (onDirectAssignment != null) {
        onDirectAssignment!(data);
      } else {
        final displayEarning = earning.isNotEmpty ? ' (Earning: NLe $earning)' : '';
        showOrderDispatchAlert(
          title: title ?? '🛵 Direct Delivery Assignment$displayEarning',
          message: body ?? (shopName.isNotEmpty
              ? 'You have been assigned order from $shopName${customerName.isNotEmpty ? ' for $customerName' : ''}.'
              : 'You have been directly assigned a new delivery order.'),
          duration: const Duration(minutes: 1),
          onTap: () {
            final orderId = data['orderId']?.toString();
            if (orderId != null && orderId.isNotEmpty) {
              Get.toNamed('/orders/$orderId', arguments: {'orderId': orderId});
            } else if (Get.currentRoute != '/dashboard') {
              Get.toNamed('/dashboard');
            }
          },
        );
      }
      return;
    }

    if (type == 'ASSIGNMENT_REVOKED') {
      onAssignmentRevoked?.call(data);
      final orderNumber = data['orderNumber']?.toString() ?? '';
      showInfoNotification(
        title: title ?? 'Offer Revoked',
        message: body ?? (orderNumber.isNotEmpty
            ? 'Delivery assignment for Order #$orderNumber was reassigned or cancelled.'
            : 'Delivery assignment was reassigned or cancelled.'),
      );
      return;
    }

    // Default notifications
    showInfoNotification(
      title: title ?? 'New Dispatch Alert',
      message: body ?? 'You have a new delivery order update!',
    );
  }

  /// 9.1 Register or Update Device Token with Backend
  Future<bool> registerCurrentDeviceToken() async {
    try {
      if (!Get.isRegistered<RegisterDeviceTokenUseCase>() || !Get.isRegistered<DeviceInfoService>()) {
        return false;
      }
      final registerTokenUseCase = Get.find<RegisterDeviceTokenUseCase>();
      final deviceInfoService = Get.find<DeviceInfoService>();

      final deviceId = await deviceInfoService.getDeviceId();
      final platform = deviceInfoService.getPlatform();
      final deviceModel = await deviceInfoService.getDeviceModel();
      final appVersion = await deviceInfoService.getAppVersion();
      final token = currentFcmToken.value.isNotEmpty
          ? currentFcmToken.value
          : (GetStorage().read<String>(AppConstants.devicePushTokenKey) ?? 'fcm_mock_device_token_2026');

      final result = await registerTokenUseCase(
        token: token,
        deviceId: deviceId,
        platform: platform,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );
      return result.isRight();
    } catch (_) {
      return false;
    }
  }

  /// 9.2 Unregister Device Token on Logout
  Future<bool> unregisterCurrentDeviceToken() async {
    try {
      if (!Get.isRegistered<UnregisterDeviceTokenUseCase>() || !Get.isRegistered<DeviceInfoService>()) {
        return false;
      }
      final unregisterTokenUseCase = Get.find<UnregisterDeviceTokenUseCase>();
      final deviceInfoService = Get.find<DeviceInfoService>();

      final deviceId = await deviceInfoService.getDeviceId();
      final result = await unregisterTokenUseCase(deviceId: deviceId);
      return result.isRight();
    } catch (_) {
      return false;
    }
  }

  /// Plays dispatch assignment alert audio/vibration cue.
  void playOrderAlertFeedback() {
    if (isVibrationEnabled.value) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Displays an in-app heads-up pop-up alert for urgent delivery dispatch assignments.
  /// Defaults to staying on screen for 1 minute (60 seconds).
  void showOrderDispatchAlert({
    required String title,
    required String message,
    required VoidCallback onTap,
    Duration duration = const Duration(minutes: 1),
  }) {
    playOrderAlertFeedback();

    if (Get.overlayContext == null) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      icon: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 28),
      duration: duration,
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onTap();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('View Order', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  /// Displays general notification snackbar.
  void showInfoNotification({required String title, required String message}) {
    if (Get.overlayContext == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }
}
