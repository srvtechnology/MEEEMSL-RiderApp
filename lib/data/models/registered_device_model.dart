import '../../domain/entities/registered_device_entity.dart';

class RegisteredDeviceModel extends RegisteredDeviceEntity {
  const RegisteredDeviceModel({
    required super.token,
    required super.deviceId,
    super.platform = 'android',
    super.deviceModel = '',
    super.lastActiveAt,
    super.createdAt,
  });

  factory RegisteredDeviceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return RegisteredDeviceModel(
      token: json['token'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      platform: json['platform'] as String? ?? 'android',
      deviceModel: json['deviceModel'] as String? ?? '',
      lastActiveAt: parseDate(json['lastActiveAt']),
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'deviceId': deviceId,
      'platform': platform,
      'deviceModel': deviceModel,
      if (lastActiveAt != null) 'lastActiveAt': lastActiveAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory RegisteredDeviceModel.fromEntity(RegisteredDeviceEntity entity) {
    return RegisteredDeviceModel(
      token: entity.token,
      deviceId: entity.deviceId,
      platform: entity.platform,
      deviceModel: entity.deviceModel,
      lastActiveAt: entity.lastActiveAt,
      createdAt: entity.createdAt,
    );
  }
}
