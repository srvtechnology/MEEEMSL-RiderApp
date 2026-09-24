import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/reset_password_result_model.dart';
import 'package:meeem_rider/domain/entities/reset_password_result_entity.dart';

void main() {
  group('SendResetOtpResultModel', () {
    test('should be a subclass of SendResetOtpResultEntity', () {
      const model = SendResetOtpResultModel(
        identity: 'rider@example.com',
        identityType: 'EMAIL',
        maskedDestination: 'rider@example.com',
        email: 'rider@example.com',
        phone: '+23276123456',
        expiresIn: 600,
        resendCooldown: 60,
      );

      expect(model, isA<SendResetOtpResultEntity>());
    });

    test('fromJson parses from MOBILE_RIDER_FORGOT_PASSWORD_API_DOC schema', () {
      final json = {
        'email': 'rider@example.com',
        'phone': '+23276123456',
        'expiresIn': 600,
        'resendCooldown': 60,
      };

      final model = SendResetOtpResultModel.fromJson(json);

      expect(model.email, 'rider@example.com');
      expect(model.phone, '+23276123456');
      expect(model.identity, 'rider@example.com');
      expect(model.identityType, 'EMAIL');
      expect(model.maskedDestination, 'rider@example.com & +23276123456');
      expect(model.expiresIn, 600);
      expect(model.resendCooldown, 60);
    });

    test('fromJson parses phone-only payload properly', () {
      final json = {
        'identifier': '+23276123456',
        'phone': '+23276123456',
        'expiresIn': 300,
        'resendCooldown': 45,
      };

      final model = SendResetOtpResultModel.fromJson(json);

      expect(model.phone, '+23276123456');
      expect(model.identity, '+23276123456');
      expect(model.identityType, 'PHONE');
      expect(model.expiresIn, 300);
      expect(model.resendCooldown, 45);
    });

    test('fromJson preserves legacy schema fields', () {
      final json = {
        'identity': 'custom@domain.com',
        'identityType': 'EMAIL',
        'maskedDestination': 'c***@domain.com',
        'expiresIn': 600,
        'resendCooldown': 60,
      };

      final model = SendResetOtpResultModel.fromJson(json);

      expect(model.identity, 'custom@domain.com');
      expect(model.identityType, 'EMAIL');
      expect(model.maskedDestination, 'c***@domain.com');
      expect(model.expiresIn, 600);
      expect(model.resendCooldown, 60);
    });
  });
}
