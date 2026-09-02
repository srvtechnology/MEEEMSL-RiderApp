import 'package:equatable/equatable.dart';

class SendPhoneOtpResultEntity extends Equatable {
  final String phone;
  final int expiresIn;
  final int resendCooldown;

  const SendPhoneOtpResultEntity({
    required this.phone,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [phone, expiresIn, resendCooldown];
}
