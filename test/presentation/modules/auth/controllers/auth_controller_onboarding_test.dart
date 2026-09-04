import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
}
