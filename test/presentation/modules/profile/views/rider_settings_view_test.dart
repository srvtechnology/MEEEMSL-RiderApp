import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
import 'package:meeem_rider/domain/entities/registered_device_entity.dart';
import 'package:meeem_rider/domain/entities/rider_settings_entity.dart';
import 'package:meeem_rider/domain/entities/document_entity.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';
import 'package:meeem_rider/domain/usecases/profile/get_profile_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_profile_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_documents_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/upload_document_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_operating_zones_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_operating_zones_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_payout_info_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_payout_info_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_vehicle_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_settings_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_settings_usecase.dart';
import 'package:meeem_rider/core/widgets/custom_button.dart';
import 'package:meeem_rider/presentation/modules/profile/controllers/profile_controller.dart';
import 'package:meeem_rider/presentation/modules/profile/views/rider_settings_view.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockGetDocumentsUseCase extends Mock implements GetDocumentsUseCase {}
class MockUploadDocumentUseCase extends Mock implements UploadDocumentUseCase {}
class MockGetOperatingZonesUseCase extends Mock implements GetOperatingZonesUseCase {}
class MockUpdateOperatingZonesUseCase extends Mock implements UpdateOperatingZonesUseCase {}
class MockGetPayoutInfoUseCase extends Mock implements GetPayoutInfoUseCase {}
class MockUpdatePayoutInfoUseCase extends Mock implements UpdatePayoutInfoUseCase {}
class MockUpdateVehicleUseCase extends Mock implements UpdateVehicleUseCase {}
class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}
class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late ProfileController controller;
  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockGetDocumentsUseCase mockGetDocumentsUseCase;
  late MockUploadDocumentUseCase mockUploadDocumentUseCase;
  late MockGetOperatingZonesUseCase mockGetOperatingZonesUseCase;
  late MockUpdateOperatingZonesUseCase mockUpdateOperatingZonesUseCase;
  late MockGetPayoutInfoUseCase mockGetPayoutInfoUseCase;
  late MockUpdatePayoutInfoUseCase mockUpdatePayoutInfoUseCase;
  late MockUpdateVehicleUseCase mockUpdateVehicleUseCase;
  late MockGetSettingsUseCase mockGetSettingsUseCase;
  late MockUpdateSettingsUseCase mockUpdateSettingsUseCase;

  const tRider = RiderEntity(
    id: 'cm7rider0001',
    name: 'Ibrahim Koroma',
    phone: '76123456',
    email: 'rider.ibrahim@example.com',
    avatar: '',
    isOnline: true,
    approvalStatus: 'approved',
    status: 'APPROVED',
    walletBalance: 120.0,
    totalTrips: 45,
    rating: 4.9,
    selectedZones: ['ZONE 1', 'ZONE 2'],
    selectedLocations: ['NO 2 RIVER', 'BAW BAW', 'HAMILTON', 'LAKKA'],
  );

  const tFullSettings = RiderSettingsEntity(
    user: UserEntity(
      id: 'cm7abc123000',
      email: 'rider.ibrahim@example.com',
      name: 'Ibrahim Koroma',
      phone: '76123456',
      phoneCountryCode: '+232',
      isEmailVerified: true,
    ),
    rider: tRider,
    registeredDevices: [
      RegisteredDeviceEntity(
        token: 'fcm_token_123',
        deviceId: 'android-uuid-1',
        platform: 'android',
        deviceModel: 'Samsung Galaxy S22',
      ),
      RegisteredDeviceEntity(
        token: 'fcm_token_456',
        deviceId: 'iphone-uuid-2',
        platform: 'ios',
        deviceModel: 'iPhone 15 Pro',
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
      distanceUnit: 'KM',
      theme: 'SYSTEM',
    ),
  );

  setUp(() {
    Get.testMode = true;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (key == 'AssetManifest.bin' || key == 'AssetManifest.bin.json') {
        final manifest = <String, List<Object?>>{
          'google_fonts/Inter-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Regular.ttf'}
          ],
          'google_fonts/Inter-Medium.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Medium.ttf'}
          ],
          'google_fonts/Inter-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-SemiBold.ttf'}
          ],
          'google_fonts/Inter-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Inter-Bold.ttf'}
          ],
        };
        return const StandardMessageCodec().encodeMessage(manifest);
      }
      if (key == 'AssetManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
      }
      if (key == 'FontManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
      }
      if (key.endsWith('.ttf')) {
        return ByteData.view(Uint8List.fromList(_fontBytes).buffer);
      }
      return null;
    });

    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockGetDocumentsUseCase = MockGetDocumentsUseCase();
    mockUploadDocumentUseCase = MockUploadDocumentUseCase();
    mockGetOperatingZonesUseCase = MockGetOperatingZonesUseCase();
    mockUpdateOperatingZonesUseCase = MockUpdateOperatingZonesUseCase();
    mockGetPayoutInfoUseCase = MockGetPayoutInfoUseCase();
    mockUpdatePayoutInfoUseCase = MockUpdatePayoutInfoUseCase();
    mockUpdateVehicleUseCase = MockUpdateVehicleUseCase();
    mockGetSettingsUseCase = MockGetSettingsUseCase();
    mockUpdateSettingsUseCase = MockUpdateSettingsUseCase();

    when(() => mockGetProfileUseCase()).thenAnswer((_) async => const Right(tRider));
    when(() => mockGetDocumentsUseCase()).thenAnswer((_) async => const Right(<DocumentEntity>[]));
    when(() => mockGetOperatingZonesUseCase()).thenAnswer((_) async => const Right(<OperatingZoneEntity>[]));
    when(() => mockGetPayoutInfoUseCase()).thenAnswer((_) async => const Right(null));
    when(() => mockGetSettingsUseCase()).thenAnswer((_) async => const Right(tFullSettings));

    controller = ProfileController(
      getProfileUseCase: mockGetProfileUseCase,
      updateProfileUseCase: mockUpdateProfileUseCase,
      getDocumentsUseCase: mockGetDocumentsUseCase,
      uploadDocumentUseCase: mockUploadDocumentUseCase,
      getOperatingZonesUseCase: mockGetOperatingZonesUseCase,
      updateOperatingZonesUseCase: mockUpdateOperatingZonesUseCase,
      getPayoutInfoUseCase: mockGetPayoutInfoUseCase,
      updatePayoutInfoUseCase: mockUpdatePayoutInfoUseCase,
      updateVehicleUseCase: mockUpdateVehicleUseCase,
      getSettingsUseCase: mockGetSettingsUseCase,
      updateSettingsUseCase: mockUpdateSettingsUseCase,
    );

    controller.riderProfile.value = tRider;
    controller.riderSettings.value = tFullSettings;
    controller.currentDeviceId.value = 'android-uuid-1';

    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('RiderSettingsView renders full 7.1 information and registered devices', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RiderSettingsView(),
      ),
    );

    await tester.pumpAndSettle();

    // Check Section 7.1 Account & Verification Overview
    expect(find.text('Account & Verification'), findsOneWidget);
    expect(find.text('Ibrahim Koroma'), findsOneWidget);
    expect(find.text('rider.ibrahim@example.com'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);

    // Check Delivery Coverage & Zones
    expect(find.text('Delivery Coverage & Zones'), findsOneWidget);
    expect(find.text('ZONE 1'), findsOneWidget);
    expect(find.text('ZONE 2'), findsOneWidget);

    // Check Registered Devices & Push Sessions
    await tester.scrollUntilVisible(
      find.text('Active Devices & Push Sessions'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Active Devices & Push Sessions'), findsOneWidget);
    expect(find.text('Samsung Galaxy S22'), findsOneWidget);
    expect(find.text('iPhone 15 Pro'), findsOneWidget);
    expect(find.text('THIS DEVICE'), findsOneWidget);
  });

  testWidgets('RiderSettingsView opens Change Password dialog conforming to 7.2', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RiderSettingsView(),
      ),
    );

    await tester.pumpAndSettle();

    final changePasswordTile = find.text('Change Password');
    expect(changePasswordTile, findsOneWidget);

    await tester.tap(changePasswordTile);
    await tester.pumpAndSettle();

    // Verify change password dialog opened
    expect(find.text('Change Account Password'), findsOneWidget);
    expect(find.text('Current Password'), findsOneWidget);
    expect(find.text('New Password (min 6 characters)'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(find.widgetWithText(CustomButton, 'Update Password'), findsOneWidget);
  });
}
