import 'package:flutter/material.dart';
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
