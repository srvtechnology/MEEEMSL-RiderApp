import 'package:equatable/equatable.dart';

class RegistrationResultEntity extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String role;
  final bool requiresVerification;
  final int expiresIn;
  final int resendCooldown;

  const RegistrationResultEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.requiresVerification,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        role,
        requiresVerification,
        expiresIn,
        resendCooldown,
      ];
}

class VerifyRegistrationResultEntity extends Equatable {
  final String email;
  final bool isEmailVerified;
  final bool loginAvailable;
  final bool onboardingCompleted;

  const VerifyRegistrationResultEntity({
    required this.email,
    required this.isEmailVerified,
    required this.loginAvailable,
    required this.onboardingCompleted,
  });

  @override
  List<Object?> get props => [email, isEmailVerified, loginAvailable, onboardingCompleted];
}

class ResendOtpResultEntity extends Equatable {
  final String email;
  final int expiresIn;
  final int resendCooldown;

  const ResendOtpResultEntity({
    required this.email,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [email, expiresIn, resendCooldown];
}
