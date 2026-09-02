import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/profile_remote_datasource.dart';
import '../../../../data/repositories/profile_repository_impl.dart';
import '../../../../domain/repositories/profile_repository.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../../domain/usecases/profile/update_profile_usecase.dart';
import '../../../../domain/usecases/profile/get_documents_usecase.dart';
import '../../../../domain/usecases/profile/upload_document_usecase.dart';
import '../../../../domain/usecases/profile/get_operating_zones_usecase.dart';
import '../../../../domain/usecases/profile/update_operating_zones_usecase.dart';
import '../../../../domain/usecases/profile/get_payout_info_usecase.dart';
import '../../../../domain/usecases/profile/update_payout_info_usecase.dart';
import '../../../../domain/usecases/profile/update_vehicle_usecase.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Datasource & Repository
    if (!Get.isRegistered<ProfileRemoteDataSource>()) {
      Get.lazyPut<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(Get.find<DioClient>()));
    }
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(() => ProfileRepositoryImpl(
            remoteDataSource: Get.find<ProfileRemoteDataSource>(),
            localDataSource: Get.find<AuthLocalDataSource>(),
          ));
    }

    // UseCases
    Get.lazyPut(() => GetProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetDocumentsUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UploadDocumentUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetOperatingZonesUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateOperatingZonesUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => GetPayoutInfoUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdatePayoutInfoUseCase(Get.find<ProfileRepository>()));
    Get.lazyPut(() => UpdateVehicleUseCase(Get.find<ProfileRepository>()));

    // Controller
    Get.lazyPut<ProfileController>(() => ProfileController(
          getProfileUseCase: Get.find<GetProfileUseCase>(),
          updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
          getDocumentsUseCase: Get.find<GetDocumentsUseCase>(),
          uploadDocumentUseCase: Get.find<UploadDocumentUseCase>(),
          getOperatingZonesUseCase: Get.find<GetOperatingZonesUseCase>(),
          updateOperatingZonesUseCase: Get.find<UpdateOperatingZonesUseCase>(),
          getPayoutInfoUseCase: Get.find<GetPayoutInfoUseCase>(),
          updatePayoutInfoUseCase: Get.find<UpdatePayoutInfoUseCase>(),
          updateVehicleUseCase: Get.find<UpdateVehicleUseCase>(),
        ));
  }
}
