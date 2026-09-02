import os

files = {}

# 1. lib/app.dart
files['lib/app.dart'] = '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_pages.dart';

class MeeemRiderApp extends StatelessWidget {
  const MeeemRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final isDark = storage.read<bool>(AppConstants.isDarkModeKey) ?? false;

    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
'''

# 2. lib/main.dart
files['lib/main.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/network/dio_client.dart';
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

  runApp(const MeeemRiderApp());
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

