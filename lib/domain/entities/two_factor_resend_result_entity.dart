import 'package:equatable/equatable.dart';

class TwoFactorResendResultEntity extends Equatable {
  final String preAuthToken;
  final int resendCooldown;
  final String message;

  const TwoFactorResendResultEntity({
    required this.preAuthToken,
    this.resendCooldown = 60,
    this.message = 'Verification code resent successfully.',
  });

  @override
  List<Object?> get props => [preAuthToken, resendCooldown, message];
}
