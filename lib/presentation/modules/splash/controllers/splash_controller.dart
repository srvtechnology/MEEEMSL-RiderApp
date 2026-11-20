import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/rider_model.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  bool _hasNavigated = false;

  void navigateToNextScreen() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final storage = GetStorage();
    final token = storage.read<String>(AppConstants.tokenKey);

    if (token != null && token.isNotEmpty) {
      final rawRider = storage.read<String>(AppConstants.riderProfileKey);
      if (rawRider != null && rawRider.isNotEmpty) {
        try {
          final riderMap = jsonDecode(rawRider) as Map<String, dynamic>;
          final rider = RiderModel.fromJson(riderMap);
          if (rider.isSuspended || rider.status.toUpperCase() == 'SUSPENDED') {
            Get.offAllNamed(AppRoutes.login);
            return;
          }
          final bool isApproved = rider.isApproved ||
              rider.status.toUpperCase() == 'APPROVED' ||
              rider.status.toUpperCase() == 'ACTIVE';
          if (isApproved) {
            Get.offAllNamed(AppRoutes.main);
            return;
          }
          if (rider.onboardingCompleted || rider.status.toUpperCase() == 'PENDING') {
            Get.offAllNamed(AppRoutes.pendingApproval);
            return;
          }
          Get.offAllNamed(AppRoutes.onboarding);
          return;
        } catch (_) {}
      }
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}

