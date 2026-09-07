import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/rider_settings_model.dart';

void main() {
  group('RiderSettingsModel & RiderStatsModel Part 3 Integration Tests', () {
    test('parses stats correctly from JSON matching Section 4.1', () {
      final json = {
        'success': true,
        'user': {
          'id': 'cuid_user_id',
          'name': 'Ibrahim Koroma',
          'email': 'rider.ibrahim@example.com',
          'phone': '76123456',
          'phoneCountryCode': '+232',
          'image': 'https://.../rider-pfp.jpg',
        },
        'rider': {
          'id': 'cuid_rider_id',
          'status': 'APPROVED',
          'isOnline': true,
          'vehicleTypes': ['2_WHEELER'],
          'vehicleNumber': 'SL-3829-B',
          'selectedZones': ['ZONE 1', 'ZONE 2'],
          'selectedLocations': ['LUMLEY', 'ABERDEEN'],
        },
        'stats': {
          'totalEarnings': 640.00,
          'completedDeliveriesCount': 32,
          'activeDeliveriesCount': 1,
        },
      };

      final settings = RiderSettingsModel.fromJson(json);

      expect(settings.stats, isNotNull);
      expect(settings.stats?.totalEarnings, equals(640.00));
      expect(settings.stats?.completedDeliveriesCount, equals(32));
      expect(settings.stats?.activeDeliveriesCount, equals(1));

      final serialized = settings.toJson();
      expect(serialized['stats'], isNotNull);
      expect(serialized['stats']['totalEarnings'], equals(640.00));
      expect(serialized['stats']['completedDeliveriesCount'], equals(32));
      expect(serialized['stats']['activeDeliveriesCount'], equals(1));
    });

    test('RiderStatsModel handles null or missing values gracefully with defaults', () {
      final stats = RiderStatsModel.fromJson({});

      expect(stats.totalEarnings, equals(0.0));
      expect(stats.completedDeliveriesCount, equals(0));
      expect(stats.activeDeliveriesCount, equals(0));
    });
  });
}
