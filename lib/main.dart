import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/dio_client.dart';
import 'core/network/logger/api_logger.dart';
import 'core/services/device_info_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/register_device_token_usecase.dart';
import 'domain/usecases/auth/unregister_device_token_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Key-Value Storage
  await GetStorage.init();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Set Preferred Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Global Core Dependency Registrations
  final storage = GetStorage();
  Get.put<GetStorage>(storage, permanent: true);
  Get.put<DeviceInfoService>(DeviceInfoService(storage), permanent: true);
  Get.put<AsyncApiLogger>(AsyncApiLogger.instance, permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);
  Get.put<DioClient>(DioClient(), permanent: true);
  Get.put<AuthLocalDataSource>(AuthLocalDataSourceImpl(storage), permanent: true);
  Get.put<AuthRemoteDataSource>(AuthRemoteDataSourceImpl(Get.find<DioClient>()), permanent: true);
  Get.put<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: Get.find<AuthRemoteDataSource>(),
      localDataSource: Get.find<AuthLocalDataSource>(),
    ),
    permanent: true,
  );
  Get.put<RegisterDeviceTokenUseCase>(RegisterDeviceTokenUseCase(Get.find<AuthRepository>()), permanent: true);
  Get.put<UnregisterDeviceTokenUseCase>(UnregisterDeviceTokenUseCase(Get.find<AuthRepository>()), permanent: true);
  Get.put<SocketService>(SocketService(), permanent: true);
  Get.put<LocationService>(LocationService(), permanent: true);
  Get.put<NotificationService>(NotificationService(), permanent: true);

  runApp(const MeeemRiderApp());
}
