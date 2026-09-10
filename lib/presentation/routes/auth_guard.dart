import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/rider_model.dart';
import 'app_routes.dart';

/// AuthGuard checks if the rider is authenticated and approved before granting access to protected screens.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token == null || token.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final rawRider = storage.read<String>(AppConstants.riderProfileKey);
    if (rawRider != null && rawRider.isNotEmpty) {
      try {
        final riderMap = jsonDecode(rawRider) as Map<String, dynamic>;
        final rider = RiderModel.fromJson(riderMap);
        if (rider.isSuspended || rider.status.toUpperCase() == 'SUSPENDED') {
          return const RouteSettings(name: AppRoutes.login);
        }
        if (!rider.onboardingCompleted || rider.isFirstLogin) {
          return const RouteSettings(name: AppRoutes.onboarding);
        }
        if (!rider.isApproved || rider.status.toUpperCase() == 'PENDING') {
          return const RouteSettings(name: AppRoutes.pendingApproval);
        }
      } catch (_) {}
    }

    return null;
  }
}
