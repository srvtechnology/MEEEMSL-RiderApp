import '../../domain/entities/email_otp_result_entity.dart';

class SendEmailOtpResultModel extends SendEmailOtpResultEntity {
  const SendEmailOtpResultModel({
    required super.email,
    super.expiresIn,
    super.resendCooldown,
  });

  factory SendEmailOtpResultModel.fromJson(Map<String, dynamic> json) {
    return SendEmailOtpResultModel(
      email: json['email'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? 60,
    );
  }
}
