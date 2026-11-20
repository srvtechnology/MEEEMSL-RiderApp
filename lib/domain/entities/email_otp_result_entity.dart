import 'package:equatable/equatable.dart';

class SendEmailOtpResultEntity extends Equatable {
  final String email;
  final int expiresIn;
  final int resendCooldown;

  const SendEmailOtpResultEntity({
    required this.email,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [email, expiresIn, resendCooldown];
}
