import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/map_launcher_util.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../orders/controllers/orders_controller.dart';

class NavigationController extends GetxController {
  final currentStepInstruction = 'In 250m, Turn Right onto Broadway St'.obs;
  final remainingDistance = 2.4.obs;
  final remainingMinutes = 8.obs;
  final currentSpeedKmh = 34.obs;

  OrdersController get _ordersController => Get.find<OrdersController>();
  OrderEntity? get activeOrder => _ordersController.selectedOrder.value;

  bool get isHeadingToPickup =>
      activeOrder?.status == OrderStatus.accepted || activeOrder?.status == OrderStatus.atPickup;

  String get targetTitle =>
      isHeadingToPickup ? (activeOrder?.pickupName ?? 'Vendor Store') : (activeOrder?.customerName ?? 'Customer Dropoff');

  String get targetAddress =>
      isHeadingToPickup ? (activeOrder?.pickupAddress ?? '') : (activeOrder?.dropoffAddress ?? '');

  double get targetLat =>
      isHeadingToPickup ? (activeOrder?.pickupLat ?? 40.7589) : (activeOrder?.dropoffLat ?? 40.7527);

  double get targetLng =>
      isHeadingToPickup ? (activeOrder?.pickupLng ?? -73.9851) : (activeOrder?.dropoffLng ?? -73.9772);

  String get targetPhone =>
      isHeadingToPickup ? (activeOrder?.pickupPhone ?? '') : (activeOrder?.customerPhone ?? '');

  void openNavigationChooser(BuildContext context) {
    MapLauncherUtil.showMapOptionsModal(
      context: context,
      latitude: targetLat,
      longitude: targetLng,
      title: targetTitle,
      address: targetAddress,
    );
  }

  Future<void> openGoogleMaps() async {
    await MapLauncherUtil.openGoogleMaps(
      latitude: targetLat,
      longitude: targetLng,
      label: targetTitle,
    );
  }

  Future<void> openAppleMaps() async {
    await MapLauncherUtil.openAppleMaps(
      latitude: targetLat,
      longitude: targetLng,
      label: targetTitle,
    );
  }

  void callTarget() {
    if (targetPhone.isNotEmpty) {
      _ordersController.callContact(targetPhone);
    }
  }

  void messageTarget() {
    if (targetPhone.isNotEmpty) {
      _ordersController.messageContact(targetPhone);
    }
  }
}
