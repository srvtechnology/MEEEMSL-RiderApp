import 'package:equatable/equatable.dart';
import 'user_entity.dart';
import 'rider_entity.dart';

class LoginResponseEntity extends Equatable {
  final UserEntity user;
  final RiderEntity rider;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const LoginResponseEntity({
    required this.user,
    required this.rider,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  @override
  List<Object?> get props => [user, rider, accessToken, refreshToken, expiresIn];
}
