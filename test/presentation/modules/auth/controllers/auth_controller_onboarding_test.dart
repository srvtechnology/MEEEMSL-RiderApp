import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
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
import 'package:get/get.dart';
import 'package:meeem_rider/core/services/device_info_service.dart';
import 'package:meeem_rider/presentation/modules/auth/controllers/auth_controller.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;

  setUp(() {
    Get.testMode = true;
    controller = AuthController(
      loginUseCase: MockLoginUseCase(),
      loginWithPasswordUseCase: MockLoginWithPasswordUseCase(),
      loginWithEmailPasswordUseCase: MockLoginWithEmailPasswordUseCase(),
      sendPhoneOtpUseCase: MockSendPhoneOtpUseCase(),
      verifyPhoneOtpUseCase: MockVerifyPhoneOtpUseCase(),
      verifyOtpUseCase: MockVerifyOtpUseCase(),
      registerRiderUseCase: MockRegisterRiderUseCase(),
      submitOnboardingUseCase: MockSubmitOnboardingUseCase(),
      selfRegisterUseCase: MockSelfRegisterUseCase(),
      verifyRegistrationOtpUseCase: MockVerifyRegistrationOtpUseCase(),
      resendRegistrationOtpUseCase: MockResendRegistrationOtpUseCase(),
      resetPasswordUseCase: MockResetPasswordUseCase(),
      deviceInfoService: MockDeviceInfoService(),
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test('initOnboardingData pre-fills ONLY step 1 (Personal Information) and leaves other steps empty', () {
    const testUser = UserEntity(
      id: 'cmtl8qc5e0008hoi0c4odoszc',
      email: 'hadane3655@fanzher.com',
      name: 'Samuel Taylor',
      role: 'RIDER',
      phone: '76145892',
      phoneCountryCode: '+232',
      isEmailVerified: true,
    );

    const testRider = RiderEntity(
      id: 'cmtl8qc5e0009hoi095of0u0g',
      name: 'Samuel Taylor',
      phone: '76145892',
      email: 'hadane3655@fanzher.com',
      avatar: '',
      rating: 5.0,
      totalTrips: 0,
      isOnline: false,
      walletBalance: 0.0,
      approvalStatus: 'APPROVED',
      isApproved: true,
      status: 'APPROVED',
      onboardingCompleted: false,
      isFirstLogin: true,
      vehicleTypes: [],
      selectedZones: [],
      selectedLocations: [],
    );

    controller.initOnboardingData(user: testUser, rider: testRider);

    // Step 1: Personal Info MUST be pre-filled
    expect(controller.fullNameController.text, 'Samuel Taylor');
    expect(controller.emailController.text, 'hadane3655@fanzher.com');
    expect(controller.onboardingPhoneController.text, '+23276145892');

    // Step 2: Documents MUST NOT be pre-filled
    expect(controller.drivingLicenseNoController.text, isEmpty);
    expect(controller.idExpiryController.text, isEmpty);
    expect(controller.licenseExpiryController.text, isEmpty);
    expect(controller.insuranceExpiryController.text, isEmpty);
    expect(controller.nationalIdFrontPath.value, isEmpty);
    expect(controller.nationalIdBackPath.value, isEmpty);
    expect(controller.driverLicensePath.value, isEmpty);
    expect(controller.vehicleInsurancePath.value, isEmpty);

    // Step 3: Vehicle MUST NOT be pre-filled
    expect(controller.vehicleType.value, isEmpty);
    expect(controller.vehicleModelController.text, isEmpty);
    expect(controller.licensePlateController.text, isEmpty);
    expect(controller.vehicleColorController.text, isEmpty);
    expect(controller.vehicleYearController.text, isEmpty);

    // Step 4: Zones MUST NOT be pre-filled
    expect(controller.selectedZones, isEmpty);
    expect(controller.selectedLocations, isEmpty);

    // Step 5: Payout MUST NOT be pre-filled
    expect(controller.bankNameController.text, isEmpty);
    expect(controller.accountNumberController.text, isEmpty);
    expect(controller.accountHolderController.text, isEmpty);
    expect(controller.routingNumberController.text, isEmpty);
    expect(controller.mobileMoneyProviderController.text, isEmpty);
    expect(controller.mobileMoneyNumberController.text, isEmpty);
    expect(controller.beneficiaryNameController.text, isEmpty);
  });

  test('initOnboardingData only pre-fills Personal Information even if rider has other existing data', () {
    const testUser = UserEntity(
      id: 'cmtl8qc5e0008hoi0c4odoszc',
      email: 'hadane3655@fanzher.com',
      name: 'Samuel Taylor',
      role: 'RIDER',
      phone: '76145892',
      phoneCountryCode: '+232',
      isEmailVerified: true,
    );

    const testRiderWithExistingData = RiderEntity(
      id: 'cmtl8qc5e0009hoi095of0u0g',
      name: 'Samuel Taylor',
      phone: '76145892',
      email: 'hadane3655@fanzher.com',
      avatar: 'https://example.com/avatar.jpg',
      rating: 5.0,
      totalTrips: 0,
      isOnline: false,
      walletBalance: 0.0,
      approvalStatus: 'APPROVED',
      isApproved: true,
      status: 'APPROVED',
      onboardingCompleted: false,
      isFirstLogin: true,
      vehicleType: '2_WHEELER',
      vehicleTypes: ['2_WHEELER'],
      vehicleName: 'Honda CB Shine 125',
      vehicleNumber: 'SL-AA-9988',
      drivingLicenseNo: 'DL-10928374',
      selectedZones: ['ZONE 1'],
      selectedLocations: ['NO 2 RIVER'],
    );

    controller.initOnboardingData(user: testUser, rider: testRiderWithExistingData);

    // Only Personal Information is populated
    expect(controller.fullNameController.text, 'Samuel Taylor');
    expect(controller.emailController.text, 'hadane3655@fanzher.com');
    expect(controller.onboardingPhoneController.text, '+23276145892');
    expect(controller.profilePhotoPath.value, 'https://example.com/avatar.jpg');

    // Other onboarding steps remain completely unpopulated / empty
    expect(controller.drivingLicenseNoController.text, isEmpty);
    expect(controller.vehicleType.value, isEmpty);
    expect(controller.vehicleModelController.text, isEmpty);
    expect(controller.licensePlateController.text, isEmpty);
    expect(controller.selectedZones, isEmpty);
    expect(controller.selectedLocations, isEmpty);
    expect(controller.bankNameController.text, isEmpty);
    expect(controller.accountNumberController.text, isEmpty);
  });

  testWidgets('submitFullOnboarding passes flat payout fields according to selected PaymentOption', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(name: '/main', page: () => const Scaffold()),
          GetPage(name: '/pending-approval', page: () => const Scaffold()),
        ],
      ),
    );
    const testRider = RiderEntity(
      id: 'cm7rider0001',
      name: 'Samuel Taylor',
      phone: '76145892',
      email: 'hadane3655@fanzher.com',
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
      vehicleTypes: ['2_WHEELER'],
      selectedZones: ['ZONE 1'],
      selectedLocations: ['NO 2 RIVER'],
    );

    when(() => controller.submitOnboardingUseCase(
      name: any(named: 'name'),
      phone: any(named: 'phone'),
      phoneCountryCode: any(named: 'phoneCountryCode'),
      newPassword: any(named: 'newPassword'),
      vehicleType: any(named: 'vehicleType'),
      vehicleTypes: any(named: 'vehicleTypes'),
      vehicleName: any(named: 'vehicleName'),
      vehicleNumber: any(named: 'vehicleNumber'),
      vehicleColor: any(named: 'vehicleColor'),
      vehicleYear: any(named: 'vehicleYear'),
      drivingLicenseNo: any(named: 'drivingLicenseNo'),
      selectedZones: any(named: 'selectedZones'),
      selectedLocations: any(named: 'selectedLocations'),
      address: any(named: 'address'),
      emergencyContact: any(named: 'emergencyContact'),
      payoutInfo: any(named: 'payoutInfo'),
      profileImagePath: any(named: 'profileImagePath'),
      drivingLicenseDocPath: any(named: 'drivingLicenseDocPath'),
      nationalIdDocPath: any(named: 'nationalIdDocPath'),
      nationalIdPath: any(named: 'nationalIdPath'),
      vehicleInsuranceDocPath: any(named: 'vehicleInsuranceDocPath'),
    )).thenAnswer((_) async => const Right(testRider));

    controller.fullNameController.text = 'Samuel Taylor';
    controller.onboardingPhoneController.text = '+23276145892';
    controller.vehicleType.value = '2_WHEELER';
    controller.selectedPaymentOption.value = PaymentOption.orangeMoney;
    controller.mobileNumberController.text = '+23276123456';
    controller.agentNumberController.text = 'AG-9081';

    await controller.submitFullOnboarding();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final captured = verify(() => controller.submitOnboardingUseCase(
      name: any(named: 'name'),
      phone: any(named: 'phone'),
      phoneCountryCode: any(named: 'phoneCountryCode'),
      newPassword: any(named: 'newPassword'),
      vehicleType: any(named: 'vehicleType'),
      vehicleTypes: any(named: 'vehicleTypes'),
      vehicleName: any(named: 'vehicleName'),
      vehicleNumber: any(named: 'vehicleNumber'),
      vehicleColor: any(named: 'vehicleColor'),
      vehicleYear: any(named: 'vehicleYear'),
      drivingLicenseNo: any(named: 'drivingLicenseNo'),
      selectedZones: any(named: 'selectedZones'),
      selectedLocations: any(named: 'selectedLocations'),
      address: any(named: 'address'),
      emergencyContact: any(named: 'emergencyContact'),
      payoutInfo: captureAny(named: 'payoutInfo'),
      profileImagePath: any(named: 'profileImagePath'),
      drivingLicenseDocPath: any(named: 'drivingLicenseDocPath'),
      nationalIdDocPath: any(named: 'nationalIdDocPath'),
      nationalIdPath: any(named: 'nationalIdPath'),
      vehicleInsuranceDocPath: any(named: 'vehicleInsuranceDocPath'),
    )).captured;

    expect(captured.length, 1);
    final payout = captured.first as Map<String, dynamic>;
    expect(payout['paymentOption'], 'Orange Money');
    expect(payout['preferredPayoutMethod'], 'Mobile Wallet');
    expect(payout['mobileMoneyOption'], 'Orange Money');
    expect(payout['mobileNumber'], '+23276123456');
    expect(payout['agentNumber'], 'AG-9081');
  });

  group('Onboarding Step Validations & Mandatory Payout', () {
    test('Step 0 (Personal): blocks advance when profile photo is not uploaded', () {
      controller.onboardingStep.value = 0;
      controller.fullNameController.text = 'Samuel Taylor';
      controller.onboardingPhoneController.text = '+23276145892';
      controller.profilePhotoPath.value = '';

      controller.nextOnboardingStep();

      // Must not advance to Step 1
      expect(controller.onboardingStep.value, 0);

      // Once profile photo is provided, advances to Step 1
      controller.profilePhotoPath.value = '/mock/path/profile.jpg';
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);
    });

    test('Step 1 (Documents): blocks advance if any document upload or DL number is missing', () {
      controller.onboardingStep.value = 1;
      controller.drivingLicenseNoController.text = '';
      controller.nationalIdFrontPath.value = '';
      controller.nationalIdBackPath.value = '';
      controller.driverLicensePath.value = '';
      controller.vehicleInsurancePath.value = '';

      // Missing DL No
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);

      controller.drivingLicenseNoController.text = 'DL-10928374';

      // Missing National ID Front
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);

      controller.nationalIdFrontPath.value = '/mock/nid_front.jpg';

      // Missing National ID Back
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);

      controller.nationalIdBackPath.value = '/mock/nid_back.jpg';

      // Missing Driver's License Document
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);

      controller.driverLicensePath.value = '/mock/dl_doc.jpg';

      // Missing Vehicle Insurance
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 1);

      controller.vehicleInsurancePath.value = '/mock/insurance.jpg';

      // Now all 4 documents and DL number are present -> advances to Step 2
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);
    });

    test('Step 2 (Vehicle): blocks advance if vehicleType, licensePlate, make & model, color, or year is missing or invalid', () {
      controller.onboardingStep.value = 2;
      controller.vehicleType.value = '';
      controller.licensePlateController.text = '';
      controller.vehicleModelController.text = '';
      controller.vehicleColorController.text = '';
      controller.vehicleYearController.text = '';

      // Missing vehicle type
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.vehicleType.value = '2_WHEELER';

      // Missing license plate
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.licensePlateController.text = 'SL-AA-9988';

      // Missing vehicle make & model
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.vehicleModelController.text = 'Honda CB Shine 125';

      // Missing vehicle color
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.vehicleColorController.text = 'Sapphire Blue';

      // Missing model year
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      // Invalid model year (non-4-digit or non-number)
      controller.vehicleYearController.text = '23';
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.vehicleYearController.text = 'ABCD';
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      // Valid 4-digit model year
      controller.vehicleYearController.text = '2023';

      // All 4 required fields and vehicle type are provided -> advances to Step 3 (Zones)
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 3);
    });

    test('Step 2 (Vehicle): Bicycle also requires licensePlate, make & model, color, and year', () {
      controller.onboardingStep.value = 2;
      controller.vehicleType.value = 'BICYCLE';
      controller.licensePlateController.text = '';
      controller.vehicleModelController.text = 'Trek Marlin 7';
      controller.vehicleColorController.text = 'Matte Black';
      controller.vehicleYearController.text = '2022';

      // Missing license plate / bike identifier
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 2);

      controller.licensePlateController.text = 'BIKE-001';
      controller.nextOnboardingStep();
      expect(controller.onboardingStep.value, 3);
    });

    test('Step 4 (Payout Method): Bank payout validation blocks when required fields are missing', () {
      controller.onboardingStep.value = 4;
      controller.selectedPaymentOption.value = PaymentOption.bank;

      controller.bankNameController.text = '';
      controller.accountHolderController.text = '';
      controller.accountNumberController.text = '';

      expect(controller.validatePayoutMethod(), isFalse);

      controller.bankNameController.text = 'Sierra Leone Commercial Bank';
      expect(controller.validatePayoutMethod(), isFalse);

      controller.accountHolderController.text = 'Mohamed Kamara';
      expect(controller.validatePayoutMethod(), isFalse);

      controller.accountNumberController.text = '003001002345678';
      expect(controller.validatePayoutMethod(), isTrue);
    });

    test('Step 4 (Payout Method): Mobile Money validation blocks when phone number is missing or too short', () {
      controller.onboardingStep.value = 4;
      controller.selectedPaymentOption.value = PaymentOption.orangeMoney;

      controller.mobileNumberController.text = '';
      expect(controller.validatePayoutMethod(), isFalse);

      // Too short
      controller.mobileNumberController.text = '123';
      expect(controller.validatePayoutMethod(), isFalse);

      // Valid phone
      controller.mobileNumberController.text = '+23276123456';
      expect(controller.validatePayoutMethod(), isTrue);

      // AfriMoney option
      controller.selectedPaymentOption.value = PaymentOption.afriMoney;
      controller.mobileNumberController.text = '+23277987654';
      expect(controller.validatePayoutMethod(), isTrue);
    });
  });
}
