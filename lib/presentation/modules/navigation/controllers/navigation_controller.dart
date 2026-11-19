import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../orders/controllers/orders_controller.dart';

class NavigationController extends GetxController {
  final currentStepInstruction = 'Head towards destination'.obs;
  final currentManeuverTitle = 'In 250m'.obs;
  final currentManeuverIcon = Rx<IconData>(Icons.navigation_rounded);
  final remainingDistance = 2.4.obs;
  final remainingMinutes = 8.obs;
  final currentSpeedKmh = 30.obs;

  GoogleMapController? mapController;
  final isMapReady = false.obs;
  final isFollowingRider = true.obs;
  final is3dNavigationMode = true.obs;
  final isTrafficEnabled = true.obs;
  final isMuted = false.obs;

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  OrdersController? get _ordersController =>
      Get.isRegistered<OrdersController>() ? Get.find<OrdersController>() : null;
  DashboardController? get _dashboardController =>
      Get.isRegistered<DashboardController>() ? Get.find<DashboardController>() : null;
  LocationService? get _locationService =>
      Get.isRegistered<LocationService>() ? Get.find<LocationService>() : null;

  OrderEntity? get activeOrder =>
      _ordersController?.selectedOrder.value ?? _dashboardController?.activeOrder.value;

  bool get isHeadingToPickup =>
      activeOrder?.status == OrderStatus.accepted || activeOrder?.status == OrderStatus.atPickup;

  // Cooch Behar (COB) coordinates
  static const double cobCenterLat = 26.3239;
  static const double cobCenterLng = 89.4510;
  static const double khagrabariLat = 26.3442;
  static const double khagrabariLng = 89.4529;

  String get targetTitle =>
      isHeadingToPickup ? (activeOrder?.pickupName ?? 'Vendor Store') : (activeOrder?.customerName ?? 'Customer Dropoff');

  String get targetAddress =>
      isHeadingToPickup ? (activeOrder?.pickupAddress ?? '') : (activeOrder?.dropoffAddress ?? '');

  double get targetLat {
    final raw = isHeadingToPickup ? activeOrder?.pickupLat : activeOrder?.dropoffLat;
    return _resolveTargetCoordinate(raw, isLat: true);
  }

  double get targetLng {
    final raw = isHeadingToPickup ? activeOrder?.pickupLng : activeOrder?.dropoffLng;
    return _resolveTargetCoordinate(raw, isLat: false);
  }

  double _resolveTargetCoordinate(double? raw, {required bool isLat}) {
    // 1. If a valid non-default coordinate was provided (not 0, and not the Sierra Leone fallback ~8.4x / -13.2x)
    if (raw != null && raw != 0.0) {
      final isSierraLeone = isLat
          ? (raw >= 8.40 && raw <= 8.55)
          : (raw <= -13.15 && raw >= -13.35);
      if (!isSierraLeone) {
        return raw;
      }
    }

    // 2. Match known landmarks/areas in Cooch Behar (COB) & North Bengal
    final addr = targetAddress.toLowerCase();
    if (addr.contains('khagrabari') || addr.contains('khagra bari')) {
      return isLat ? khagrabariLat : khagrabariLng;
    }
    if (addr.contains('cooch') || addr.contains('cob') || addr.contains('koch bihar')) {
      return isLat ? cobCenterLat : cobCenterLng;
    }
    if (addr.contains('alipurduar')) {
      return isLat ? 26.4919 : 89.5271;
    }
    if (addr.contains('tufanganj')) {
      return isLat ? 26.3167 : 89.6667;
    }
    if (addr.contains('dinhata')) {
      return isLat ? 26.1333 : 89.4667;
    }
    if (addr.contains('mathabhanga')) {
      return isLat ? 26.3333 : 89.2167;
    }
    if (addr.contains('mekhliganj')) {
      return isLat ? 26.3456 : 88.9167;
    }
    if (addr.contains('haldibari')) {
      return isLat ? 26.3333 : 88.7667;
    }

    // 3. Default to Cooch Behar (COB)
    return isLat
        ? (isHeadingToPickup ? cobCenterLat : khagrabariLat)
        : (isHeadingToPickup ? cobCenterLng : khagrabariLng);
  }

  String get targetPhone =>
      isHeadingToPickup ? (activeOrder?.pickupPhone ?? '') : (activeOrder?.customerPhone ?? '');

  LatLng get destinationLatLng => LatLng(targetLat, targetLng);

  LatLng get riderLatLng {
    final pos = _locationService?.currentPosition.value;
    if (pos != null && pos.latitude != 0.0 && pos.longitude != 0.0) {
      final isSierraLeone = (pos.latitude >= 8.40 && pos.latitude <= 8.55) &&
          (pos.longitude <= -13.15 && pos.longitude >= -13.35);
      if (!isSierraLeone) {
        return LatLng(pos.latitude, pos.longitude);
      }
    }
    // Realistic fallback offset around destination in Cooch Behar (COB) if no GPS lock yet
    return LatLng(targetLat - 0.008, targetLng - 0.006);
  }

  CameraPosition get initialCameraPosition => CameraPosition(
        target: riderLatLng,
        zoom: 17.5,
        tilt: 50.0,
      );

  bool _isDisposed = false;
  Worker? _locationWorker;
  Worker? _orderWorker;

  @override
  void onInit() {
    super.onInit();
    updateMapRoute();

    final locService = _locationService;
    if (locService != null) {
      _locationWorker = ever(locService.currentPosition, (_) {
        if (_isDisposed) return;
        updateMapRoute();
        if (isFollowingRider.value && mapController != null) {
          centerOnRider();
        }
      });
    }

    // Reactively update route if active order milestone changes
    final ordersCtrl = _ordersController;
    if (ordersCtrl != null) {
      _orderWorker = ever(ordersCtrl.selectedOrder, (_) {
        if (_isDisposed) return;
        updateMapRoute();
        if (isFollowingRider.value && mapController != null) {
          centerOnRider();
        }
      });
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _locationWorker?.dispose();
    _orderWorker?.dispose();
    mapController?.dispose();
    mapController = null;
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    if (_isDisposed) return;
    mapController = controller;
    isMapReady.value = true;
    updateMapRoute();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_isDisposed || mapController == null) return;
      if (is3dNavigationMode.value) {
        centerOnRider();
      } else {
        fitRouteBounds();
      }
    });
  }

  void onCameraMoveStarted() {
    // User is manually exploring the map
    isFollowingRider.value = false;
  }

  void recenterRider() {
    isFollowingRider.value = true;
    is3dNavigationMode.value = true;
    centerOnRider();
  }

  void toggleCameraMode() {
    is3dNavigationMode.toggle();
    if (is3dNavigationMode.value) {
      isFollowingRider.value = true;
      centerOnRider();
    } else {
      isFollowingRider.value = false;
      fitRouteBounds();
    }
  }

  void toggleTraffic() {
    isTrafficEnabled.toggle();
  }

  void toggleMute() {
    isMuted.toggle();
  }

  void centerOnRider() {
    if (_isDisposed || mapController == null) return;
    final pos = _locationService?.currentPosition.value;
    final heading = pos?.heading ?? 0.0;
    try {
      if (is3dNavigationMode.value) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: riderLatLng,
              zoom: 17.5,
              tilt: 50.0,
              bearing: heading,
            ),
          ),
        );
      } else {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: riderLatLng,
              zoom: 16.0,
              tilt: 0.0,
              bearing: 0.0,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  void fitRouteBounds() {
    if (_isDisposed || mapController == null) return;
    isFollowingRider.value = false;
    final rider = riderLatLng;
    final dest = destinationLatLng;

    double minLat = math.min(rider.latitude, dest.latitude);
    double maxLat = math.max(rider.latitude, dest.latitude);
    double minLng = math.min(rider.longitude, dest.longitude);
    double maxLng = math.max(rider.longitude, dest.longitude);

    // Guard against zero-area LatLngBounds crash in Google Maps SDK
    if ((maxLat - minLat).abs() < 0.001) {
      minLat -= 0.002;
      maxLat += 0.002;
    }
    if ((maxLng - minLng).abs() < 0.001) {
      minLng -= 0.002;
      maxLng += 0.002;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    } catch (_) {}
  }

  void updateMapRoute() {
    final rider = riderLatLng;
    final dest = destinationLatLng;

    // Calculate real distance
    final distMeters = Geolocator.distanceBetween(
      rider.latitude,
      rider.longitude,
      dest.latitude,
      dest.longitude,
    );
    final distKm = distMeters / 1000.0;
    remainingDistance.value = distKm;

    // Speed and ETA calculation
    final currentSpeed = (_locationService?.currentPosition.value?.speed ?? 0.0) * 3.6;
    final effectiveSpeed = currentSpeed > 5.0 ? currentSpeed : 28.0;
    currentSpeedKmh.value = currentSpeed.round();
    final mins = ((distKm / effectiveSpeed) * 60).round().clamp(1, 180);
    remainingMinutes.value = mins;

    // Dynamic Turn-by-Turn Maneuver Instructions
    if (distKm < 0.035) {
      currentManeuverTitle.value = 'Arrived';
      currentStepInstruction.value = 'You have arrived at $targetTitle';
      currentManeuverIcon.value = Icons.check_circle_rounded;
    } else if (distKm < 0.15) {
      currentManeuverTitle.value = 'In ${(distMeters).round()}m';
      currentStepInstruction.value = 'Destination is on your right';
      currentManeuverIcon.value = Icons.near_me_rounded;
    } else if (distKm < 0.5) {
      currentManeuverTitle.value = 'In ${(distMeters).round()}m';
      currentStepInstruction.value = 'Turn slight right onto delivery street';
      currentManeuverIcon.value = Icons.turn_slight_right_rounded;
    } else if (distKm < 1.0) {
      currentManeuverTitle.value = 'In ${(distMeters * 0.4).round()}m';
      currentStepInstruction.value = 'Turn right towards $targetTitle';
      currentManeuverIcon.value = Icons.turn_right_rounded;
    } else {
      currentManeuverTitle.value = 'In 250m';
      currentStepInstruction.value = 'Continue straight on main road toward $targetTitle';
      currentManeuverIcon.value = Icons.navigation_rounded;
    }

    // Build Rider & Destination Markers
    final riderHeading = _locationService?.currentPosition.value?.heading ?? 0.0;
    final newMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('rider_live_marker'),
        position: rider,
        rotation: riderHeading,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Delivery Partner (Live)'),
      ),
      Marker(
        markerId: const MarkerId('destination_marker'),
        position: dest,
        anchor: const Offset(0.5, 1.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isHeadingToPickup ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: targetTitle,
          snippet: targetAddress,
        ),
      ),
    };

    // Realistic multi-point road trajectory
    final routePoints = _generateRoadPath(rider, dest);

    final newPolylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('delivery_navigation_route'),
        points: routePoints,
        color: AppColors.primary,
        width: 6,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };

    markers.assignAll(newMarkers);
    polylines.assignAll(newPolylines);
  }

  List<LatLng> _generateRoadPath(LatLng start, LatLng end) {
    final dLat = end.latitude - start.latitude;
    final dLng = end.longitude - start.longitude;

    if (dLat.abs() < 0.0005 && dLng.abs() < 0.0005) {
      return [start, end];
    }

    return [
      start,
      LatLng(start.latitude + dLat * 0.22, start.longitude + dLng * 0.05),
      LatLng(start.latitude + dLat * 0.45, start.longitude + dLng * 0.18),
      LatLng(start.latitude + dLat * 0.60, start.longitude + dLng * 0.52),
      LatLng(start.latitude + dLat * 0.82, start.longitude + dLng * 0.88),
      LatLng(start.latitude + dLat * 0.94, end.longitude),
      end,
    ];
  }

  String get milestoneActionLabel {
    final status = activeOrder?.status;
    switch (status) {
      case OrderStatus.accepted:
        return 'I Have Arrived at Store';
      case OrderStatus.atPickup:
        return 'Confirm Package Pickup';
      case OrderStatus.pickedUp:
        return 'Start Heading to Drop-off';
      case OrderStatus.outForDelivery:
        return 'I Have Arrived at Drop-off';
      case OrderStatus.delivered:
        return 'Delivery Completed';
      default:
        return isHeadingToPickup ? 'I Have Arrived at Store' : 'I Have Arrived at Drop-off';
    }
  }

  IconData get milestoneActionIcon {
    final status = activeOrder?.status;
    switch (status) {
      case OrderStatus.accepted:
        return Icons.storefront_rounded;
      case OrderStatus.atPickup:
        return Icons.camera_alt_rounded;
      case OrderStatus.pickedUp:
        return Icons.directions_bike_rounded;
      case OrderStatus.outForDelivery:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.delivered:
        return Icons.verified_rounded;
      default:
        return isHeadingToPickup ? Icons.storefront_rounded : Icons.check_circle_outline_rounded;
    }
  }

  void advanceMilestone() {
    final order = activeOrder;
    if (order == null) return;
    final ordersCtrl = _ordersController;
    if (ordersCtrl != null) {
      if (ordersCtrl.selectedOrder.value == null) {
        ordersCtrl.setActiveOrder(order);
      }
      ordersCtrl.advanceActiveOrderStatus();
    } else {
      Get.back();
    }
  }

  void callTarget() {
    if (targetPhone.isNotEmpty) {
      if (_ordersController != null) {
        _ordersController!.callContact(targetPhone);
      } else {
        launchUrl(Uri.parse('tel:$targetPhone'));
      }
    }
  }

  void messageTarget() {
    if (targetPhone.isNotEmpty) {
      if (_ordersController != null) {
        _ordersController!.messageContact(targetPhone);
      } else {
        launchUrl(Uri.parse('sms:$targetPhone'));
      }
    }
  }
}
