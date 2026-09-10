import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/repositories/profile_repository.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../controllers/pending_approval_controller.dart';

class PendingApprovalBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileRemoteDataSource>()) {
      Get.lazyPut<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(Get.find<DioClient>()),
      );
    }

    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(
          remoteDataSource: Get.find<ProfileRemoteDataSource>(),
          localDataSource: Get.find<AuthLocalDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<GetProfileUseCase>()) {
      Get.lazyPut<GetProfileUseCase>(
        () => GetProfileUseCase(Get.find<ProfileRepository>()),
      );
    }

    Get.lazyPut<PendingApprovalController>(
      () => PendingApprovalController(
        getProfileUseCase: Get.find<GetProfileUseCase>(),
      ),
    );
  }
}
