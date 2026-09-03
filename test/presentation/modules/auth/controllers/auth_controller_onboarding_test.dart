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

  test('initOnboardingData pre-fills step 1 with authenticated login user details', () {
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

    expect(controller.fullNameController.text, 'Samuel Taylor');
    expect(controller.emailController.text, 'hadane3655@fanzher.com');
    expect(controller.onboardingPhoneController.text, '+23276145892');
  });
}
