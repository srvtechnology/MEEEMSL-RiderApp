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
    super.requiresOtp = false,
    super.preAuthToken,
    super.maskedPhone,
    super.maskedEmail,
    super.channels = const [],
    super.resendCooldown = 60,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final preAuthToken = dataMap['preAuthToken'] as String? ?? json['preAuthToken'] as String?;
    final requiresOtp = json['requiresOtp'] == true || dataMap['requiresOtp'] == true || preAuthToken != null;

    final maskedPhone = dataMap['maskedPhone'] as String? ?? json['maskedPhone'] as String?;
    final maskedEmail = dataMap['maskedEmail'] as String? ?? json['maskedEmail'] as String?;
    final rawChannels = dataMap['channels'] as List? ?? json['channels'] as List?;
    final channels = rawChannels?.map((e) => e.toString()).toList() ?? <String>[];
    final resendCooldown = dataMap['resendCooldown'] as int? ?? json['resendCooldown'] as int? ?? 60;

    final userJson = dataMap['user'] as Map<String, dynamic>? ?? json['user'] as Map<String, dynamic>? ?? {};
    final riderProfile = userJson['riderProfile'] as Map<String, dynamic>? ?? {};
    final riderSource = dataMap['rider'] as Map<String, dynamic>? ?? json['rider'] as Map<String, dynamic>? ?? (riderProfile.isNotEmpty ? riderProfile : {});
    final riderJson = Map<String, dynamic>.from(riderSource);
    final tokensJson = dataMap['tokens'] as Map<String, dynamic>? ?? json['tokens'] as Map<String, dynamic>? ?? {};

    // Propagate onboarding status from root if present
    if (json.containsKey('onboardingCompleted') && !riderJson.containsKey('onboardingCompleted')) {
      riderJson['onboardingCompleted'] = json['onboardingCompleted'];
    }
    if (dataMap.containsKey('onboardingCompleted') && !riderJson.containsKey('onboardingCompleted')) {
      riderJson['onboardingCompleted'] = dataMap['onboardingCompleted'];
    }
    if (json.containsKey('isFirstLogin') && !riderJson.containsKey('isFirstLogin')) {
      riderJson['isFirstLogin'] = json['isFirstLogin'];
    }
    if (dataMap.containsKey('isFirstLogin') && !riderJson.containsKey('isFirstLogin')) {
      riderJson['isFirstLogin'] = dataMap['isFirstLogin'];
    }

    final user = userJson.isNotEmpty
        ? UserModel.fromJson(userJson)
        : const UserModel(id: '', name: '', phone: '');

    final rider = riderJson.isNotEmpty
        ? RiderModel.fromJson(riderJson, userJson)
        : const RiderModel(
            id: '',
            name: '',
            phone: '',
            email: '',
            avatar: '',
            rating: 0,
            totalTrips: 0,
            isOnline: false,
            walletBalance: 0,
            approvalStatus: '',
          );

    final accessToken = tokensJson['accessToken'] as String? ?? dataMap['token'] as String? ?? json['token'] as String? ?? '';
    final refreshToken = tokensJson['refreshToken'] as String? ?? dataMap['refreshToken'] as String? ?? json['refreshToken'] as String? ?? '';
    final expiresIn = tokensJson['expiresIn'] as int? ?? dataMap['expiresIn'] as int? ?? json['expiresIn'] as int? ?? 172800;

    return LoginResponseModel(
      user: user,
      rider: rider,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      requiresOtp: requiresOtp,
      preAuthToken: preAuthToken,
      maskedPhone: maskedPhone,
      maskedEmail: maskedEmail,
      channels: channels,
      resendCooldown: resendCooldown,
    );
  }
}
