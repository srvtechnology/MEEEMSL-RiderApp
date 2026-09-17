import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/data/datasources/auth_local_datasource.dart';
import 'package:meeem_rider/data/models/rider_model.dart';
import 'package:meeem_rider/domain/entities/login_response_entity.dart';
import 'package:meeem_rider/domain/entities/registration_result_entity.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/rider_settings_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
import 'package:meeem_rider/domain/usecases/auth/login_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_email_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/send_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_phone_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/register_rider_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/submit_onboarding_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/self_register_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_registration_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/resend_registration_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/reset_password_usecase.dart';
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
import 'package:meeem_rider/presentation/modules/auth/controllers/auth_controller.dart';
import 'package:meeem_rider/presentation/modules/auth/views/register_view.dart';
import 'package:meeem_rider/presentation/modules/auth/views/login_view.dart';
import 'package:meeem_rider/presentation/modules/auth/views/otp_view.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';
import 'package:meeem_rider/presentation/modules/profile/controllers/profile_controller.dart';
import 'package:meeem_rider/presentation/widgets/rider_drawer.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLoginWithPasswordUseCase extends Mock implements LoginWithPasswordUseCase {}
class MockLoginWithEmailPasswordUseCase extends Mock implements LoginWithEmailPasswordUseCase {}
class MockSendPhoneOtpUseCase extends Mock implements SendPhoneOtpUseCase {}
class MockVerifyPhoneOtpUseCase extends Mock implements VerifyPhoneOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockRegisterRiderUseCase extends Mock implements RegisterRiderUseCase {}
class MockSubmitOnboardingUseCase extends Mock implements SubmitOnboardingUseCase {}
class MockSelfRegisterUseCase extends Mock implements SelfRegisterUseCase {}
class MockVerifyRegistrationOtpUseCase extends Mock implements VerifyRegistrationOtpUseCase {}
class MockResendRegistrationOtpUseCase extends Mock implements ResendRegistrationOtpUseCase {}
class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}
class MockDeviceInfoService extends Mock implements DeviceInfoService {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

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

  late AuthController authController;
  late MockLoginWithEmailPasswordUseCase mockLoginWithEmailPasswordUseCase;
  late MockSelfRegisterUseCase mockSelfRegisterUseCase;
  late MockVerifyRegistrationOtpUseCase mockVerifyRegistrationOtpUseCase;
  late MockResendRegistrationOtpUseCase mockResendRegistrationOtpUseCase;
  late MockDeviceInfoService mockDeviceInfoService;

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
        return ByteData.view(Uint8List.fromList(utf8.encode(jsonEncode({
          'google_fonts/Inter-Regular.ttf': ['google_fonts/Inter-Regular.ttf'],
          'google_fonts/Inter-Medium.ttf': ['google_fonts/Inter-Medium.ttf'],
          'google_fonts/Inter-SemiBold.ttf': ['google_fonts/Inter-SemiBold.ttf'],
          'google_fonts/Inter-Bold.ttf': ['google_fonts/Inter-Bold.ttf'],
          'google_fonts/Poppins-Regular.ttf': ['google_fonts/Poppins-Regular.ttf'],
          'google_fonts/Poppins-SemiBold.ttf': ['google_fonts/Poppins-SemiBold.ttf'],
          'google_fonts/Poppins-Bold.ttf': ['google_fonts/Poppins-Bold.ttf'],
        }))).buffer);
      }
      if (key == 'FontManifest.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
      }
      if (key.endsWith('.ttf')) {
        return ByteData.view(Uint8List.fromList(_fontBytes).buffer);
      }
      if (key.endsWith('.png') || key.endsWith('.jpg')) {
        return ByteData.view(Uint8List.fromList([
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
          0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
          0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
          0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
          0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
          0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
        ]).buffer);
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
    registerFallbackValue(const RiderEntity(
      id: 'fallback-rider',
      name: 'Fallback',
      phone: '+919999999999',
      email: '',
      avatar: '',
      rating: 5.0,
      totalTrips: 0,
      isOnline: true,
      walletBalance: 0.0,
      approvalStatus: 'APPROVED',
    ));
  });

  setUp(() {
    Get.testMode = true;
    mockLoginWithEmailPasswordUseCase = MockLoginWithEmailPasswordUseCase();
    mockSelfRegisterUseCase = MockSelfRegisterUseCase();
    mockVerifyRegistrationOtpUseCase = MockVerifyRegistrationOtpUseCase();
    mockResendRegistrationOtpUseCase = MockResendRegistrationOtpUseCase();
    mockDeviceInfoService = MockDeviceInfoService();

    when(() => mockDeviceInfoService.getDeviceId()).thenAnswer((_) async => 'mock-device-id');
    when(() => mockDeviceInfoService.getPlatform()).thenReturn('ANDROID');
    when(() => mockDeviceInfoService.getUserAgent()).thenAnswer((_) async => 'MeeemRider/Test');

    authController = AuthController(
      loginUseCase: MockLoginUseCase(),
      loginWithPasswordUseCase: MockLoginWithPasswordUseCase(),
      loginWithEmailPasswordUseCase: mockLoginWithEmailPasswordUseCase,
      sendPhoneOtpUseCase: MockSendPhoneOtpUseCase(),
      verifyPhoneOtpUseCase: MockVerifyPhoneOtpUseCase(),
      verifyOtpUseCase: MockVerifyOtpUseCase(),
      registerRiderUseCase: MockRegisterRiderUseCase(),
      submitOnboardingUseCase: MockSubmitOnboardingUseCase(),
      selfRegisterUseCase: mockSelfRegisterUseCase,
      verifyRegistrationOtpUseCase: mockVerifyRegistrationOtpUseCase,
      resendRegistrationOtpUseCase: mockResendRegistrationOtpUseCase,
      resetPasswordUseCase: MockResetPasswordUseCase(),
      deviceInfoService: mockDeviceInfoService,
    );
    Get.put<AuthController>(authController);
  });

  tearDown(() {
    authController.cancelResendTimer();
    Get.reset();
  });

  Widget buildTestApp(Widget home) {
    return GetMaterialApp(
      home: home,
      getPages: [
        GetPage(name: AppRoutes.otp, page: () => const Scaffold(body: Text('OTP Page'))),
        GetPage(name: AppRoutes.main, page: () => const Scaffold(body: Text('Main Page'))),
        GetPage(name: AppRoutes.login, page: () => const Scaffold(body: Text('Login Page'))),
        GetPage(name: AppRoutes.onboarding, page: () => const Scaffold(body: Text('Onboarding Page'))),
        GetPage(name: AppRoutes.pendingApproval, page: () => const Scaffold(body: Text('Pending Approval Page'))),
      ],
    );
  }

  group('1. Rider Registration (Mandatory Phone, Optional Email, Vehicle Details)', () {
    testWidgets('Self-registration succeeds with mandatory phone, vehicle details, and no email',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold(body: SizedBox())));

      authController.registerNameController.text = 'Jane Doe';
      authController.registerPhoneController.text = '9876543210';
      authController.registerCountryCode.value = '+91';
      authController.registerEmailController.text = ''; // Optional email
      authController.registerPasswordController.text = 'Secret123!';
      authController.registerVehicleType.value = 'BIKE';
      authController.registerVehicleNumberController.text = 'MH12AB1234';
      authController.registerDrivingLicenseController.text = 'DL-TEST-123';

      when(() => mockSelfRegisterUseCase(
            name: 'Jane Doe',
            phone: '9876543210',
            phoneCountryCode: '+91',
            email: null,
            password: 'Secret123!',
            vehicleType: 'BIKE',
            vehicleNumber: 'MH12AB1234',
            drivingLicense: 'DL-TEST-123',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
          )).thenAnswer((_) async => const Right(RegistrationResultEntity(
            userId: 'user-001',
            email: '',
            phone: '9876543210',
            resendCooldown: 60,
          )));

      await authController.selfRegisterRider();
      expect(authController.phoneNumber.value, '+919876543210');
      expect(authController.otpFlowType.value, OtpFlowType.registration);
      expect(authController.canResendOtp.value, false);
      expect(authController.resendTimerSeconds.value, inInclusiveRange(58, 60));
      authController.cancelResendTimer();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      verify(() => mockSelfRegisterUseCase(
            name: 'Jane Doe',
            phone: '9876543210',
            phoneCountryCode: '+91',
            email: null,
            password: 'Secret123!',
            vehicleType: 'BIKE',
            vehicleNumber: 'MH12AB1234',
            drivingLicense: 'DL-TEST-123',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
          )).called(1);
    });

    testWidgets('Resend registration OTP sends to mobile phone via SMS',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold(body: SizedBox())));

      authController.otpFlowType.value = OtpFlowType.registration;
      authController.canResendOtp.value = true;
      authController.phoneNumber.value = '+919876543210';
      authController.registerPhoneController.text = '9876543210';
      authController.registerCountryCode.value = '+91';

      when(() => mockResendRegistrationOtpUseCase(
            phone: '9876543210',
            phoneCountryCode: '+91',
            email: null,
          )).thenAnswer((_) async => const Right(ResendOtpResultEntity(
            resendCooldown: 45,
            phone: '9876543210',
          )));

      await authController.resendCurrentOtp();
      verify(() => mockResendRegistrationOtpUseCase(
            phone: '9876543210',
            phoneCountryCode: '+91',
            email: null,
          )).called(1);
      expect(authController.resendTimerSeconds.value, 45);
      authController.cancelResendTimer();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('2. Dual Credential Login (Mobile Number or Email with Password)', () {
    testWidgets('Login with Mobile Number and Password calls usecase with phone & identifier',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold(body: SizedBox())));

      authController.loginEmailController.text = '9876543210';
      authController.loginPasswordController.text = 'Password123!';

      when(() => mockLoginWithEmailPasswordUseCase(
            identifier: '9876543210',
            email: null,
            phone: '9876543210',
            phoneCountryCode: '+91',
            password: 'Password123!',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
            deviceToken: any(named: 'deviceToken'),
            userAgent: 'MeeemRider/Test',
          )).thenAnswer((_) async => const Right(LoginResponseEntity(
            user: UserEntity(
              id: 'u-1',
              name: 'Alex Rider',
              phone: '9876543210',
              phoneCountryCode: '+91',
              isPhoneVerified: true,
            ),
            rider: RiderEntity(
              id: 'r-1',
              name: 'Alex Rider',
              phone: '+919876543210',
              email: '',
              avatar: '',
              rating: 5.0,
              totalTrips: 0,
              isOnline: true,
              walletBalance: 0.0,
              approvalStatus: 'APPROVED',
              status: 'APPROVED',
              isApproved: true,
              onboardingCompleted: true,
              isFirstLogin: false,
              vehicleNumber: 'MH12AB1234',
              drivingLicenseNo: 'DL-1234',
              selectedZones: ['ZONE-1'],
            ),
            accessToken: 'mock-token',
            refreshToken: 'mock-refresh',
            expiresIn: 3600,
          )));

      await authController.loginWithEmailPassword();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      verify(() => mockLoginWithEmailPasswordUseCase(
            identifier: '9876543210',
            email: null,
            phone: '9876543210',
            phoneCountryCode: '+91',
            password: 'Password123!',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
            deviceToken: any(named: 'deviceToken'),
            userAgent: 'MeeemRider/Test',
          )).called(1);
    });

    testWidgets('403 Unverified Account redirects to OTP verification screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold(body: SizedBox())));

      authController.loginEmailController.text = '9876543210';
      authController.loginPasswordController.text = 'Password123!';

      when(() => mockLoginWithEmailPasswordUseCase(
            identifier: '9876543210',
            email: null,
            phone: '9876543210',
            phoneCountryCode: '+91',
            password: 'Password123!',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
            deviceToken: any(named: 'deviceToken'),
            userAgent: 'MeeemRider/Test',
          )).thenAnswer((_) async => const Left(UnverifiedAccountFailure(
            message: 'Phone number not verified. Please verify with OTP.',
            statusCode: 403,
          )));

      await authController.loginWithEmailPassword();
      expect(authController.otpFlowType.value, OtpFlowType.registration);
      expect(authController.phoneNumber.value, '9876543210');
      expect(authController.isPendingApproval.value, false);
      authController.cancelResendTimer();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('403 Pending Approval displays banner and does NOT redirect to OTP',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const Scaffold(body: SizedBox())));

      authController.loginEmailController.text = 'rider@meeem.com';
      authController.loginPasswordController.text = 'Password123!';

      when(() => mockLoginWithEmailPasswordUseCase(
            identifier: 'rider@meeem.com',
            email: 'rider@meeem.com',
            phone: null,
            phoneCountryCode: '+91',
            password: 'Password123!',
            deviceId: 'mock-device-id',
            platform: 'ANDROID',
            deviceToken: any(named: 'deviceToken'),
            userAgent: 'MeeemRider/Test',
          )).thenAnswer((_) async => const Left(PendingApprovalFailure(
            message: 'Your account is currently pending admin verification.',
            statusCode: 403,
          )));

      await authController.loginWithEmailPassword();
      await tester.pumpAndSettle();

      expect(authController.isPendingApproval.value, true);
      expect(authController.pendingApprovalMessage.value,
          'Your account is currently pending admin verification.');
      expect(Get.currentRoute, isNot(AppRoutes.otp));
    });
  });

  group('3. UI & Widget Rendering Tests', () {
    testWidgets('RegisterView renders mandatory Phone Number *, optional Email, and Vehicle fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const RegisterView()));
      await tester.pumpAndSettle();

      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.text('Email Address (Optional)'), findsOneWidget);
      expect(find.text('Vehicle Type *'), findsOneWidget);
      expect(find.text('Vehicle Number *'), findsOneWidget);
      expect(find.text('Register & Verify Phone'), findsOneWidget);
    });

    testWidgets('LoginView renders Email or Mobile Number and shows Pending Approval Banner when triggered',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const LoginView()));
      await tester.pumpAndSettle();

      expect(find.text('Email or Mobile Number'), findsOneWidget);
      expect(find.text('Account Pending Verification'), findsNothing);

      // Trigger pending approval banner
      authController.isPendingApproval.value = true;
      authController.pendingApprovalMessage.value = 'Your rider account is pending admin approval.';
      await tester.pumpAndSettle();

      expect(find.text('Account Pending Verification'), findsOneWidget);
      expect(find.text('Your rider account is pending admin approval.'), findsOneWidget);
    });

    testWidgets('OtpView dynamically displays SMS OTP verification target',
        (WidgetTester tester) async {
      authController.otpFlowType.value = OtpFlowType.registration;
      authController.phoneNumber.value = '+91 9876543210';

      await tester.pumpWidget(buildTestApp(const OtpView()));
      await tester.pumpAndSettle();

      expect(find.text('Phone Verification'), findsOneWidget);
      expect(find.text('Verify Your Phone'), findsOneWidget);
      expect(find.text('A 6-digit verification OTP was sent via SMS to +91 9876543210'), findsOneWidget);
    });

    testWidgets('RiderDrawer displays phone under name when email is absent, never an empty string',
        (WidgetTester tester) async {
      final mockAuthLocal = MockAuthLocalDataSource();
      Get.put<AuthLocalDataSource>(mockAuthLocal);

      const rider = RiderEntity(
        id: 'r-1',
        name: 'Carlos Mendez',
        phone: '+91 9876543210',
        email: '', // No email
        avatar: '',
        rating: 5.0,
        totalTrips: 0,
        isOnline: true,
        walletBalance: 0.0,
        approvalStatus: 'APPROVED',
        status: 'APPROVED',
      );

      when(() => mockAuthLocal.getSavedRider()).thenReturn(RiderModel.fromEntity(rider));
      when(() => mockAuthLocal.getSavedUser()).thenReturn(null);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
            drawer: RiderDrawer(),
          ),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Carlos Mendez'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
      expect(find.text(''), findsNothing);

      Get.delete<AuthLocalDataSource>();
    });
  });

  group('4. Profile / Settings Email Update and Conflict Handling', () {
    late ProfileController profileController;
    late MockUpdateProfileUseCase mockUpdateProfileUseCase;

    setUp(() {
      mockUpdateProfileUseCase = MockUpdateProfileUseCase();

      profileController = ProfileController(
        getProfileUseCase: MockGetProfileUseCase(),
        updateProfileUseCase: mockUpdateProfileUseCase,
        getDocumentsUseCase: MockGetDocumentsUseCase(),
        uploadDocumentUseCase: MockUploadDocumentUseCase(),
        getOperatingZonesUseCase: MockGetOperatingZonesUseCase(),
        updateOperatingZonesUseCase: MockUpdateOperatingZonesUseCase(),
        getPayoutInfoUseCase: MockGetPayoutInfoUseCase(),
        updatePayoutInfoUseCase: MockUpdatePayoutInfoUseCase(),
        updateVehicleUseCase: MockUpdateVehicleUseCase(),
        getSettingsUseCase: MockGetSettingsUseCase(),
        updateSettingsUseCase: MockUpdateSettingsUseCase(),
      );
    });

    testWidgets('updateRiderEmail handles 400/409 duplicate email conflict', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));

      profileController.riderProfile.value = const RiderEntity(
        id: 'r-1',
        name: 'Carlos Mendez',
        phone: '+919876543210',
        email: '',
        avatar: '',
        rating: 5.0,
        totalTrips: 0,
        isOnline: true,
        walletBalance: 0.0,
        approvalStatus: 'APPROVED',
      );

      when(() => mockUpdateProfileUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure(
          message: 'Email already in use by another account',
          statusCode: 400,
        )),
      );

      final success = await profileController.updateRiderEmail('taken@meeem.com');
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(success, false);
      expect(profileController.riderProfile.value?.email, '');
    });

    testWidgets('updateRiderEmail succeeds and updates riderProfile and riderSettings', (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SizedBox())));

      profileController.riderProfile.value = const RiderEntity(
        id: 'r-1',
        name: 'Carlos Mendez',
        phone: '+919876543210',
        email: '',
        avatar: '',
        rating: 5.0,
        totalTrips: 0,
        isOnline: true,
        walletBalance: 0.0,
        approvalStatus: 'APPROVED',
      );
      profileController.riderSettings.value = const RiderSettingsEntity(
        user: UserEntity(id: 'u-1', name: 'Carlos Mendez', phone: '+919876543210', email: ''),
      );

      when(() => mockUpdateProfileUseCase(any())).thenAnswer(
        (_) async => const Right(RiderEntity(
          id: 'r-1',
          name: 'Carlos Mendez',
          phone: '+919876543210',
          email: 'new.rider@meeem.com',
          avatar: '',
          rating: 5.0,
          totalTrips: 0,
          isOnline: true,
          walletBalance: 0.0,
          approvalStatus: 'APPROVED',
        )),
      );

      final success = await profileController.updateRiderEmail('new.rider@meeem.com');
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(success, true);
      expect(profileController.riderProfile.value?.email, 'new.rider@meeem.com');
      expect(profileController.riderSettings.value.user?.email, 'new.rider@meeem.com');
    });
  });
}
