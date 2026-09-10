import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/services/location_service.dart';
import 'package:meeem_rider/core/services/socket_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSocketService extends Mock implements SocketService {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Part 8 Socket.IO Telemetry Tests (Section 5)', () {
    late SocketService socketService;

    setUp(() {
      socketService = SocketService();
    });

    tearDown(() {
      socketService.disconnect();
    });

    test('telemetrySocketUrl adheres to https://socket.meeemsl.com (Port 443 SSL / WSS without :3001)', () {
      expect(ApiEndpoints.telemetrySocketUrl, 'https://socket.meeemsl.com');
      expect(ApiEndpoints.telemetrySocketUrl.contains(':3001'), isFalse);
    });

    test('joinOrder returns false when not connected', () {
      final result = socketService.joinOrder('cuid_order_123');
      expect(result, isFalse);
    });

    test('leaveOrder returns false when not connected', () {
      final result = socketService.leaveOrder('cuid_order_123');
      expect(result, isFalse);
    });

    test('LocationService.setActiveOrderId calls joinOrder and leaveOrder appropriately', () {
      final mockSocket = MockSocketService();
      final mockDioClient = MockDioClient();
      when(() => mockSocket.joinOrder(any())).thenReturn(true);
      when(() => mockSocket.leaveOrder(any())).thenReturn(true);

      final locationService = LocationService(mockDioClient, mockSocket);

      // Set first active order
      locationService.setActiveOrderId('cuid_order_1');
      expect(locationService.activeOrderId.value, 'cuid_order_1');
      verify(() => mockSocket.joinOrder('cuid_order_1')).called(1);

      // Switch to another order
      locationService.setActiveOrderId('cuid_order_2');
      expect(locationService.activeOrderId.value, 'cuid_order_2');
      verify(() => mockSocket.leaveOrder('cuid_order_1')).called(1);
      verify(() => mockSocket.joinOrder('cuid_order_2')).called(1);

      // Clear order (trip completed/cancelled)
      locationService.setActiveOrderId(null);
      expect(locationService.activeOrderId.value, isNull);
      verify(() => mockSocket.leaveOrder('cuid_order_2')).called(1);
    });

    test('emitStatusUpdate returns false when disconnected', () {
      final result = socketService.emitStatusUpdate(
        riderId: 'cuid_rider_1',
        isOnline: false,
      );
      expect(result, isFalse);
    });

    test('emitLocationUpdate accepts isOnline and returns false when disconnected', () {
      final result = socketService.emitLocationUpdate(
        riderId: 'cuid_rider_1',
        latitude: 8.484245,
        longitude: -13.234125,
        isOnline: true,
      );
      expect(result, isFalse);
    });
  });
}
