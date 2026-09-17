import 'package:equatable/equatable.dart';

class RegistrationResultEntity extends Equatable {
  final String userId;
  final String email;
  final String phone;
  final String name;
  final String role;
  final bool requiresVerification;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? verifyUrl;
  final int expiresIn;
  final int resendCooldown;

  const RegistrationResultEntity({
    required this.userId,
    this.email = '',
    this.phone = '',
    this.name = '',
    this.role = 'RIDER',
    this.requiresVerification = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.verifyUrl,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        phone,
        name,
        role,
        requiresVerification,
        isEmailVerified,
        isPhoneVerified,
        verifyUrl,
        expiresIn,
        resendCooldown,
      ];
}

class VerifyRegistrationResultEntity extends Equatable {
  final String email;
  final String phone;
  final bool isEmailVerified;
  final bool loginAvailable;
  final bool onboardingCompleted;

  const VerifyRegistrationResultEntity({
    this.email = '',
    this.phone = '',
    required this.isEmailVerified,
    required this.loginAvailable,
    required this.onboardingCompleted,
  });

  @override
  List<Object?> get props => [email, phone, isEmailVerified, loginAvailable, onboardingCompleted];
}

class ResendOtpResultEntity extends Equatable {
  final String email;
  final String phone;
  final int expiresIn;
  final int resendCooldown;

  const ResendOtpResultEntity({
    this.email = '',
    this.phone = '',
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [email, phone, expiresIn, resendCooldown];
}
