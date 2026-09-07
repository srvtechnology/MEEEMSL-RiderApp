import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_launcher_util.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../orders/controllers/orders_controller.dart';

class NavigationController extends GetxController {
  final currentStepInstruction = 'Head towards destination'.obs;
  final remainingDistance = 2.4.obs;
  final remainingMinutes = 8.obs;
  final currentSpeedKmh = 30.obs;

  GoogleMapController? mapController;
  final isMapReady = false.obs;
  final isFollowingRider = true.obs;

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

  String get targetTitle =>
      isHeadingToPickup ? (activeOrder?.pickupName ?? 'Vendor Store') : (activeOrder?.customerName ?? 'Customer Dropoff');

  String get targetAddress =>
      isHeadingToPickup ? (activeOrder?.pickupAddress ?? '') : (activeOrder?.dropoffAddress ?? '');

  double get targetLat =>
      isHeadingToPickup ? (activeOrder?.pickupLat ?? 8.484245) : (activeOrder?.dropoffLat ?? 8.480100);

  double get targetLng =>
      isHeadingToPickup ? (activeOrder?.pickupLng ?? -13.234125) : (activeOrder?.dropoffLng ?? -13.228500);

  String get targetPhone =>
      isHeadingToPickup ? (activeOrder?.pickupPhone ?? '') : (activeOrder?.customerPhone ?? '');

  LatLng get destinationLatLng => LatLng(targetLat, targetLng);

  LatLng get riderLatLng {
    final pos = _locationService?.currentPosition.value;
    if (pos != null && pos.latitude != 0.0 && pos.longitude != 0.0) {
      return LatLng(pos.latitude, pos.longitude);
    }
    // Realistic fallback offset around destination if no GPS lock yet
    return LatLng(targetLat - 0.012, targetLng - 0.008);
  }

  CameraPosition get initialCameraPosition => CameraPosition(
        target: riderLatLng,
        zoom: 15.5,
        tilt: 35.0,
      );

  Worker? _locationWorker;

  @override
  void onInit() {
    super.onInit();
    updateMapRoute();

    final locService = _locationService;
    if (locService != null) {
      _locationWorker = ever(locService.currentPosition, (_) {
        updateMapRoute();
        if (isFollowingRider.value && mapController != null) {
          centerOnRider();
        }
      });
    }
  }

  @override
  void onClose() {
    _locationWorker?.dispose();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady.value = true;
    updateMapRoute();
    Future.delayed(const Duration(milliseconds: 350), () {
      fitRouteBounds();
    });
  }

  void onCameraMoveStarted() {
    // User is manually exploring the map
    isFollowingRider.value = false;
  }

  void recenterRider() {
    isFollowingRider.value = true;
    centerOnRider();
  }

  void centerOnRider() {
    if (mapController == null) return;
    final pos = _locationService?.currentPosition.value;
    final heading = pos?.heading ?? 0.0;
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: riderLatLng,
          zoom: 16.5,
          tilt: 40.0,
          bearing: heading,
        ),
      ),
    );
  }

  void fitRouteBounds() {
    if (mapController == null) return;
    final rider = riderLatLng;
    final dest = destinationLatLng;

    final southWest = LatLng(
      math.min(rider.latitude, dest.latitude),
      math.min(rider.longitude, dest.longitude),
    );
    final northEast = LatLng(
      math.max(rider.latitude, dest.latitude),
      math.max(rider.longitude, dest.longitude),
    );

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
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

    // Step instruction
    if (distKm < 0.05) {
      currentStepInstruction.value = 'Arrived at $targetTitle';
    } else if (distKm < 0.25) {
      currentStepInstruction.value = 'In ${(distMeters).round()}m, destination is on your right';
    } else if (distKm < 0.8) {
      currentStepInstruction.value = 'Continue straight toward $targetTitle';
    } else {
      currentStepInstruction.value = 'In 250m, continue on main route to $targetTitle';
    }

    // Build markers
    final newMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('rider_live_marker'),
        position: rider,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location (Live)'),
      ),
      Marker(
        markerId: const MarkerId('destination_marker'),
        position: dest,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isHeadingToPickup ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: targetTitle,
          snippet: targetAddress,
        ),
      ),
    };

    // Build polyline route
    final newPolylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('delivery_navigation_route'),
        points: [rider, dest],
        color: AppColors.primary,
        width: 5,
        geodesic: true,
      ),
    };

    markers.assignAll(newMarkers);
    polylines.assignAll(newPolylines);
  }

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
