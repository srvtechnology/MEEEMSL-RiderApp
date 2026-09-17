import '../../domain/entities/registration_result_entity.dart';

class RegistrationResultModel extends RegistrationResultEntity {
  const RegistrationResultModel({
    required super.userId,
    super.email = '',
    super.phone = '',
    super.name = '',
    super.role = 'RIDER',
    super.requiresVerification = true,
    super.isEmailVerified = false,
    super.isPhoneVerified = false,
    super.verifyUrl,
    super.expiresIn = 600,
    super.resendCooldown = 60,
  });

  factory RegistrationResultModel.fromJson(Map<String, dynamic> json) {
    final verificationDetails = json['verificationDetails'] as Map<String, dynamic>?;

    return RegistrationResultModel(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'RIDER',
      requiresVerification: json['requiresVerification'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      verifyUrl: json['verifyUrl'] as String?,
      expiresIn: json['expiresIn'] as int? ?? verificationDetails?['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? verificationDetails?['resendCooldown'] as int? ?? 60,
    );
  }
}

class VerifyRegistrationResultModel extends VerifyRegistrationResultEntity {
  const VerifyRegistrationResultModel({
    super.email = '',
    super.phone = '',
    required super.isEmailVerified,
    required super.loginAvailable,
    required super.onboardingCompleted,
  });

  factory VerifyRegistrationResultModel.fromJson(Map<String, dynamic> json) {
    return VerifyRegistrationResultModel(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
      loginAvailable: json['loginAvailable'] as bool? ?? true,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}

class ResendOtpResultModel extends ResendOtpResultEntity {
  const ResendOtpResultModel({
    super.email = '',
    super.phone = '',
    super.expiresIn = 600,
    super.resendCooldown = 60,
  });

  factory ResendOtpResultModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpResultModel(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? 60,
    );
  }
}
