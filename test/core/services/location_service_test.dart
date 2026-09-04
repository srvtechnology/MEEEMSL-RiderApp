import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/services/location_service.dart';

class MockDioClient extends Mock implements DioClient {}

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
      locationService = LocationService(mockDioClient);
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
  });
}
