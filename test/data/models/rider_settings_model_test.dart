import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/registered_device_model.dart';
import 'package:meeem_rider/data/models/rider_settings_model.dart';
import 'package:meeem_rider/domain/entities/registered_device_entity.dart';
import 'package:meeem_rider/domain/entities/rider_settings_entity.dart';

void main() {
  group('RegisteredDeviceModel Tests', () {
    const tDeviceModel = RegisteredDeviceModel(
      token: 'fcm_token_123',
      deviceId: 'android-uuid-1',
      platform: 'android',
      deviceModel: 'Samsung Galaxy S22',
    );

    test('RegisteredDeviceModel should be a subclass of RegisteredDeviceEntity', () {
      expect(tDeviceModel, isA<RegisteredDeviceEntity>());
    });

    test('RegisteredDeviceModel fromJson & toJson parses correctly', () {
      final json = {
        'token': 'fcm_token_123',
        'deviceId': 'android-uuid-1',
        'platform': 'android',
        'deviceModel': 'Samsung Galaxy S22',
        'lastActiveAt': '2026-08-26T12:00:00.000Z',
      };

      final model = RegisteredDeviceModel.fromJson(json);
      expect(model.token, 'fcm_token_123');
      expect(model.deviceId, 'android-uuid-1');
      expect(model.platform, 'android');
      expect(model.deviceModel, 'Samsung Galaxy S22');
      expect(model.lastActiveAt, DateTime.parse('2026-08-26T12:00:00.000Z'));

      final serialized = model.toJson();
      expect(serialized['deviceId'], 'android-uuid-1');
      expect(serialized['deviceModel'], 'Samsung Galaxy S22');
    });
  });

  group('RiderSettingsModel Section 7.1 Full Settings Tests', () {
    test('RiderSettingsModel parses Section 7.1 GET response with user, rider & registeredDevices', () {
      final json = {
        'user': {
          'id': 'cm7abc123000',
          'email': 'rider.ibrahim@example.com',
          'name': 'Ibrahim Koroma',
          'phone': '76123456',
          'phoneCountryCode': '+232',
          'image': 'https://s3.amazonaws.com/meeem/avatar.png',
          'isEmailVerified': true,
        },
        'rider': {
          'id': 'cm7rider0001',
          'isApproved': true,
          'isSuspended': false,
          'status': 'APPROVED',
          'vehicleType': '2_WHEELER',
          'vehicleTypes': ['2_WHEELER'],
          'vehicleName': 'Honda CB Shine 125',
          'vehicleNumber': 'SL-AA-9988',
          'drivingLicenseNo': 'DL-10928374',
          'profileImage': 'https://s3.amazonaws.com/meeem/profile.png',
          'selectedZones': ['ZONE 1', 'ZONE 2'],
          'selectedLocations': ['NO 2 RIVER', 'BAW BAW'],
        },
        'registeredDevices': [
          {
            'token': 'fcm_token_123',
            'deviceId': 'android-uuid-1',
            'platform': 'android',
            'deviceModel': 'Samsung Galaxy S22',
            'lastActiveAt': '2026-08-26T12:00:00.000Z',
          }
        ],
        'notifications': {
          'orderAlerts': true,
          'promotionalAlerts': false,
          'soundEnabled': true,
          'vibrationEnabled': true,
        },
        'navigation': {
          'defaultMapApp': 'GOOGLE_MAPS',
          'voiceGuidance': true,
          'avoidTolls': false,
        },
        'appPreferences': {
          'theme': 'SYSTEM',
          'language': 'en',
          'distanceUnit': 'KM',
        },
      };

      final settings = RiderSettingsModel.fromJson(json);

      expect(settings, isA<RiderSettingsEntity>());
      expect(settings.user?.name, 'Ibrahim Koroma');
      expect(settings.user?.email, 'rider.ibrahim@example.com');
      expect(settings.user?.isEmailVerified, true);
      expect(settings.rider?.id, 'cm7rider0001');
      expect(settings.rider?.status, 'APPROVED');
      expect(settings.rider?.selectedZones, ['ZONE 1', 'ZONE 2']);
      expect(settings.registeredDevices.length, 1);
      expect(settings.registeredDevices.first.deviceModel, 'Samsung Galaxy S22');
      expect(settings.notifications.orderAlerts, true);
      expect(settings.navigation.defaultMapApp, 'GOOGLE_MAPS');
      expect(settings.appPreferences.distanceUnit, 'KM');

      final serialized = settings.toJson();
      expect(serialized['user'], isNotNull);
      expect(serialized['rider'], isNotNull);
      expect(serialized['registeredDevices'], isNotEmpty);
    });
  });
}
