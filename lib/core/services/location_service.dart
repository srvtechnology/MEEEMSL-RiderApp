import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'device_info_service.dart';
import 'socket_service.dart';

/// Active telemetry streaming method
enum TelemetryMode {
  idle,
  socketStreaming,
  restFallback,
  error,
}

/// LocationService manages foreground and background GPS telemetry.
/// It continuously captures rider coordinates and streams them in real-time
/// conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md:
///
/// 1.1 Primary: Socket.IO streaming every 3 to 5 seconds with event "rider:location_update".
/// 1.2 Fallback: REST API POST /mobileapi/rider/location when WebSocket drops.
class LocationService extends GetxService {
  final DioClient _dioClient;
  final SocketService _socketService;
  final AuthLocalDataSource? _authLocalDataSource;

  LocationService([
    DioClient? dioClient,
    SocketService? socketService,
    AuthLocalDataSource? authLocalDataSource,
  ])  : _dioClient = dioClient ??
            (Get.isRegistered<DioClient>()
                ? Get.find<DioClient>()
                : DioClient()),
        _socketService = socketService ??
            (Get.isRegistered<SocketService>()
                ? Get.find<SocketService>()
                : SocketService()),
        _authLocalDataSource = authLocalDataSource ??
            (Get.isRegistered<AuthLocalDataSource>()
                ? Get.find<AuthLocalDataSource>()
                : (Get.isRegistered<GetStorage>()
                    ? AuthLocalDataSourceImpl(Get.find<GetStorage>())
                    : null));

  // Telemetry intervals
  static const int telemetryIntervalSeconds = 4; // 3-5 seconds per Section 1.1
  static const int restFallbackHeartbeatSeconds = 20; // 15-30s heartbeat window per Checklist Point 2

  // Reactive state
  final Rx<Position?> currentPosition = Rx<Position?>(defaultFallbackPosition);
  final RxBool isTrackingActive = false.obs;
  final RxBool hasPermission = false.obs;
  final Rxn<DateTime> lastSyncTimestamp = Rxn<DateTime>();
  final RxnString activeOrderId = RxnString();
  final Rx<TelemetryMode> telemetryMode = TelemetryMode.idle.obs;
  final RxnString lastSyncError = RxnString();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _periodicSyncTimer;
  DateTime? _lastRestFallbackTimestamp;
  bool _wasSocketConnected = false;

  // Fallback initial location (Downtown Delivery District)
  static final Position defaultFallbackPosition = Position(
    latitude: 8.484245,
    longitude: -13.234125,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 10.0,
    altitudeAccuracy: 1.0,
    heading: 90.0,
    headingAccuracy: 1.0,
    speed: 0.0,
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

  /// Sets or clears the active delivery order ID for real-time telemetry streaming.
  /// Joins/leaves the Socket.IO order room per MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8 Section 5.
  /// Pass null if the rider is roaming/idle.
  void setActiveOrderId(String? orderId) {
    final oldOrderId = activeOrderId.value;
    if (oldOrderId != null && oldOrderId != orderId) {
      _socketService.leaveOrder(oldOrderId);
    }
    activeOrderId.value = orderId;
    if (orderId != null) {
      _socketService.joinOrder(orderId);
    }
    debugPrint(
        '[LocationService] Active order ID updated for telemetry: $orderId');
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

  /// Connects to Socket.IO using stored rider credentials if not already connected.
  void _connectSocketIfPossible() {
    final token = _authLocalDataSource?.getToken();
    final rider = _authLocalDataSource?.getSavedRider();
    final riderId = rider?.id ??
        _authLocalDataSource?.getSavedUser()?.id ??
        'cuid_rider_id';

    if (token != null && token.isNotEmpty) {
      if (!_socketService.isConnected.value &&
          _socketService.connectionState.value !=
              SocketConnectionState.connecting) {
        _socketService.connect(riderId: riderId, token: token);
      }
    }
  }

  /// Starts high-frequency GPS tracking and initiates telemetry streaming.
  Future<void> startTracking() async {
    if (isTrackingActive.value) return;

    final permissionGranted = await checkAndRequestPermissions();
    if (!permissionGranted) {
      debugPrint('[LocationService] Running with fallback GPS coordinates.');
    }

    isTrackingActive.value = true;

    // Connect to Socket.IO
    _connectSocketIfPossible();

    // Listen to real-time device GPS position stream with foreground notification on Android (Point 3)
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update when moved 5 meters
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: telemetryIntervalSeconds),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Meeem Delivery Rider Active',
          notificationText: 'Online & streaming GPS • Ready for delivery assignments',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    try {
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
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

    // Schedule 3-5s periodic coordinate streaming to backend
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(seconds: telemetryIntervalSeconds),
      (_) => sendLocationUpdate(),
    );

    // Initial immediate ping
    sendLocationUpdate();
  }

  /// Stops tracking, closes telemetry streaming, and disconnects socket.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;

    final rider = _authLocalDataSource?.getSavedRider();
    final riderId = rider?.id ??
        _authLocalDataSource?.getSavedUser()?.id ??
        'cuid_rider_id';

    if (_socketService.isConnected.value) {
      _socketService.emitStatusUpdate(riderId: riderId, isOnline: false);
    }

    _socketService.disconnect();
    isTrackingActive.value = false;
    telemetryMode.value = TelemetryMode.idle;
    _lastRestFallbackTimestamp = null;
    _wasSocketConnected = false;
    debugPrint('[LocationService] GPS tracking & telemetry stopped.');
  }

  /// Cross-device switch alert callback
  static void Function(String message)? onDeviceSwitchedAlert;

  /// Handles Single Active Driving Device conflict (Checklist Point 3).
  void handleDeviceSwitched([String? message]) {
    final alertMsg = message ??
        'You have switched to another device. Tracking stopped on this device.';
    stopTracking();
    _authLocalDataSource?.setIsOnline(false);
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
    onDeviceSwitchedAlert?.call(alertMsg);
    showDeviceSwitchedDialog(alertMsg);
  }

  /// Displays alert dialog notifying rider that another device became active.
  static void showDeviceSwitchedDialog([String? customMessage]) {
    final msg = customMessage ??
        'You have switched to another device. Tracking stopped on this device.';
    if (Get.overlayContext == null) return;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    Get.defaultDialog(
      title: 'Device Switched',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53E3E)),
      middleText: msg,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE53E3E),
      onConfirm: () => Get.back(),
    );
  }

  /// Transmits current GPS telemetry via Primary Socket.IO or Fallback REST API.
  Future<void> sendLocationUpdate({bool forceRest = false}) async {
    if (!isTrackingActive.value) return;

    final pos = currentPosition.value ?? defaultFallbackPosition;
    final token = _authLocalDataSource?.getToken();
    final rider = _authLocalDataSource?.getSavedRider();
    final riderId = rider?.id ??
        _authLocalDataSource?.getSavedUser()?.id ??
        'cuid_rider_id';
    final isOnline = _authLocalDataSource?.getIsOnline() ?? true;

    // Resolve hardware deviceId for Single Active Driving Device tracking
    String? deviceId = Get.isRegistered<DeviceInfoService>()
        ? Get.find<DeviceInfoService>().cachedDeviceId
        : null;
    if (deviceId == null || deviceId.isEmpty) {
      if (Get.isRegistered<GetStorage>()) {
        try {
          deviceId = Get.find<GetStorage>().read<String>(AppConstants.registeredDeviceIdKey);
        } catch (_) {}
      }
    }

    // Convert speed: Geolocator gives m/s -> multiply by 3.6 for km/h
    final double speedInKmH = pos.speed < 0 ? 0.0 : (pos.speed * 3.6);
    // Normalize heading: 0.0 - 360.0 degrees
    final double headingDegrees =
        pos.heading < 0 ? 0.0 : (pos.heading % 360.0);

    // Ensure socket is attempting connection if we have auth token
    if (!_socketService.isConnected.value &&
        token != null &&
        token.isNotEmpty) {
      _connectSocketIfPossible();
    }

    // 1.1 Primary Real-Time Streaming (Socket.IO)
    // Stream coordinates every 3-5 seconds when socket is connected
    if (_socketService.isConnected.value) {
      _wasSocketConnected = true;
      final success = _socketService.emitLocationUpdate(
        riderId: riderId,
        orderId: activeOrderId.value,
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: double.parse(headingDegrees.toStringAsFixed(1)),
        speed: double.parse(speedInKmH.toStringAsFixed(1)),
        isOnline: isOnline,
        deviceId: deviceId,
      );

      if (success) {
        telemetryMode.value = TelemetryMode.socketStreaming;
        lastSyncTimestamp.value = DateTime.now();
        lastSyncError.value = null;
        debugPrint(
            '[LocationService] Streamed GPS via Socket.IO: (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}) heading: ${headingDegrees.toStringAsFixed(1)}° speed: ${speedInKmH.toStringAsFixed(1)} km/h, isOnline: $isOnline, deviceId: $deviceId, order: ${activeOrderId.value}');
        return;
      }
    }

    // 1.2 Fallback Background Telemetry (REST API)
    // Strictly an Emergency Fallback / Heartbeat:
    // - One-off immediate call if socket just dropped (_wasSocketConnected was true)
    // - Periodic REST heartbeat once every 15-30 seconds if socket remains disconnected or in background
    final now = DateTime.now();
    final bool socketJustDropped = _wasSocketConnected;
    final bool isHeartbeatDue = _lastRestFallbackTimestamp == null ||
        now.difference(_lastRestFallbackTimestamp!).inSeconds >=
            restFallbackHeartbeatSeconds;

    if (forceRest || socketJustDropped || isHeartbeatDue) {
      _wasSocketConnected = false;
      _lastRestFallbackTimestamp = now;

      await _sendRestFallback(
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: double.parse(headingDegrees.toStringAsFixed(1)),
        speed: double.parse(speedInKmH.toStringAsFixed(1)),
        deviceId: deviceId,
      );
    } else {
      debugPrint(
          '[LocationService] Socket disconnected; REST fallback skipped to prevent flooding (heartbeat due in ${restFallbackHeartbeatSeconds - now.difference(_lastRestFallbackTimestamp!).inSeconds}s)');
    }
  }

  /// REST API Fallback (POST /mobileapi/rider/location)
  Future<void> _sendRestFallback({
    required double latitude,
    required double longitude,
    required double heading,
    required double speed,
    String? deviceId,
  }) async {
    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'isOnline': _authLocalDataSource?.getIsOnline() ?? true,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    };

    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.location,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        telemetryMode.value = TelemetryMode.restFallback;
        lastSyncTimestamp.value = DateTime.now();
        lastSyncError.value = null;
        debugPrint('[LocationService] Fallback REST telemetry synced: $payload');
      } else {
        telemetryMode.value = TelemetryMode.error;
        lastSyncError.value = 'Status code: ${response.statusCode}';
        debugPrint(
            '[LocationService] Fallback REST telemetry failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Checklist Point 3: Single Active Driving Device HTTP 409 Conflict Handling
      if (e.response?.statusCode == 409 ||
          e.response?.data is Map &&
              (e.response?.data['error'] == 'DEVICE_SWITCHED' ||
                  e.response?.data['shouldStopTracking'] == true)) {
        final serverMessage = (e.response?.data is Map && e.response?.data['message'] != null)
            ? e.response?.data['message'].toString()
            : 'You have switched to another device. Tracking stopped on this device.';
        debugPrint('[LocationService] HTTP 409 Conflict: $serverMessage');
        handleDeviceSwitched(serverMessage);
        return;
      }
      telemetryMode.value = TelemetryMode.error;
      lastSyncError.value = e.toString();
      debugPrint('[LocationService] Fallback REST telemetry exception: $e');
    } catch (e) {
      telemetryMode.value = TelemetryMode.error;
      lastSyncError.value = e.toString();
      debugPrint('[LocationService] Fallback REST telemetry exception: $e');
    }
  }
}
