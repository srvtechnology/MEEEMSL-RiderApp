import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_settings_entity.dart';
import 'package:meeem_rider/domain/entities/registered_device_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/repositories/profile_repository.dart';
import 'package:meeem_rider/domain/usecases/profile/get_settings_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_settings_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late GetSettingsUseCase getSettingsUseCase;
  late UpdateSettingsUseCase updateSettingsUseCase;

  const tFullSettings = RiderSettingsEntity(
    user: UserEntity(
      id: 'cm7abc123000',
      email: 'rider.ibrahim@example.com',
      name: 'Ibrahim Koroma',
      phone: '76123456',
    ),
    rider: RiderEntity(
      id: 'cm7rider0001',
      name: 'Ibrahim Koroma',
      phone: '76123456',
      email: 'rider.ibrahim@example.com',
      avatar: '',
      rating: 5.0,
      totalTrips: 0,
      isOnline: true,
      walletBalance: 0.0,
      approvalStatus: 'approved',
      selectedZones: ['ZONE 1', 'ZONE 2'],
      selectedLocations: ['NO 2 RIVER', 'BAW BAW'],
    ),
    registeredDevices: [
      RegisteredDeviceEntity(
        token: 'fcm_token_123',
        deviceId: 'android-uuid-1',
        platform: 'android',
        deviceModel: 'Samsung Galaxy S22',
      ),
    ],
    notifications: NotificationsSettingsEntity(
      orderAlerts: true,
      promotionalAlerts: false,
      soundEnabled: true,
      vibrationEnabled: true,
    ),
    navigation: NavigationSettingsEntity(
      defaultMapApp: 'GOOGLE_MAPS',
      voiceGuidance: true,
      avoidTolls: false,
    ),
    appPreferences: AppPreferencesSettingsEntity(
      theme: 'SYSTEM',
      language: 'en',
      distanceUnit: 'KM',
    ),
  );

  setUp(() {
    mockRepository = MockProfileRepository();
    getSettingsUseCase = GetSettingsUseCase(mockRepository);
    updateSettingsUseCase = UpdateSettingsUseCase(mockRepository);
  });

  group('Section 7: Rider Settings & Preferences UseCases Tests', () {
    test('7.1 GetSettingsUseCase returns full settings including user, rider & devices', () async {
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const Right(tFullSettings));

      final result = await getSettingsUseCase();

      expect(result, const Right(tFullSettings));
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (settings) {
          expect(settings.user?.name, 'Ibrahim Koroma');
          expect(settings.rider?.selectedZones, ['ZONE 1', 'ZONE 2']);
          expect(settings.registeredDevices.length, 1);
          expect(settings.registeredDevices.first.deviceId, 'android-uuid-1');
        },
      );
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('7.2 UpdateSettingsUseCase updates password and coverage zones/locations', () async {
      when(() => mockRepository.updateSettings(
            currentPassword: 'OldPassword123!',
            newPassword: 'NewSecurePassword456!',
            selectedZones: ['ZONE 1', 'ZONE 2', 'ZONE 3'],
            selectedLocations: ['NO 2 RIVER', 'BAW BAW', 'LAKKA'],
          )).thenAnswer((_) async => const Right(tFullSettings));

      final result = await updateSettingsUseCase(
        currentPassword: 'OldPassword123!',
        newPassword: 'NewSecurePassword456!',
        selectedZones: ['ZONE 1', 'ZONE 2', 'ZONE 3'],
        selectedLocations: ['NO 2 RIVER', 'BAW BAW', 'LAKKA'],
      );

      expect(result, const Right(tFullSettings));
      verify(() => mockRepository.updateSettings(
            currentPassword: 'OldPassword123!',
            newPassword: 'NewSecurePassword456!',
            selectedZones: ['ZONE 1', 'ZONE 2', 'ZONE 3'],
            selectedLocations: ['NO 2 RIVER', 'BAW BAW', 'LAKKA'],
          )).called(1);
    });
  });
}
