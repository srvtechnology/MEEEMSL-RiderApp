import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/rider_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../domain/entities/rider_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../routes/app_routes.dart';
import '../widgets/suspended_account_dialog.dart';

class PendingApprovalController extends GetxController {
  final GetProfileUseCase getProfileUseCase;
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final isChecking = false.obs;
  final riderProfile = Rxn<RiderEntity>();
  final userProfile = Rxn<UserEntity>();
  final lastChecked = Rxn<DateTime>();

  PendingApprovalController({required this.getProfileUseCase});

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
    checkApprovalStatus(silent: true);
  }

  void _loadCachedData() {
    try {
      final rawRider = _storage.read<String>(AppConstants.riderProfileKey);
      if (rawRider != null && rawRider.isNotEmpty) {
        final map = jsonDecode(rawRider) as Map<String, dynamic>;
        riderProfile.value = RiderModel.fromJson(map);
      }

      final rawUser = _storage.read<String>(AppConstants.userProfileKey);
      if (rawUser != null && rawUser.isNotEmpty) {
        final map = jsonDecode(rawUser) as Map<String, dynamic>;
        userProfile.value = UserModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('Error loading cached profile for approval: $e');
    }
  }

  Future<void> checkApprovalStatus({bool silent = false}) async {
    if (isChecking.value) return;
    isChecking.value = true;

    final result = await getProfileUseCase();
    isChecking.value = false;
    lastChecked.value = DateTime.now();

    result.fold(
      (failure) {
        if (!silent) {
          Get.snackbar(
            'Check Failed',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFEE2E2),
          );
        }
      },
      (rider) {
        riderProfile.value = rider;

        if (rider.isSuspended || rider.status.toUpperCase() == 'SUSPENDED') {
          SuspendedAccountDialog.show();
          return;
        }

        final isApproved = rider.isApproved && rider.status.toUpperCase() == 'APPROVED';
        if (isApproved) {
          Get.snackbar(
            '🎉 Application Approved!',
            'Your rider account has been approved! Welcome to Meeem Delivery.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE8F8EE),
            duration: const Duration(seconds: 4),
          );
          Get.offAllNamed(AppRoutes.main);
          return;
        }

        if (!silent) {
          Get.snackbar(
            'Application Pending',
            'Your rider profile is still under review by our admin team. Please check back shortly.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFFBEB),
            duration: const Duration(seconds: 3),
          );
        }
      },
    );
  }

  Future<void> contactSupport() async {
    final uri = Uri.parse('mailto:support@meeem.com?subject=Rider%20Application%20Approval%20Inquiry');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('Support', 'Please email support@meeem.com');
      }
    } catch (_) {
      Get.snackbar('Support', 'Please email support@meeem.com');
    }
  }

  void logout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out of Meeem Rider?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().unregisterCurrentDeviceToken();
        }
        _storage.remove(AppConstants.tokenKey);
        _storage.remove(AppConstants.refreshTokenKey);
        _storage.remove(AppConstants.riderProfileKey);
        _storage.remove(AppConstants.userProfileKey);
        Get.back();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }
}
