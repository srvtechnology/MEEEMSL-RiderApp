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
            .setTransports(['websocket'])
            .setAuth({
              'riderId': riderId,
              'token': formattedToken,
            })
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(double.infinity)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .build(),
      );

      _socket?.onConnect((_) {
        debugPrint('[SocketService] Connected to telemetry socket: $url');
        isConnected.value = true;
        connectionState.value = SocketConnectionState.connected;
      });

      _socket?.onDisconnect((reason) {
        debugPrint('[SocketService] Disconnected from telemetry socket: $reason');
        isConnected.value = false;
        connectionState.value = SocketConnectionState.disconnected;
      });

      _socket?.onConnectError((error) {
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

  /// Emits real-time GPS telemetry to the server via the "rider:location_update" event.
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
    required double heading,
    required double speed,
  }) {
    if (_socket == null || !isConnected.value) {
      return false;
    }

    final payload = <String, dynamic>{
      'riderId': riderId,
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
    };

    try {
      _socket?.emit('rider:location_update', payload);
      lastEmittedEvent.value = 'rider:location_update';
      lastEmittedTimestamp.value = DateTime.now();
      debugPrint(
          '[SocketService] Emitted rider:location_update: lat: $latitude, lng: $longitude, orderId: $orderId, speed: $speed km/h');
      return true;
    } catch (e) {
      debugPrint('[SocketService] Error emitting location update: $e');
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
