import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Screen 1: Forgot Password (Initiate Password Reset)
/// Conforms to MOBILE_RIDER_FORGOT_PASSWORD_API_DOC.md (Screen 1)
class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Security Icon Badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Forgot Password?',
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your registered email address or phone number to receive a 6-digit password reset code.',
                style: AppTextStyles.bodyMedium(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Identifier Input Field (Email or Phone)
              CustomTextField(
                controller: controller.resetIdentityController,
                label: 'Email or Mobile Number',
                hintText: 'e.g. rider@example.com or +23276123456',
                prefixIcon: Icons.account_circle_outlined,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.telephoneNumber,
                ],
              ),
              const SizedBox(height: 28),

              // Submit Action Button: "Send 6-Digit OTP"
              Obx(() => CustomButton(
                    text: AppStrings.send6DigitOtp,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.sendResetCode(),
                  )),
              const SizedBox(height: 24),

              // Back to Login Link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    if (Get.previousRoute.isNotEmpty) {
                      Get.back();
                    } else {
                      Get.offAllNamed(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Back to Sign In',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
