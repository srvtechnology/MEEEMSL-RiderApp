import '../../domain/entities/login_response_entity.dart';
import 'user_model.dart';
import 'rider_model.dart';

class LoginResponseModel extends LoginResponseEntity {
  const LoginResponseModel({
    required super.user,
    required super.rider,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final riderJson = Map<String, dynamic>.from(json['rider'] as Map<String, dynamic>? ?? {});
    final tokensJson = json['tokens'] as Map<String, dynamic>? ?? {};

    // Propagate onboarding status from root if present
    if (json.containsKey('onboardingCompleted') && !riderJson.containsKey('onboardingCompleted')) {
      riderJson['onboardingCompleted'] = json['onboardingCompleted'];
    }
    if (json.containsKey('isFirstLogin') && !riderJson.containsKey('isFirstLogin')) {
      riderJson['isFirstLogin'] = json['isFirstLogin'];
    }

    return LoginResponseModel(
      user: UserModel.fromJson(userJson),
      rider: RiderModel.fromJson(riderJson),
      accessToken: tokensJson['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: tokensJson['refreshToken'] as String? ?? json['refreshToken'] as String? ?? '',
      expiresIn: tokensJson['expiresIn'] as int? ?? 172800,
    );
  }
}
