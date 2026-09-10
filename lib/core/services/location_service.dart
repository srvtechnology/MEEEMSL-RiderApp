import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
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
  static const int restFallbackHeartbeatSeconds = 50; // 45-60 seconds REST heartbeat fallback per backend spec

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

    // Listen to real-time device GPS position stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update when moved 5 meters
    );

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
    _socketService.disconnect();
    isTrackingActive.value = false;
    telemetryMode.value = TelemetryMode.idle;
    _lastRestFallbackTimestamp = null;
    _wasSocketConnected = false;
    debugPrint('[LocationService] GPS tracking & telemetry stopped.');
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
      );

      if (success) {
        telemetryMode.value = TelemetryMode.socketStreaming;
        lastSyncTimestamp.value = DateTime.now();
        lastSyncError.value = null;
        debugPrint(
            '[LocationService] Streamed GPS via Socket.IO: (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}) heading: ${headingDegrees.toStringAsFixed(1)}° speed: ${speedInKmH.toStringAsFixed(1)} km/h, order: ${activeOrderId.value}');
        return;
      }
    }

    // 1.2 Fallback Background Telemetry (REST API)
    // Strictly an Emergency Fallback / Heartbeat:
    // - One-off immediate call if socket just dropped (_wasSocketConnected was true)
    // - Slow REST heartbeat once every 45-60 seconds if socket remains disconnected or in background
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
  }) async {
    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'isOnline': _authLocalDataSource?.getIsOnline() ?? true,
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
    } catch (e) {
      telemetryMode.value = TelemetryMode.error;
      lastSyncError.value = e.toString();
      debugPrint('[LocationService] Fallback REST telemetry exception: $e');
    }
  }
}
