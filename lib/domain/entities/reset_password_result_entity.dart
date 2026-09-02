import 'package:equatable/equatable.dart';

class SendResetOtpResultEntity extends Equatable {
  final String identity;
  final String identityType; // EMAIL or PHONE
  final String maskedDestination;
  final int expiresIn;
  final int resendCooldown;

  const SendResetOtpResultEntity({
    required this.identity,
    required this.identityType,
    required this.maskedDestination,
    this.expiresIn = 600,
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [
        identity,
        identityType,
        maskedDestination,
        expiresIn,
        resendCooldown,
      ];
}
