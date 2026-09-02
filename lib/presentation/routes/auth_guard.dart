import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import 'app_routes.dart';

/// AuthGuard checks if the rider is authenticated before granting access to protected screens.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
