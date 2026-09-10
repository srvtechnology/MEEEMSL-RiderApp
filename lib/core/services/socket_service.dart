import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_endpoints.dart';

/// Connection states for real-time WebSocket communication
enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// SocketService manages the persistent Socket.IO connection for real-time
/// rider telemetry streaming and server-broadcasted event handling.
///
/// Conforms to MOBILE_RIDER_APP_API_DOC_PART_2.md (Section 1.1).
class SocketService extends GetxService {
  io.Socket? _socket;

  // Reactive state
  final RxBool isConnected = false.obs;
  final Rx<SocketConnectionState> connectionState =
      SocketConnectionState.disconnected.obs;
  final RxnString currentRiderId = RxnString();
  final RxnString lastEmittedEvent = RxnString();
  final Rxn<DateTime> lastEmittedTimestamp = Rxn<DateTime>();

  // Cross-device sync callbacks (Checklist Point 4)
  static void Function(bool isOnline)? onRiderStatusChanged;
  static void Function(Map<String, dynamic> data)? onActiveDeviceChanged;

  io.Socket? get socket => _socket;

  /// Connects to the WebSocket server with JWT Bearer authentication.
  ///
  /// Auth payload:
  /// ```json
  /// {
  ///   "auth": {
  ///     "riderId": "<riderId>",
  ///     "token": "Bearer <accessToken>"
  ///   }
  /// }
  /// ```
  void connect({
    required String riderId,
    required String token,
    String? customUrl,
  }) {
    if (_socket != null &&
        isConnected.value &&
        currentRiderId.value == riderId) {
      return;
    }

    disconnect();

    currentRiderId.value = riderId;
    connectionState.value = SocketConnectionState.connecting;

    final url = customUrl ?? ApiEndpoints.telemetrySocketUrl;
    final formattedToken =
        token.startsWith('Bearer ') ? token : 'Bearer $token';

    debugPrint(
        '[SocketService] Connecting to Socket.IO server: $url for rider: $riderId');

    try {
      _socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({
              'token': formattedToken,
              'riderId': riderId,
            })
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(double.infinity)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(6000)
            .build(),
      );

      _socket?.onConnect((_) {
        debugPrint('[Socket] Rider connected: ${_socket?.id}');
        debugPrint('[SocketService] Connected to telemetry socket: $url');
        isConnected.value = true;
        connectionState.value = SocketConnectionState.connected;

        // Checklist Point 4: Socket.IO Real-Time Cross-Device Sync
        _socket?.on('rider:status_changed', (data) {
          debugPrint('[SocketService] Received rider:status_changed: $data');
          final isOnline = (data is Map && data['isOnline'] != null)
              ? (data['isOnline'] as bool)
              : false;
          onRiderStatusChanged?.call(isOnline);
        });

        _socket?.on('rider:active_device_changed', (data) {
          debugPrint('[SocketService] Received rider:active_device_changed: $data');
          if (data is Map) {
            onActiveDeviceChanged?.call(Map<String, dynamic>.from(data));
          }
        });
      });

      _socket?.onDisconnect((reason) {
        debugPrint('[SocketService] Disconnected from telemetry socket: $reason');
        isConnected.value = false;
        connectionState.value = SocketConnectionState.disconnected;
      });

      _socket?.onConnectError((error) {
        debugPrint('[Socket] Error: $error');
        debugPrint('[SocketService] Telemetry socket connect error: $error');
        isConnected.value = false;
        connectionState.value = SocketConnectionState.error;
      });

      _socket?.onError((error) {
        debugPrint('[SocketService] Telemetry socket error: $error');
      });

      _socket?.onReconnect((attempt) {
        debugPrint('[SocketService] Telemetry socket reconnected (attempt: $attempt)');
        isConnected.value = true;
        connectionState.value = SocketConnectionState.connected;
      });

      _socket?.onReconnectAttempt((attempt) {
        debugPrint('[SocketService] Telemetry socket reconnect attempt: $attempt');
        connectionState.value = SocketConnectionState.connecting;
      });

      // Explicitly trigger connection
      _socket?.connect();
    } catch (e) {
      debugPrint('[SocketService] Error creating socket connection: $e');
      isConnected.value = false;
      connectionState.value = SocketConnectionState.error;
    }
  }

  /// Closes and disposes of the persistent socket connection.
  void disconnect() {
    if (_socket != null) {
      try {
        _socket?.clearListeners();
        _socket?.disconnect();
        _socket?.dispose();
      } catch (e) {
        debugPrint('[SocketService] Exception disconnecting socket: $e');
      }
      _socket = null;
    }
    isConnected.value = false;
    connectionState.value = SocketConnectionState.disconnected;
    currentRiderId.value = null;
  }

  /// Joins the order room for real-time tracking (MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8 Section 5).
  bool joinOrder(String orderId) {
    if (_socket == null || !isConnected.value) {
      return false;
    }
    try {
      _socket?.emit('join_order', {'orderId': orderId});
      debugPrint('[SocketService] Emitted join_order for order: $orderId');
      return true;
    } catch (e) {
      debugPrint('[SocketService] Error emitting join_order: $e');
      return false;
    }
  }

  /// Leaves the order room for real-time tracking (Part 8 Section 5).
  bool leaveOrder(String orderId) {
    if (_socket == null || !isConnected.value) {
      return false;
    }
    try {
      _socket?.emit('leave_order', {'orderId': orderId});
      debugPrint('[SocketService] Emitted leave_order for order: $orderId');
      return true;
    } catch (e) {
      debugPrint('[SocketService] Error emitting leave_order: $e');
      return false;
    }
  }

  /// Emits real-time GPS telemetry to the server via the "rider_location_update" event.
  ///
  /// Conforms to MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8 (Section 5).
  ///
  /// Payload schema:
  /// ```json
  /// {
  ///   "riderId": "cuid_rider_id",
  ///   "orderId": "cuid_active_order_id", // null if idle/roaming
  ///   "latitude": 8.484245,
  ///   "longitude": -13.234125,
  ///   "heading": 145.2,
  ///   "speed": 28.5
  /// }
  /// ```
  bool emitLocationUpdate({
    required String riderId,
    String? orderId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    bool isOnline = true,
    String? deviceId,
  }) {
    if (_socket == null || !isConnected.value) {
      return false;
    }

    final payload = <String, dynamic>{
      'riderId': riderId,
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading ?? 0.0,
      'speed': speed ?? 0.0,
      'isOnline': isOnline,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    };

    try {
      // Part 8 Section 5: emit 'rider_location_update'
      _socket?.emit('rider_location_update', payload);
      // Checklist Point 2: emit 'rider:location_update'
      _socket?.emit('rider:location_update', payload);
      lastEmittedEvent.value = 'rider:location_update';
      lastEmittedTimestamp.value = DateTime.now();
      debugPrint(
          '[SocketService] Emitted rider:location_update: lat: $latitude, lng: $longitude, isOnline: $isOnline, deviceId: $deviceId, orderId: $orderId, heading: ${heading ?? 0.0}, speed: ${speed ?? 0.0} km/h');
      return true;
    } catch (e) {
      debugPrint('[SocketService] Error emitting location update: $e');
      return false;
    }
  }

  /// Emits real-time Online/Offline status update (Checklist Point 1).
  /// Event: "rider:status_update" with payload: { "riderId": "...", "isOnline": true/false, "deviceId": "..." }
  bool emitStatusUpdate({
    required String riderId,
    required bool isOnline,
    String? deviceId,
    String? deviceModel,
  }) {
    if (_socket == null || !isConnected.value) {
      return false;
    }

    final payload = <String, dynamic>{
      'riderId': riderId,
      'isOnline': isOnline,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
      if (isOnline && deviceModel != null && deviceModel.isNotEmpty) 'deviceModel': deviceModel,
    };

    try {
      _socket?.emit('rider:status_update', payload);
      _socket?.emit('rider_status_update', payload);
      lastEmittedEvent.value = 'rider:status_update';
      lastEmittedTimestamp.value = DateTime.now();
      debugPrint('[SocketService] Emitted rider:status_update: $payload');
      return true;
    } catch (e) {
      debugPrint('[SocketService] Error emitting status update: $e');
      return false;
    }
  }

  /// Registers an event listener on the active socket.
  void on(String event, dynamic Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Unregisters an event listener on the active socket.
  void off(String event) {
    _socket?.off(event);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
