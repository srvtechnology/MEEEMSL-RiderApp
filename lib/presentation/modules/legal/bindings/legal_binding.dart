import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/datasources/legal_remote_datasource.dart';
import '../../../../data/repositories/legal_repository_impl.dart';
import '../../../../domain/repositories/legal_repository.dart';
import '../../../../domain/usecases/legal/get_legal_documents_usecase.dart';
import '../controllers/legal_controller.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    // Datasource
    if (!Get.isRegistered<LegalRemoteDataSource>()) {
      Get.lazyPut<LegalRemoteDataSource>(
        () => LegalRemoteDataSourceImpl(Get.find<DioClient>()),
      );
    }

    // Repository
    if (!Get.isRegistered<LegalRepository>()) {
      Get.lazyPut<LegalRepository>(
        () => LegalRepositoryImpl(
          remoteDataSource: Get.find<LegalRemoteDataSource>(),
        ),
      );
    }

    // UseCase
    Get.lazyPut<GetLegalDocumentsUseCase>(
      () => GetLegalDocumentsUseCase(Get.find<LegalRepository>()),
    );

    // Controller
    Get.lazyPut<LegalController>(
      () => LegalController(
        getLegalDocumentsUseCase: Get.find<GetLegalDocumentsUseCase>(),
      ),
    );
  }
}
