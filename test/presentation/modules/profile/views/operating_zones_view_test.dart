import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';
import 'package:meeem_rider/domain/entities/document_entity.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';
import 'package:meeem_rider/domain/entities/rider_settings_entity.dart';
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
import 'package:meeem_rider/presentation/modules/profile/views/operating_zones_view.dart';

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

  const tZones = [
    OperatingZoneEntity(
      id: 'ZONE 1',
      name: 'ZONE 1 (Western Rural)',
      description: 'Outer Western Area',
      locations: [
        DeliveryLocationEntity(id: 'NO 2 RIVER', zoneId: 'ZONE 1', name: 'NO 2 RIVER'),
        DeliveryLocationEntity(id: 'BAW BAW', zoneId: 'ZONE 1', name: 'BAW BAW'),
      ],
    ),
    OperatingZoneEntity(
      id: 'ZONE 2',
      name: 'ZONE 2 (Peninsula Area)',
      description: 'Peninsula coastal corridor',
      locations: [
        DeliveryLocationEntity(id: 'HAMILTON', zoneId: 'ZONE 2', name: 'HAMILTON'),
        DeliveryLocationEntity(id: 'LAKKA', zoneId: 'ZONE 2', name: 'LAKKA'),
      ],
    ),
  ];

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
    selectedZones: ['ZONE 1'],
    selectedLocations: ['NO 2 RIVER'],
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

    when(() => mockGetProfileUseCase()).thenAnswer((_) async => const Right(tRider));
    when(() => mockGetDocumentsUseCase()).thenAnswer((_) async => const Right(<DocumentEntity>[]));
    when(() => mockGetOperatingZonesUseCase()).thenAnswer((_) async => const Right(tZones));
    when(() => mockGetPayoutInfoUseCase()).thenAnswer((_) async => const Right(PayoutInfoEntity(methodType: PayoutMethodType.bank)));
    when(() => mockGetSettingsUseCase()).thenAnswer((_) async => const Right(RiderSettingsEntity(rider: tRider)));

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
    controller.operatingZones.assignAll(tZones);
    controller.syncOperatingZonesWithProfile();
    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('OperatingZonesView renders with dynamically loaded zones and pre-selects zones & locations matching riderProfile', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: OperatingZonesView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and header
    expect(find.text('Preferred Operating Zones'), findsOneWidget);
    expect(find.text('Delivery Zones & Hierarchical Locations'), findsOneWidget);

    // Verify coverage summary counter shows 1 of 2 zones, 1 region selected
    expect(find.text('1 of 2 Zones • 1 Regions Selected'), findsOneWidget);

    // Verify zone names
    expect(find.text('ZONE 1 (Western Rural)'), findsOneWidget);
    expect(find.text('ZONE 2 (Peninsula Area)'), findsOneWidget);

    // Verify locations rendered as FilterChips
    expect(find.widgetWithText(FilterChip, 'NO 2 RIVER'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'BAW BAW'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'HAMILTON'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'LAKKA'), findsOneWidget);

    // Verify NO 2 RIVER chip is selected
    final no2RiverChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'NO 2 RIVER'));
    expect(no2RiverChip.selected, isTrue);

    // Verify BAW BAW chip is NOT selected
    final bawBawChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'BAW BAW'));
    expect(bawBawChip.selected, isFalse);
  });

  testWidgets('OperatingZonesView toggling an unselected location chip selects it and updates counter', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: OperatingZonesView(),
      ),
    );
    await tester.pumpAndSettle();

    // Initially 1 region selected
    expect(find.text('1 of 2 Zones • 1 Regions Selected'), findsOneWidget);

    // Tap BAW BAW chip
    await tester.tap(find.widgetWithText(FilterChip, 'BAW BAW'));
    await tester.pumpAndSettle();

    // Counter now reflects 2 regions selected
    expect(find.text('1 of 2 Zones • 2 Regions Selected'), findsOneWidget);

    final bawBawChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'BAW BAW'));
    expect(bawBawChip.selected, isTrue);
  });

  testWidgets('OperatingZonesView toggling zone checkbox toggles all locations in that zone', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: OperatingZonesView(),
      ),
    );
    await tester.pumpAndSettle();

    // Find ZONE 2 checkbox and tap it
    final zone2Checkbox = find.descendant(
      of: find.ancestor(of: find.text('ZONE 2 (Peninsula Area)'), matching: find.byType(Container)),
      matching: find.byType(Checkbox),
    ).first;

    await tester.tap(zone2Checkbox);
    await tester.pumpAndSettle();

    // Now 2 zones and 3 regions (NO 2 RIVER + HAMILTON + LAKKA) should be selected
    expect(find.text('2 of 2 Zones • 3 Regions Selected'), findsOneWidget);

    final hamiltonChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'HAMILTON'));
    expect(hamiltonChip.selected, isTrue);
    final lakkaChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'LAKKA'));
    expect(lakkaChip.selected, isTrue);
  });

  testWidgets('OperatingZonesView tapping Save Preferred Zones & Regions submits selected zones & locations', (tester) async {
    when(() => mockUpdateOperatingZonesUseCase(any(), any()))
        .thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: OperatingZonesView(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to Save button
    final saveButton = find.text('Save Preferred Zones & Regions');
    await tester.scrollUntilVisible(
      saveButton,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Tap Save button
    await tester.tap(saveButton);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify usecase was called with ZONE 1 and NO 2 RIVER
    verify(() => mockUpdateOperatingZonesUseCase(
      ['ZONE 1'],
      ['NO 2 RIVER'],
    )).called(1);

    // Verify controller state updated
    expect(controller.riderProfile.value?.selectedZones, ['ZONE 1']);
    expect(controller.riderProfile.value?.selectedLocations, ['NO 2 RIVER']);
  });
}
