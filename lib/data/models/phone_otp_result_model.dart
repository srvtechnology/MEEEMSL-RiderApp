import '../../domain/entities/phone_otp_result_entity.dart';

class SendPhoneOtpResultModel extends SendPhoneOtpResultEntity {
  const SendPhoneOtpResultModel({
    required super.phone,
    super.expiresIn,
    super.resendCooldown,
  });

  factory SendPhoneOtpResultModel.fromJson(Map<String, dynamic> json) {
    return SendPhoneOtpResultModel(
      phone: json['phone'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? 60,
    );
  }
}
