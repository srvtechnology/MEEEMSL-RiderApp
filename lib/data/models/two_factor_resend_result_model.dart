import '../../domain/entities/two_factor_resend_result_entity.dart';

class TwoFactorResendResultModel extends TwoFactorResendResultEntity {
  const TwoFactorResendResultModel({
    required super.preAuthToken,
    super.resendCooldown = 60,
    super.message = 'Verification code resent successfully.',
  });

  factory TwoFactorResendResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return TwoFactorResendResultModel(
      preAuthToken: data['preAuthToken'] as String? ?? json['preAuthToken'] as String? ?? '',
      resendCooldown: data['resendCooldown'] as int? ?? json['resendCooldown'] as int? ?? 60,
      message: json['message'] as String? ?? 'Verification code resent successfully.',
    );
  }
}
