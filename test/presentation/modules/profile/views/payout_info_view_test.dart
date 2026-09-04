import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/constants/app_strings.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';
import 'package:meeem_rider/domain/entities/document_entity.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';
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
import 'package:meeem_rider/presentation/modules/profile/views/payout_info_view.dart';

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

class FakePayoutInfoEntity extends Fake implements PayoutInfoEntity {}

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

  const tPayoutInfo = PayoutInfoEntity(
    methodType: PayoutMethodType.bank,
    bankName: 'Sierra Leone Commercial Bank',
    accountNumber: '•••• 8829',
    accountHolderName: 'Ibrahim Koroma',
    routingNumber: '021000021',
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
  );

  setUpAll(() {
    registerFallbackValue(FakePayoutInfoEntity());
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
    when(() => mockGetPayoutInfoUseCase()).thenAnswer((_) async => const Right(tPayoutInfo));
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
    controller.payoutInfo.value = tPayoutInfo;
    Get.put<ProfileController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PayoutInfoView loads and pre-populates bank details dynamically', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: PayoutInfoView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and subtitle
    expect(find.text('Payout Information'), findsOneWidget);
    expect(find.text('Payout & Direct Deposit'), findsOneWidget);

    // Verify bank fields pre-populated
    expect(find.byWidgetPredicate((w) => w is TextField && w.controller?.text == 'Sierra Leone Commercial Bank'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is TextField && w.controller?.text == '•••• 8829'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is TextField && w.controller?.text == 'Ibrahim Koroma'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is TextField && w.controller?.text == '021000021'), findsOneWidget);
  });

  testWidgets('PayoutInfoView switches between Bank Account and Mobile Money tabs', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: PayoutInfoView(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Mobile Money tab
    await tester.tap(find.text('Mobile Money'));
    await tester.pumpAndSettle();

    // Verify Mobile Money fields and quick chips are shown
    expect(find.text('Mobile Money Provider'), findsOneWidget);
    expect(find.text('Orange Money'), findsWidgets);
    expect(find.text('Afrimoney'), findsOneWidget);
    expect(find.text(AppStrings.mobileMoneyNumber), findsOneWidget);
    expect(find.text('Beneficiary Name'), findsOneWidget);

    // Tap Afrimoney chip
    await tester.tap(find.text('Afrimoney'));
    await tester.pumpAndSettle();

    // Provider field now contains Afrimoney
    expect(find.text('Afrimoney'), findsWidgets);
  });

  testWidgets('PayoutInfoView saves updated payout details successfully', (tester) async {
    const updatedInfo = PayoutInfoEntity(
      methodType: PayoutMethodType.bank,
      bankName: 'Rokel Commercial Bank',
      accountNumber: 'SL-77889900',
      accountHolderName: 'Ibrahim Koroma',
      routingNumber: '021000021',
    );

    when(() => mockUpdatePayoutInfoUseCase(any()))
        .thenAnswer((_) async => const Right(updatedInfo));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: PayoutInfoView(),
      ),
    );
    await tester.pumpAndSettle();

    // Update bank name
    final bankField = find.widgetWithText(TextField, 'Sierra Leone Commercial Bank');
    await tester.enterText(bankField, 'Rokel Commercial Bank');

    // Update account number
    final accField = find.widgetWithText(TextField, '•••• 8829');
    await tester.enterText(accField, 'SL-77889900');

    // Tap Save Payout Details button
    final saveButton = find.text('Save Payout Details');
    await tester.tap(saveButton);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify use case was invoked
    verify(() => mockUpdatePayoutInfoUseCase(any(
      that: isA<PayoutInfoEntity>()
          .having((p) => p.bankName, 'bankName', 'Rokel Commercial Bank')
          .having((p) => p.accountNumber, 'accountNumber', 'SL-77889900'),
    ))).called(1);

    // Verify controller state updated
    expect(controller.payoutInfo.value?.bankName, 'Rokel Commercial Bank');
    expect(controller.payoutInfo.value?.accountNumber, 'SL-77889900');
  });
}
