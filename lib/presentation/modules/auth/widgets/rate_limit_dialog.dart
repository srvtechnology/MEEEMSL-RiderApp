import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Displays clear, actionable dialogs for severe HTTP 429 security limits:
/// - Daily Phone OTP Cap (9 SMS / 24h)
/// - Brute-Force OTP Guessing Lockout (5 failed attempts -> 15 min block)
/// Conforms to MOBILE_APP_SECURITY_INTEGRATION_GUIDE.md Section 3 (C & D).
class RateLimitDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final bool showSupportAction;

  const RateLimitDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
    this.showSupportAction = false,
  });

  static const String defaultDailyLimitMessage =
      'Daily limit reached for this phone number. Please try again tomorrow or contact customer support.';

  static const String defaultLockoutMessage =
      'Too many failed attempts. Try again in 15 minute(s).';

  static void showDailyOtpLimit({String? message}) {
    if (Get.testMode && Get.overlayContext == null) return;
    final trimmed = message?.trim() ?? '';
    final displayMsg = trimmed.isNotEmpty
        ? '$trimmed\n\nPlease try again tomorrow or contact customer support.'
        : defaultDailyLimitMessage;
    Get.dialog(
      RateLimitDialog(
        title: 'Daily OTP Limit Reached',
        message: displayMsg,
        icon: Icons.sms_failed_outlined,
        accentColor: AppColors.error,
        showSupportAction: true,
      ),
      barrierDismissible: true,
    );
  }

  static void showOtpLockout({String? message}) {
    if (Get.testMode && Get.overlayContext == null) return;
    final trimmed = message?.trim() ?? '';
    Get.dialog(
      RateLimitDialog(
        title: 'Verification Temporarily Locked',
        message: trimmed.isNotEmpty ? trimmed : defaultLockoutMessage,
        icon: Icons.lock_clock_outlined,
        accentColor: const Color(0xFFE65100),
        showSupportAction: false,
      ),
      barrierDismissible: true,
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
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (showSupportAction) ...[
              CustomButton(
                text: 'Contact Support',
                icon: Icons.support_agent_rounded,
                onPressed: () async {
                  final uri = Uri.parse(
                    'mailto:support@meeemsl.com?subject=Rider%20OTP%20Verification%20Limit%20Assistance',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Get.snackbar('Support', 'Please email support@meeemsl.com');
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            CustomButton(
              text: 'OK',
              type: showSupportAction ? ButtonType.text : ButtonType.primary,
              onPressed: () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
