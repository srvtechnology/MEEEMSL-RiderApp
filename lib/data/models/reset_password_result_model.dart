import '../../domain/entities/reset_password_result_entity.dart';

class SendResetOtpResultModel extends SendResetOtpResultEntity {
  const SendResetOtpResultModel({
    required super.identity,
    required super.identityType,
    required super.maskedDestination,
    super.email,
    super.phone,
    super.expiresIn,
    super.resendCooldown,
  });

  factory SendResetOtpResultModel.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String?;
    final phone = json['phone'] as String?;
    final rawIdentity = json['identity'] as String? ?? json['identifier'] as String? ?? email ?? phone ?? '';
    final isEmail = rawIdentity.contains('@');
    final identityType = json['identityType'] as String? ?? (isEmail ? 'EMAIL' : 'PHONE');

    String destination = json['maskedDestination'] as String? ?? '';
    if (destination.isEmpty) {
      if (email != null && phone != null) {
        destination = '$email & $phone';
      } else {
        destination = email ?? phone ?? rawIdentity;
      }
    }

    return SendResetOtpResultModel(
      identity: rawIdentity,
      identityType: identityType,
      maskedDestination: destination,
      email: email,
      phone: phone,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 600,
      resendCooldown: (json['resendCooldown'] as num?)?.toInt() ?? 60,
    );
  }
}
