import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';

class SuspendedAccountDialog extends StatelessWidget {
  final String message;

  const SuspendedAccountDialog({
    super.key,
    this.message = 'Your rider account has been suspended. Please contact platform support to resolve this issue.',
  });

  static void show({String? message}) {
    Get.dialog(
      SuspendedAccountDialog(
        message: message ?? 'Your rider account has been suspended. Please contact platform support.',
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Account Suspended',
              style: AppTextStyles.headlineSmall(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Contact Support',
              icon: Icons.support_agent_rounded,
              onPressed: () async {
                final uri = Uri.parse('mailto:support@meeem.com?subject=Rider%20Account%20Suspension%20Inquiry');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  Get.snackbar('Support', 'Please email support@meeem.com');
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text('Back to Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
