import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/login_with_password_usecase.dart';
import '../../../../domain/usecases/auth/login_with_email_password_usecase.dart';
import '../../../../domain/usecases/auth/send_phone_otp_usecase.dart';
import '../../../../domain/usecases/auth/verify_phone_otp_usecase.dart';
import '../../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../../domain/usecases/auth/register_rider_usecase.dart';
import '../../../../domain/usecases/auth/self_register_usecase.dart';
import '../../../../domain/usecases/auth/verify_registration_otp_usecase.dart';
import '../../../../domain/usecases/auth/resend_registration_otp_usecase.dart';
import '../../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../../domain/usecases/auth/submit_onboarding_usecase.dart';
import '../../../../domain/usecases/auth/register_device_token_usecase.dart';
import '../../../../domain/usecases/auth/unregister_device_token_usecase.dart';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/repositories/profile_repository.dart';
import '../../../../domain/usecases/profile/get_operating_zones_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(Get.find<DioClient>()), fenix: true);
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(Get.find()), fenix: true);
    if (!Get.isRegistered<ProfileRemoteDataSource>()) {
      Get.lazyPut<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(Get.find<DioClient>()), fenix: true);
    }

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      fenix: true,
    );
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(
          remoteDataSource: Get.find<ProfileRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ),
        fenix: true,
      );
    }

    // UseCases
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => LoginWithPasswordUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => LoginWithEmailPasswordUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SendPhoneOtpUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => VerifyPhoneOtpUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => VerifyOtpUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => RegisterRiderUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SubmitOnboardingUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => SelfRegisterUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => VerifyRegistrationOtpUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ResendRegistrationOtpUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ResetPasswordUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => RegisterDeviceTokenUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => UnregisterDeviceTokenUseCase(Get.find<AuthRepository>()), fenix: true);
    if (!Get.isRegistered<GetOperatingZonesUseCase>()) {
      Get.lazyPut(() => GetOperatingZonesUseCase(Get.find<ProfileRepository>()), fenix: true);
    }

    // Controller
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(
          loginUseCase: Get.find<LoginUseCase>(),
          loginWithPasswordUseCase: Get.find<LoginWithPasswordUseCase>(),
          loginWithEmailPasswordUseCase: Get.find<LoginWithEmailPasswordUseCase>(),
          sendPhoneOtpUseCase: Get.find<SendPhoneOtpUseCase>(),
          verifyPhoneOtpUseCase: Get.find<VerifyPhoneOtpUseCase>(),
          verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
          registerRiderUseCase: Get.find<RegisterRiderUseCase>(),
          submitOnboardingUseCase: Get.find<SubmitOnboardingUseCase>(),
          selfRegisterUseCase: Get.find<SelfRegisterUseCase>(),
          verifyRegistrationOtpUseCase: Get.find<VerifyRegistrationOtpUseCase>(),
          resendRegistrationOtpUseCase: Get.find<ResendRegistrationOtpUseCase>(),
          resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
          deviceInfoService: Get.find<DeviceInfoService>(),
          getOperatingZonesUseCase: Get.find<GetOperatingZonesUseCase>(),
        ),
        permanent: true,
      );
    }
  }
}
