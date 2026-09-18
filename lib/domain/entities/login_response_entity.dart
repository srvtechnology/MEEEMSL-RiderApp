import 'package:equatable/equatable.dart';
import 'user_entity.dart';
import 'rider_entity.dart';

class LoginResponseEntity extends Equatable {
  final UserEntity user;
  final RiderEntity rider;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  // 2FA Challenge Fields
  final bool requiresOtp;
  final String? preAuthToken;
  final String? maskedPhone;
  final String? maskedEmail;
  final List<String> channels;
  final int resendCooldown;

  const LoginResponseEntity({
    required this.user,
    required this.rider,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.requiresOtp = false,
    this.preAuthToken,
    this.maskedPhone,
    this.maskedEmail,
    this.channels = const [],
    this.resendCooldown = 60,
  });

  @override
  List<Object?> get props => [
        user,
        rider,
        accessToken,
        refreshToken,
        expiresIn,
        requiresOtp,
        preAuthToken,
        maskedPhone,
        maskedEmail,
        channels,
        resendCooldown,
      ];
}
