import '../../domain/entities/reset_password_result_entity.dart';

class SendResetOtpResultModel extends SendResetOtpResultEntity {
  const SendResetOtpResultModel({
    required super.identity,
    required super.identityType,
    required super.maskedDestination,
    super.expiresIn,
    super.resendCooldown,
  });

  factory SendResetOtpResultModel.fromJson(Map<String, dynamic> json) {
    return SendResetOtpResultModel(
      identity: json['identity'] as String? ?? '',
      identityType: json['identityType'] as String? ?? 'EMAIL',
      maskedDestination: json['maskedDestination'] as String? ?? json['identity'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? 60,
    );
  }
}
