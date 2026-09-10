import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/usecases/profile/get_profile_usecase.dart';
import 'package:meeem_rider/presentation/modules/auth/controllers/pending_approval_controller.dart';
import 'package:meeem_rider/presentation/modules/auth/views/pending_approval_view.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

final List<int> _fontBytes = [
  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x03, 0x00, 0x20
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late MockGetProfileUseCase mockGetProfileUseCase;
  late PendingApprovalController controller;

  const testPendingRider = RiderEntity(
    id: 'cmtu3d10r000ab484p4rvanb8',
    name: 'Rider Pranab',
    phone: '+232 732594563',
    email: 'sewic42385@94an.com',
    avatar: '',
    rating: 5.0,
    totalTrips: 0,
    isOnline: false,
    walletBalance: 0.0,
    approvalStatus: 'PENDING',
    isApproved: false,
    status: 'PENDING',
    onboardingCompleted: true,
    isFirstLogin: false,
    vehicleType: '2_WHEELER',
    vehicleName: 'Honda Cbz',
    vehicleNumber: 'SL-5373828',
    drivingLicenseNo: 'DL - 467737',
    adminFeedback: 'Please check your submitted license photo',
  );

  const testApprovedRider = RiderEntity(
    id: 'cmtu3d10r000ab484p4rvanb8',
    name: 'Rider Pranab',
    phone: '+232 732594563',
    email: 'sewic42385@94an.com',
    avatar: '',
    rating: 5.0,
    totalTrips: 0,
    isOnline: false,
    walletBalance: 0.0,
    approvalStatus: 'APPROVED',
    isApproved: true,
    status: 'APPROVED',
    onboardingCompleted: true,
    isFirstLogin: false,
    vehicleType: '2_WHEELER',
    vehicleName: 'Honda Cbz',
    vehicleNumber: 'SL-5373828',
    drivingLicenseNo: 'DL - 467737',
  );

  setUpAll(() async {
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
    await GetStorage.init();
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();

    mockGetProfileUseCase = MockGetProfileUseCase();

    // Default mock response
    when(() => mockGetProfileUseCase()).thenAnswer(
      (_) async => const Right(testPendingRider),
    );

    controller = PendingApprovalController(
      getProfileUseCase: mockGetProfileUseCase,
    );
    Get.put<PendingApprovalController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PendingApprovalView renders pending status, feedback note, and vehicle details', (tester) async {
    controller.riderProfile.value = testPendingRider;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: PendingApprovalView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header status
    expect(find.text('Application Status'), findsOneWidget);
    expect(find.text('PENDING APPROVAL'), findsOneWidget);
    expect(find.text('Application Under Review'), findsOneWidget);

    // Verify admin feedback note is shown
    expect(find.text('Admin Review Note'), findsOneWidget);
    expect(find.text('Please check your submitted license photo'), findsOneWidget);

    // Verify vehicle & applicant details
    expect(find.text('Applicant Name'), findsOneWidget);
    expect(find.text('Rider Pranab'), findsOneWidget);
    expect(find.text('Honda Cbz'), findsOneWidget);
    expect(find.text('SL-5373828'), findsOneWidget);
    expect(find.text('DL - 467737'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Check Approval Status'), findsOneWidget);
    expect(find.text('Need Help? Contact Support'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('PendingApprovalView tapping Check Approval Status triggers getProfileUseCase', (tester) async {
    controller.riderProfile.value = testPendingRider;

    await tester.pumpWidget(
      const GetMaterialApp(
        home: PendingApprovalView(),
      ),
    );
    await tester.pumpAndSettle();

    final checkButton = find.text('Check Approval Status');
    expect(checkButton, findsOneWidget);

    await tester.ensureVisible(checkButton);
    await tester.tap(checkButton);
    await tester.pump();

    verify(() => mockGetProfileUseCase()).called(greaterThanOrEqualTo(1));

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('PendingApprovalController routes to AppRoutes.main when profile becomes APPROVED', (tester) async {
    when(() => mockGetProfileUseCase()).thenAnswer(
      (_) async => const Right(testApprovedRider),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.pendingApproval,
        getPages: [
          GetPage(
            name: AppRoutes.pendingApproval,
            page: () => const PendingApprovalView(),
          ),
          GetPage(
            name: AppRoutes.main,
            page: () => const Scaffold(body: Text('Main Dashboard Screen')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Trigger check
    await controller.checkApprovalStatus(silent: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Main Dashboard Screen'), findsOneWidget);
  });
}
