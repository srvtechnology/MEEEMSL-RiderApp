import 'package:equatable/equatable.dart';

class NotificationsSettingsEntity extends Equatable {
  final bool orderAlerts;
  final bool promotionalAlerts;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationsSettingsEntity({
    this.orderAlerts = true,
    this.promotionalAlerts = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationsSettingsEntity copyWith({
    bool? orderAlerts,
    bool? promotionalAlerts,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationsSettingsEntity(
      orderAlerts: orderAlerts ?? this.orderAlerts,
      promotionalAlerts: promotionalAlerts ?? this.promotionalAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [orderAlerts, promotionalAlerts, soundEnabled, vibrationEnabled];
}

class NavigationSettingsEntity extends Equatable {
  final String defaultMapApp;
  final bool voiceGuidance;
  final bool avoidTolls;

  const NavigationSettingsEntity({
    this.defaultMapApp = 'GOOGLE_MAPS',
    this.voiceGuidance = true,
    this.avoidTolls = false,
  });

  NavigationSettingsEntity copyWith({
    String? defaultMapApp,
    bool? voiceGuidance,
    bool? avoidTolls,
  }) {
    return NavigationSettingsEntity(
      defaultMapApp: defaultMapApp ?? this.defaultMapApp,
      voiceGuidance: voiceGuidance ?? this.voiceGuidance,
      avoidTolls: avoidTolls ?? this.avoidTolls,
    );
  }

  @override
  List<Object?> get props => [defaultMapApp, voiceGuidance, avoidTolls];
}

class AppPreferencesSettingsEntity extends Equatable {
  final String theme;
  final String language;
  final String distanceUnit;

  const AppPreferencesSettingsEntity({
    this.theme = 'SYSTEM',
    this.language = 'en',
    this.distanceUnit = 'KM',
  });

  AppPreferencesSettingsEntity copyWith({
    String? theme,
    String? language,
    String? distanceUnit,
  }) {
    return AppPreferencesSettingsEntity(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      distanceUnit: distanceUnit ?? this.distanceUnit,
    );
  }

  @override
  List<Object?> get props => [theme, language, distanceUnit];
}

class RiderSettingsEntity extends Equatable {
  final NotificationsSettingsEntity notifications;
  final NavigationSettingsEntity navigation;
  final AppPreferencesSettingsEntity appPreferences;

  const RiderSettingsEntity({
    this.notifications = const NotificationsSettingsEntity(),
    this.navigation = const NavigationSettingsEntity(),
    this.appPreferences = const AppPreferencesSettingsEntity(),
  });

  RiderSettingsEntity copyWith({
    NotificationsSettingsEntity? notifications,
    NavigationSettingsEntity? navigation,
    AppPreferencesSettingsEntity? appPreferences,
  }) {
    return RiderSettingsEntity(
      notifications: notifications ?? this.notifications,
      navigation: navigation ?? this.navigation,
      appPreferences: appPreferences ?? this.appPreferences,
    );
  }

  @override
  List<Object?> get props => [notifications, navigation, appPreferences];
}
