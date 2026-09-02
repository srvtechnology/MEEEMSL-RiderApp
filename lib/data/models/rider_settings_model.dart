import '../../domain/entities/rider_settings_entity.dart';

class NotificationsSettingsModel extends NotificationsSettingsEntity {
  const NotificationsSettingsModel({
    super.orderAlerts = true,
    super.promotionalAlerts = false,
    super.soundEnabled = true,
    super.vibrationEnabled = true,
  });

  factory NotificationsSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsSettingsModel(
      orderAlerts: json['orderAlerts'] as bool? ?? true,
      promotionalAlerts: json['promotionalAlerts'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderAlerts': orderAlerts,
      'promotionalAlerts': promotionalAlerts,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationsSettingsModel.fromEntity(NotificationsSettingsEntity entity) {
    return NotificationsSettingsModel(
      orderAlerts: entity.orderAlerts,
      promotionalAlerts: entity.promotionalAlerts,
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
    );
  }
}

class NavigationSettingsModel extends NavigationSettingsEntity {
  const NavigationSettingsModel({
    super.defaultMapApp = 'GOOGLE_MAPS',
    super.voiceGuidance = true,
    super.avoidTolls = false,
  });

  factory NavigationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NavigationSettingsModel(
      defaultMapApp: json['defaultMapApp'] as String? ?? 'GOOGLE_MAPS',
      voiceGuidance: json['voiceGuidance'] as bool? ?? true,
      avoidTolls: json['avoidTolls'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultMapApp': defaultMapApp,
      'voiceGuidance': voiceGuidance,
      'avoidTolls': avoidTolls,
    };
  }

  factory NavigationSettingsModel.fromEntity(NavigationSettingsEntity entity) {
    return NavigationSettingsModel(
      defaultMapApp: entity.defaultMapApp,
      voiceGuidance: entity.voiceGuidance,
      avoidTolls: entity.avoidTolls,
    );
  }
}

class AppPreferencesSettingsModel extends AppPreferencesSettingsEntity {
  const AppPreferencesSettingsModel({
    super.theme = 'SYSTEM',
    super.language = 'en',
    super.distanceUnit = 'KM',
  });

  factory AppPreferencesSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppPreferencesSettingsModel(
      theme: json['theme'] as String? ?? 'SYSTEM',
      language: json['language'] as String? ?? 'en',
      distanceUnit: json['distanceUnit'] as String? ?? 'KM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'distanceUnit': distanceUnit,
    };
  }

  factory AppPreferencesSettingsModel.fromEntity(AppPreferencesSettingsEntity entity) {
    return AppPreferencesSettingsModel(
      theme: entity.theme,
      language: entity.language,
      distanceUnit: entity.distanceUnit,
    );
  }
}

class RiderSettingsModel extends RiderSettingsEntity {
  const RiderSettingsModel({
    super.notifications = const NotificationsSettingsModel(),
    super.navigation = const NavigationSettingsModel(),
    super.appPreferences = const AppPreferencesSettingsModel(),
  });

  factory RiderSettingsModel.fromJson(Map<String, dynamic> json) {
    return RiderSettingsModel(
      notifications: json['notifications'] != null
          ? NotificationsSettingsModel.fromJson(json['notifications'] as Map<String, dynamic>)
          : const NotificationsSettingsModel(),
      navigation: json['navigation'] != null
          ? NavigationSettingsModel.fromJson(json['navigation'] as Map<String, dynamic>)
          : const NavigationSettingsModel(),
      appPreferences: json['appPreferences'] != null
          ? AppPreferencesSettingsModel.fromJson(json['appPreferences'] as Map<String, dynamic>)
          : const AppPreferencesSettingsModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': NotificationsSettingsModel.fromEntity(notifications).toJson(),
      'navigation': NavigationSettingsModel.fromEntity(navigation).toJson(),
      'appPreferences': AppPreferencesSettingsModel.fromEntity(appPreferences).toJson(),
    };
  }

  factory RiderSettingsModel.fromEntity(RiderSettingsEntity entity) {
    return RiderSettingsModel(
      notifications: entity.notifications,
      navigation: entity.navigation,
      appPreferences: entity.appPreferences,
    );
  }
}
