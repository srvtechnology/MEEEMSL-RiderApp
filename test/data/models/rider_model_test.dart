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

    test('correctly merges user details when userJson is supplied or nested', () {
      final riderJson = {
        "id": "cm7rider0001",
        "status": "APPROVED",
        "isApproved": true,
        "isSuspended": false,
        "vehicleType": "2_WHEELER",
        "vehicleName": "Honda CB Shine 125",
        "vehicleNumber": "SL-AA-9988",
      };
      final userJson = {
        "id": "cm7abc123000",
        "email": "rider.ibrahim@example.com",
        "name": "Ibrahim Koroma",
        "phone": "76123456",
        "phoneCountryCode": "+232",
        "image": "https://s3.amazonaws.com/meeem/profiles/ibrahim.jpg",
      };

      final rider = RiderModel.fromJson(riderJson, userJson);

      expect(rider.id, 'cm7rider0001');
      expect(rider.name, 'Ibrahim Koroma');
      expect(rider.email, 'rider.ibrahim@example.com');
      expect(rider.phone, '+232 76123456');
      expect(rider.avatar, 'https://s3.amazonaws.com/meeem/profiles/ibrahim.jpg');
      expect(rider.vehicleType, '2_WHEELER');
      expect(rider.vehicleName, 'Honda CB Shine 125');
      expect(rider.vehicleNumber, 'SL-AA-9988');
    });
  });
}
