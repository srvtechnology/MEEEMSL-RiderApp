import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/services/socket_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SocketService Tests (Section 1.1)', () {
    late SocketService socketService;

    setUp(() {
      socketService = SocketService();
    });

    tearDown(() {
      socketService.disconnect();
    });

    test('Initializes in disconnected state', () {
      expect(socketService.isConnected.value, isFalse);
      expect(socketService.connectionState.value,
          SocketConnectionState.disconnected);
      expect(socketService.currentRiderId.value, isNull);
      expect(socketService.lastEmittedEvent.value, isNull);
    });

    test('emitLocationUpdate returns false when not connected', () {
      final result = socketService.emitLocationUpdate(
        riderId: 'cuid_test_rider_1',
        orderId: 'cuid_test_order_1',
        latitude: 8.484245,
        longitude: -13.234125,
        heading: 145.2,
        speed: 28.5,
      );

      expect(result, isFalse);
      expect(socketService.lastEmittedEvent.value, isNull);
      expect(socketService.lastEmittedTimestamp.value, isNull);
    });

    test('disconnect safely cleans up state and resets observables', () {
      socketService.currentRiderId.value = 'cuid_rider_123';
      socketService.isConnected.value = true;
      socketService.connectionState.value = SocketConnectionState.connected;

      socketService.disconnect();

      expect(socketService.isConnected.value, isFalse);
      expect(socketService.connectionState.value,
          SocketConnectionState.disconnected);
      expect(socketService.currentRiderId.value, isNull);
    });

    test('telemetrySocketUrl points to dedicated SSL socket server without port 3001', () {
      expect(ApiEndpoints.telemetrySocketUrl, 'https://socket.meeemsl.com');
      expect(ApiEndpoints.telemetrySocketUrl.contains(':3001'), isFalse);
    });
  });
}
