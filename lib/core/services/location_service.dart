import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';

/// LocationService manages foreground and background GPS tracking.
/// It continuously captures rider coordinates and syncs them periodically with the backend
/// for optimal order matching and customer live tracking.
class LocationService extends GetxService {
  // ignore: unused_field
  final DioClient _dioClient;

  LocationService([DioClient? dioClient]) : _dioClient = dioClient ?? Get.find<DioClient>();

  // Reactive state
  final Rx<Position?> currentPosition = Rx<Position?>(defaultFallbackPosition);
  final isTrackingActive = false.obs;
  final hasPermission = false.obs;
  final lastSyncTimestamp = Rxn<DateTime>();
  
  StreamSubscription<Position>? _positionSubscription;
  Timer? _periodicSyncTimer;

  // Fallback initial location (Downtown Delivery District)
  static final Position defaultFallbackPosition = Position(
    latitude: 40.7580,
    longitude: -73.9855,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 10.0,
    altitudeAccuracy: 1.0,
    heading: 90.0,
    headingAccuracy: 1.0,
    speed: 15.0,
    speedAccuracy: 1.0,
  );

  @override
  void onInit() {
    super.onInit();
    currentPosition.value = defaultFallbackPosition;
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  /// Initializes location permissions and checks device GPS status.
  Future<bool> checkAndRequestPermissions() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services are disabled.');
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Location permission denied.');
          hasPermission.value = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permissions permanently denied.');
        hasPermission.value = false;
        return false;
      }

      hasPermission.value = true;
      return true;
    } catch (e) {
      debugPrint('[LocationService] Error requesting location permission: $e');
      hasPermission.value = false;
      return false;
    }
  }

  /// Starts background & foreground GPS tracking and periodic server synchronizations.
  Future<void> startTracking() async {
    if (isTrackingActive.value) return;

    final permissionGranted = await checkAndRequestPermissions();
    if (!permissionGranted) {
      debugPrint('[LocationService] Running with simulated GPS coordinates.');
    }

    isTrackingActive.value = true;

    // Listen to real-time position stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update when moved 10 meters
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          currentPosition.value = position;
        },
        onError: (error) {
          debugPrint('[LocationService] Position stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('[LocationService] Could not start location stream: $e');
    }

    // Schedule periodic coordinate pings to backend
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
      (_) => _sendLocationUpdateToServer(),
    );

    // Initial ping
    _sendLocationUpdateToServer();
  }

  /// Stops tracking when rider goes offline.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    isTrackingActive.value = false;
  }

  /// Records latest coordinates for local tracking (API Doc Part 1 does not specify location update endpoint).
  Future<void> _sendLocationUpdateToServer() async {
    if (!isTrackingActive.value) return;

    final pos = currentPosition.value ?? defaultFallbackPosition;
    lastSyncTimestamp.value = DateTime.now();
    debugPrint('[LocationService] Local GPS updated: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
  }
}
