import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/login_with_password_usecase.dart';
import '../../../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../../../domain/usecases/auth/register_rider_usecase.dart';
import '../../../../domain/usecases/auth/reset_password_usecase.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(Get.find<DioClient>()));
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(Get.find()));

    // Repository
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(
          remoteDataSource: Get.find<AuthRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ));

    // UseCases
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => LoginWithPasswordUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => VerifyOtpUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => RegisterRiderUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => ResetPasswordUseCase(Get.find<AuthRepository>()));

    // Controller
    Get.lazyPut<AuthController>(() => AuthController(
          loginUseCase: Get.find<LoginUseCase>(),
          loginWithPasswordUseCase: Get.find<LoginWithPasswordUseCase>(),
          verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
          registerRiderUseCase: Get.find<RegisterRiderUseCase>(),
          resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
        ));
  }
}
