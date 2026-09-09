import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/services/location_service.dart';
import 'package:meeem_rider/core/services/socket_service.dart';
import 'package:meeem_rider/data/datasources/auth_local_datasource.dart';

class MockDioClient extends Mock implements DioClient {}
class MockSocketService extends Mock implements SocketService {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockDio extends Mock implements dio.Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('iOS Info.plist Permission Definitions Tests', () {
    test('Info.plist contains all required Location and Background mode permissions', () {
      final plistFile = File('ios/Runner/Info.plist');
      expect(plistFile.existsSync(), isTrue, reason: 'ios/Runner/Info.plist must exist');

      final content = plistFile.readAsStringSync();

      // Verify NSLocationWhenInUseUsageDescription
      expect(content.contains('<key>NSLocationWhenInUseUsageDescription</key>'), isTrue,
          reason: 'Must include NSLocationWhenInUseUsageDescription');

      // Verify NSLocationAlwaysAndWhenInUseUsageDescription
      expect(content.contains('<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>'), isTrue,
          reason: 'Must include NSLocationAlwaysAndWhenInUseUsageDescription');

      // Verify NSLocationAlwaysUsageDescription
      expect(content.contains('<key>NSLocationAlwaysUsageDescription</key>'), isTrue,
          reason: 'Must include NSLocationAlwaysUsageDescription');

      // Verify UIBackgroundModes includes location
      expect(content.contains('<key>UIBackgroundModes</key>'), isTrue,
          reason: 'Must include UIBackgroundModes');
      expect(content.contains('<string>location</string>'), isTrue,
          reason: 'UIBackgroundModes must include location');

      // Verify Camera & Photo library
      expect(content.contains('<key>NSCameraUsageDescription</key>'), isTrue);
      expect(content.contains('<key>NSPhotoLibraryUsageDescription</key>'), isTrue);
    });

    test('AndroidManifest.xml contains required Location and Camera permissions', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);

      final content = manifestFile.readAsStringSync();
      expect(content.contains('android.permission.ACCESS_FINE_LOCATION'), isTrue);
      expect(content.contains('android.permission.ACCESS_COARSE_LOCATION'), isTrue);
      expect(content.contains('android.permission.ACCESS_BACKGROUND_LOCATION'), isTrue);
      expect(content.contains('android.permission.CAMERA'), isTrue);
    });
  });

  group('LocationService Tests', () {
    late MockDioClient mockDioClient;
    late LocationService locationService;

    setUp(() {
      Get.testMode = true;
      mockDioClient = MockDioClient();
      when(() => mockDioClient.dio).thenReturn(dio.Dio());
      locationService = LocationService(mockDioClient);
      locationService.onInit();
    });

    tearDown(() {
      locationService.onClose();
      Get.reset();
    });

    test('Initializes with defaultFallbackPosition and default state', () {
      expect(locationService.currentPosition.value, isNotNull);
      expect(locationService.currentPosition.value?.latitude, LocationService.defaultFallbackPosition.latitude);
      expect(locationService.currentPosition.value?.longitude, LocationService.defaultFallbackPosition.longitude);
      expect(locationService.isTrackingActive.value, isFalse);
      expect(locationService.hasPermission.value, isFalse);
    });

    test('stopTracking sets isTrackingActive to false and cleans up timers', () {
      locationService.isTrackingActive.value = true;
      locationService.stopTracking();
      expect(locationService.isTrackingActive.value, isFalse);
    });

    test('checkAndRequestPermissions catches platform exceptions and does not crash', () async {
      // In a unit test environment without real platform channels, checkAndRequestPermissions
      // should catch MissingPluginException / platform errors gracefully
      final result = await locationService.checkAndRequestPermissions();
      expect(result, isFalse);
      expect(locationService.hasPermission.value, isFalse);
    });

    test('startTracking handles missing platform channels without throwing unhandled exceptions', () async {
      await locationService.startTracking();
      expect(locationService.isTrackingActive.value, isTrue);
      locationService.stopTracking();
      expect(locationService.isTrackingActive.value, isFalse);
    });

    test('1.1 Primary Streaming: emits via Socket.IO when socket is connected', () async {
      final mockSocket = MockSocketService();
      final mockAuth = MockAuthLocalDataSource();

      when(() => mockSocket.isConnected).thenReturn(true.obs);
      when(() => mockSocket.connectionState)
          .thenReturn(SocketConnectionState.connected.obs);
      when(() => mockAuth.getToken()).thenReturn('mock_jwt_token');
      when(() => mockAuth.getSavedRider()).thenReturn(null);
      when(() => mockAuth.getSavedUser()).thenReturn(null);
      when(() => mockSocket.emitLocationUpdate(
            riderId: any(named: 'riderId'),
            orderId: any(named: 'orderId'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            heading: any(named: 'heading'),
            speed: any(named: 'speed'),
          )).thenReturn(true);

      final telemetryService = LocationService(
        mockDioClient,
        mockSocket,
        mockAuth,
      );
      telemetryService.isTrackingActive.value = true;
      telemetryService.setActiveOrderId('cuid_active_order_42');

      await telemetryService.sendLocationUpdate();

      verify(() => mockSocket.emitLocationUpdate(
            riderId: any(named: 'riderId'),
            orderId: 'cuid_active_order_42',
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            heading: any(named: 'heading'),
            speed: any(named: 'speed'),
          )).called(1);

      expect(telemetryService.telemetryMode.value,
          TelemetryMode.socketStreaming);
      expect(telemetryService.lastSyncTimestamp.value, isNotNull);
      expect(telemetryService.lastSyncError.value, isNull);
    });

    test('1.2 Fallback Telemetry: posts to REST API when socket is disconnected', () async {
      final mockSocket = MockSocketService();
      final mockAuth = MockAuthLocalDataSource();
      final mockDio = MockDio();

      when(() => mockSocket.isConnected).thenReturn(false.obs);
      when(() => mockSocket.connectionState)
          .thenReturn(SocketConnectionState.disconnected.obs);
      when(() => mockAuth.getToken()).thenReturn('mock_jwt_token');
      when(() => mockAuth.getSavedRider()).thenReturn(null);
      when(() => mockAuth.getSavedUser()).thenReturn(null);
      when(() => mockAuth.getIsOnline()).thenReturn(true);

      when(() => mockDioClient.dio).thenReturn(mockDio);
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => dio.Response(
            requestOptions: dio.RequestOptions(path: '/location'),
            statusCode: 200,
            data: {
              'success': true,
              'message': 'Location updated successfully',
              'data': {
                'id': 'cuid_rider_id',
                'currentLatitude': 8.484245,
                'currentLongitude': -13.234125,
                'isOnline': true,
              }
            },
          ));

      final telemetryService = LocationService(
        mockDioClient,
        mockSocket,
        mockAuth,
      );
      telemetryService.isTrackingActive.value = true;

      await telemetryService.sendLocationUpdate();

      verify(() => mockDio.post(
            '/location',
            data: any(named: 'data'),
          )).called(1);

      expect(telemetryService.telemetryMode.value, TelemetryMode.restFallback);
      expect(telemetryService.lastSyncTimestamp.value, isNotNull);
      expect(telemetryService.lastSyncError.value, isNull);
    });

    test('1.2 Fallback Telemetry: throttles repeated REST fallback calls within 50s heartbeat', () async {
      final mockSocket = MockSocketService();
      final mockAuth = MockAuthLocalDataSource();
      final mockDio = MockDio();

      when(() => mockSocket.isConnected).thenReturn(false.obs);
      when(() => mockSocket.connectionState)
          .thenReturn(SocketConnectionState.disconnected.obs);
      when(() => mockAuth.getToken()).thenReturn('mock_jwt_token');
      when(() => mockAuth.getSavedRider()).thenReturn(null);
      when(() => mockAuth.getSavedUser()).thenReturn(null);
      when(() => mockAuth.getIsOnline()).thenReturn(true);

      when(() => mockDioClient.dio).thenReturn(mockDio);
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => dio.Response(
            requestOptions: dio.RequestOptions(path: '/location'),
            statusCode: 200,
            data: {'success': true},
          ));

      final telemetryService = LocationService(
        mockDioClient,
        mockSocket,
        mockAuth,
      );
      telemetryService.isTrackingActive.value = true;

      // 1st call -> immediate drop / first heartbeat fallback
      await telemetryService.sendLocationUpdate();

      // 2nd call immediate after (4s simulation) -> should be throttled
      await telemetryService.sendLocationUpdate();
      await telemetryService.sendLocationUpdate();

      // Ensure mockDio.post('/location') was only called once, not 3 times
      verify(() => mockDio.post(
            '/location',
            data: any(named: 'data'),
          )).called(1);
    });
  });
}
