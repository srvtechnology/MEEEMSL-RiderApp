import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/auth_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Key-Value Storage
  await GetStorage.init();

  // Set Preferred Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Global Core Dependency Registrations
  final storage = GetStorage();
  Get.put<GetStorage>(storage, permanent: true);
  Get.put<DioClient>(DioClient(), permanent: true);
  Get.put<AuthLocalDataSource>(AuthLocalDataSourceImpl(storage), permanent: true);
  Get.put<LocationService>(LocationService(), permanent: true);
  Get.put<NotificationService>(NotificationService(), permanent: true);

  runApp(const MeeemRiderApp());
}
