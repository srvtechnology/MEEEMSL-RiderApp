import '../../domain/entities/rider_settings_entity.dart';
import 'user_model.dart';
import 'rider_model.dart';
import 'registered_device_model.dart';

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

class RiderStatsModel extends RiderStatsEntity {
  const RiderStatsModel({
    super.totalEarnings = 0.0,
    super.completedDeliveriesCount = 0,
    super.activeDeliveriesCount = 0,
  });

  factory RiderStatsModel.fromJson(Map<String, dynamic> json) {
    return RiderStatsModel(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      completedDeliveriesCount: (json['completedDeliveriesCount'] as num?)?.toInt() ?? 0,
      activeDeliveriesCount: (json['activeDeliveriesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'completedDeliveriesCount': completedDeliveriesCount,
      'activeDeliveriesCount': activeDeliveriesCount,
    };
  }

  factory RiderStatsModel.fromEntity(RiderStatsEntity entity) {
    return RiderStatsModel(
      totalEarnings: entity.totalEarnings,
      completedDeliveriesCount: entity.completedDeliveriesCount,
      activeDeliveriesCount: entity.activeDeliveriesCount,
    );
  }
}

/// Conforms to MEEEM Delivery Network — Rider Mobile App API Doc (Part 1 & Part 3)
/// Section 7: Rider Settings & Preferences (7.1 Get Full Settings)
/// Part 3 Section 4.1: Rider Dashboard & Earnings API (stats)
class RiderSettingsModel extends RiderSettingsEntity {
  const RiderSettingsModel({
    super.user,
    super.rider,
    super.registeredDevices = const [],
    super.notifications = const NotificationsSettingsModel(),
    super.navigation = const NavigationSettingsModel(),
    super.appPreferences = const AppPreferencesSettingsModel(),
    super.stats,
  });

  factory RiderSettingsModel.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    }

    RiderModel? rider;
    if (json['rider'] != null && json['rider'] is Map<String, dynamic>) {
      final userJson = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
      rider = RiderModel.fromJson(json['rider'] as Map<String, dynamic>, userJson);
    }

    List<RegisteredDeviceModel> registeredDevices = [];
    if (json['registeredDevices'] != null && json['registeredDevices'] is List) {
      registeredDevices = (json['registeredDevices'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RegisteredDeviceModel.fromJson(e))
          .toList();
    }

    final notifs = json['notifications'] != null
        ? NotificationsSettingsModel.fromJson(json['notifications'] as Map<String, dynamic>)
        : const NotificationsSettingsModel();

    final nav = json['navigation'] != null
        ? NavigationSettingsModel.fromJson(json['navigation'] as Map<String, dynamic>)
        : const NavigationSettingsModel();

    final prefs = json['appPreferences'] != null
        ? AppPreferencesSettingsModel.fromJson(json['appPreferences'] as Map<String, dynamic>)
        : const AppPreferencesSettingsModel();

    final stats = json['stats'] != null && json['stats'] is Map<String, dynamic>
        ? RiderStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
        : null;

    return RiderSettingsModel(
      user: user,
      rider: rider,
      registeredDevices: registeredDevices,
      notifications: notifs,
      navigation: nav,
      appPreferences: prefs,
      stats: stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (user != null)
        'user': (user is UserModel ? user as UserModel : UserModel.fromEntity(user!)).toJson(),
      if (rider != null)
        'rider': (rider is RiderModel ? rider as RiderModel : RiderModel.fromEntity(rider!)).toJson(),
      'registeredDevices': registeredDevices
          .map((d) => (d is RegisteredDeviceModel ? d : RegisteredDeviceModel.fromEntity(d)).toJson())
          .toList(),
      'notifications': NotificationsSettingsModel.fromEntity(notifications).toJson(),
      'navigation': NavigationSettingsModel.fromEntity(navigation).toJson(),
      'appPreferences': AppPreferencesSettingsModel.fromEntity(appPreferences).toJson(),
      if (stats != null)
        'stats': (stats is RiderStatsModel ? stats as RiderStatsModel : RiderStatsModel.fromEntity(stats!)).toJson(),
    };
  }

  factory RiderSettingsModel.fromEntity(RiderSettingsEntity entity) {
    return RiderSettingsModel(
      user: entity.user,
      rider: entity.rider,
      registeredDevices: entity.registeredDevices,
      notifications: entity.notifications,
      navigation: entity.navigation,
      appPreferences: entity.appPreferences,
      stats: entity.stats != null ? RiderStatsModel.fromEntity(entity.stats!) : null,
    );
  }
}
