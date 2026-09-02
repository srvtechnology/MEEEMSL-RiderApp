import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// NotificationService handles Push Notifications (FCM simulation),
/// Dispatch Assignment Sound Alerts, and Heads-up In-app Popups.
class NotificationService extends GetxService {
  final isSoundEnabled = true.obs;
  final isVibrationEnabled = true.obs;

  /// Plays dispatch assignment alert audio/vibration cue.
  void playOrderAlertFeedback() {
    if (isVibrationEnabled.value) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Displays an in-app heads-up pop-up alert for urgent delivery dispatch assignments.
  void showOrderDispatchAlert({
    required String title,
    required String message,
    required VoidCallback onTap,
  }) {
    playOrderAlertFeedback();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      icon: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 28),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      borderRadius: 16,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onTap();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('View Order', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  /// Displays general notification snackbar.
  void showInfoNotification({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
    );
  }
}
