import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/vehicle_entity.dart';
import 'package:meeem_rider/domain/entities/document_entity.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';
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
import 'package:meeem_rider/presentation/modules/profile/views/vehicle_info_view.dart';

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

class FakeVehicleEntity extends Fake implements VehicleEntity {}

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

  const tVehicle = VehicleEntity(
    type: '2_WHEELER',
    licensePlate: 'RD-8842-NY',
    model: 'Honda CB500X',
    color: 'Sapphire Blue',
    year: '2023',
  );

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
    vehicle: tVehicle,
  );

  setUpAll(() {
    registerFallbackValue(FakeVehicleEntity());
  });

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
    when(() => mockGetOperatingZonesUseCase()).thenAnswer((_) async => const Right(<OperatingZoneEntity>[]));
    when(() => mockGetPayoutInfoUseCase()).thenAnswer((_) async => const Right(PayoutInfoEntity(methodType: PayoutMethodType.bank)));
    when(() => mockGetSettingsUseCase()).thenAnswer((_) async => const Right(RiderSettingsEntity()));

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
    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('VehicleInfoView loads and pre-populates vehicle data dynamically from riderProfile', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: VehicleInfoView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and header
    expect(find.text('Vehicle Details'), findsOneWidget);
    expect(find.text('Registered Delivery Vehicle'), findsOneWidget);

    // Verify fields populated from dynamic profile
    expect(find.text('RD-8842-NY'), findsOneWidget);
    expect(find.text('Honda CB500X'), findsOneWidget);
    expect(find.text('Sapphire Blue'), findsOneWidget);
    expect(find.text('2023'), findsOneWidget);

    // Verify 2-Wheeler card is selected by checking check icon
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('VehicleInfoView allows selecting another vehicle type and submitting update via API', (tester) async {
    const updatedVehicle = VehicleEntity(
      type: '3_WHEELER',
      licensePlate: 'SL-5521-AB',
      model: 'Honda CB500X',
      color: 'Sapphire Blue',
      year: '2023',
    );

    when(() => mockUpdateVehicleUseCase(any())).thenAnswer((_) async => const Right(updatedVehicle));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: VehicleInfoView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on 3-Wheeler option
    await tester.tap(find.text('3-Wheeler (Auto Rickshaw / TukTuk)'));
    await tester.pumpAndSettle();

    // Enter new plate number
    final plateField = find.widgetWithText(TextField, 'RD-8842-NY');
    await tester.enterText(plateField, 'SL-5521-AB');

    // Scroll to Update button
    final updateButton = find.text('Update Vehicle Details');
    await tester.scrollUntilVisible(
      updateButton,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Tap Update Vehicle Details button
    await tester.tap(updateButton);
    // Pump past the snackbar duration so no pending timer fails the test
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify use case was invoked with 3_WHEELER and updated plate
    verify(() => mockUpdateVehicleUseCase(any(
      that: isA<VehicleEntity>()
          .having((v) => v.type, 'type', '3_WHEELER')
          .having((v) => v.licensePlate, 'licensePlate', 'SL-5521-AB'),
    ))).called(1);

    // Verify controller state updated
    expect(controller.riderProfile.value?.vehicle?.licensePlate, 'SL-5521-AB');
    expect(controller.riderProfile.value?.vehicle?.type, '3_WHEELER');
  });
}
