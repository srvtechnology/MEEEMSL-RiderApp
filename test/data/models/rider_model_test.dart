import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/rider_model.dart';

void main() {
  group('RiderModel JSON parsing', () {
    test('correctly parses onboardingCompleted: false and isFirstLogin: true from login API', () {
      final json = {
        "id": "cmtl8qc5e0009hoi095of0u0g",
        "isApproved": true,
        "isSuspended": false,
        "status": "APPROVED",
        "onboardingCompleted": false,
        "isFirstLogin": true,
        "vehicleTypes": [],
        "vehicleNumber": null,
        "drivingLicenseNo": null,
        "profileImage": null,
        "selectedZones": [],
        "selectedLocations": []
      };

      final rider = RiderModel.fromJson(json);

      expect(rider.id, 'cmtl8qc5e0009hoi095of0u0g');
      expect(rider.onboardingCompleted, false);
      expect(rider.isFirstLogin, true);
      expect(rider.vehicleNumber, isNull);
      expect(rider.drivingLicenseNo, isNull);
      expect(rider.selectedZones, isEmpty);
    });

    test('defaults onboardingCompleted to false when field is missing', () {
      final json = {
        "id": "cmtl8qc5e0009hoi095of0u0g",
        "status": "APPROVED",
      };

      final rider = RiderModel.fromJson(json);

      expect(rider.onboardingCompleted, false);
    });

    test('correctly parses string and boolean variations', () {
      final riderFalseStr = RiderModel.fromJson({
        "id": "1",
        "onboardingCompleted": "false",
        "isFirstLogin": "true",
      });
      expect(riderFalseStr.onboardingCompleted, false);
      expect(riderFalseStr.isFirstLogin, true);

      final riderTrue = RiderModel.fromJson({
        "id": "2",
        "onboardingCompleted": true,
        "isFirstLogin": false,
      });
      expect(riderTrue.onboardingCompleted, true);
      expect(riderTrue.isFirstLogin, false);
    });
  });
}
