import 'package:equatable/equatable.dart';

class RegisteredDeviceEntity extends Equatable {
  final String token;
  final String deviceId;
  final String platform;
  final String deviceModel;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const RegisteredDeviceEntity({
    required this.token,
    required this.deviceId,
    this.platform = 'android',
    this.deviceModel = '',
    this.lastActiveAt,
    this.createdAt,
  });

  RegisteredDeviceEntity copyWith({
    String? token,
    String? deviceId,
    String? platform,
    String? deviceModel,
    DateTime? lastActiveAt,
    DateTime? createdAt,
  }) {
    return RegisteredDeviceEntity(
      token: token ?? this.token,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      deviceModel: deviceModel ?? this.deviceModel,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        token,
        deviceId,
        platform,
        deviceModel,
        lastActiveAt,
        createdAt,
      ];
}
