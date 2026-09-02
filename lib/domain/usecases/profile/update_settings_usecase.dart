import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_settings_entity.dart';
import '../../repositories/profile_repository.dart';

class UpdateSettingsUseCase {
  final ProfileRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<Either<Failure, RiderSettingsEntity>> call({
    NotificationsSettingsEntity? notifications,
    NavigationSettingsEntity? navigation,
    AppPreferencesSettingsEntity? appPreferences,
    String? currentPassword,
    String? newPassword,
  }) {
    return repository.updateSettings(
      notifications: notifications,
      navigation: navigation,
      appPreferences: appPreferences,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
