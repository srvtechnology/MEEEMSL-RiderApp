import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
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
import 'package:meeem_rider/presentation/modules/profile/controllers/profile_controller.dart';
import 'package:meeem_rider/presentation/modules/profile/views/profile_view.dart';
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

  const testRider = RiderEntity(
    id: 'rider-1',
    name: 'Test Rider',
    phone: '+1234567890',
    email: 'rider@example.com',
    avatar: '',
    isOnline: true,
    approvalStatus: 'approved',
    walletBalance: 120.0,
    totalTrips: 45,
    rating: 4.9,
  );

  const testSettings = RiderSettingsEntity(
    notifications: NotificationsSettingsEntity(
      orderAlerts: true,
      promotionalAlerts: true,
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
      theme: 'LIGHT',
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
          'google_fonts/Poppins-Regular.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Regular.ttf'}
          ],
          'google_fonts/Poppins-SemiBold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-SemiBold.ttf'}
          ],
          'google_fonts/Poppins-Bold.ttf': <Object?>[
            <String, Object?>{'asset': 'google_fonts/Poppins-Bold.ttf'}
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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );

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

    when(() => mockGetProfileUseCase()).thenAnswer((_) async => const Right(testRider));
    when(() => mockGetDocumentsUseCase()).thenAnswer((_) async => const Right(<DocumentEntity>[]));
    when(() => mockGetOperatingZonesUseCase()).thenAnswer((_) async => const Right(<OperatingZoneEntity>[]));
    when(() => mockGetPayoutInfoUseCase()).thenAnswer((_) async => const Right(null));
    when(() => mockGetSettingsUseCase()).thenAnswer((_) async => const Right(testSettings));

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

    controller.riderProfile.value = testRider;
    controller.riderSettings.value = testSettings;

    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('ProfileView renders with CustomCards and ListTiles without assertion error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: ProfileView(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Documents & Verification'), findsOneWidget);
    expect(find.text('Settings & Preferences'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('RiderSettingsView renders with CustomCards and ListTiles without assertion error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RiderSettingsView(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('Order & Dispatch Alerts'), findsOneWidget);
    expect(find.text('Default Navigation App'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
  });

  testWidgets('RiderSettingsView opens map app picker bottom sheet with ListTiles without assertion error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RiderSettingsView(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Default Navigation App'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Default Map App'), findsOneWidget);
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('Waze'), findsOneWidget);
    expect(find.text('Apple Maps'), findsOneWidget);
  });

  testWidgets('RiderSettingsView opens theme picker bottom sheet with ListTiles without assertion error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RiderSettingsView(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Theme Mode'), 100);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theme Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Theme Mode'), findsWidgets);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.text('Dark Mode'), findsWidgets);
    expect(find.text('Light Mode'), findsOneWidget);
  });
}
