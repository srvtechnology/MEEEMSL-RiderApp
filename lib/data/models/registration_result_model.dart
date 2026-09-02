import '../../domain/entities/registration_result_entity.dart';

class RegistrationResultModel extends RegistrationResultEntity {
  const RegistrationResultModel({
    required super.userId,
    required super.email,
    required super.name,
    required super.role,
    required super.requiresVerification,
    super.expiresIn,
    super.resendCooldown,
  });

  factory RegistrationResultModel.fromJson(Map<String, dynamic> json) {
    final verificationDetails = json['verificationDetails'] as Map<String, dynamic>?;

    return RegistrationResultModel(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'RIDER',
      requiresVerification: json['requiresVerification'] as bool? ?? true,
      expiresIn: verificationDetails?['expiresIn'] as int? ?? 600,
      resendCooldown: verificationDetails?['resendCooldown'] as int? ?? 60,
    );
  }
}

class VerifyRegistrationResultModel extends VerifyRegistrationResultEntity {
  const VerifyRegistrationResultModel({
    required super.email,
    required super.isEmailVerified,
    required super.loginAvailable,
    required super.onboardingCompleted,
  });

  factory VerifyRegistrationResultModel.fromJson(Map<String, dynamic> json) {
    return VerifyRegistrationResultModel(
      email: json['email'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
      loginAvailable: json['loginAvailable'] as bool? ?? true,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}

class ResendOtpResultModel extends ResendOtpResultEntity {
  const ResendOtpResultModel({
    required super.email,
    super.expiresIn,
    super.resendCooldown,
  });

  factory ResendOtpResultModel.fromJson(Map<String, dynamic> json) {
    return ResendOtpResultModel(
      email: json['email'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 600,
      resendCooldown: json['resendCooldown'] as int? ?? 60,
    );
  }
}
