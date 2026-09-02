import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resetPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            final isCodeSent = controller.isResetCodeSent.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  isCodeSent ? 'Create New Password' : AppStrings.resetPassword,
                  style: AppTextStyles.headlineMedium(),
                ),
                const SizedBox(height: 6),
                Text(
                  isCodeSent
                      ? 'Enter the 4-digit code sent to your email/phone and choose a new password.'
                      : AppStrings.resetPasswordSubtitle,
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(height: 32),

                if (!isCodeSent) ...[
                  // Step 1: Request Reset Code
                  CustomTextField(
                    controller: controller.resetIdentityController,
                    label: 'Email or Phone Number',
                    hintText: 'alex.rider@meeem.com or +15552345678',
                    prefixIcon: Icons.account_circle_outlined,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: AppStrings.sendResetCode,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.sendResetCode(),
                  ),
                ] else ...[
                  // Step 2: Confirm OTP & Set New Password
                  CustomTextField(
                    controller: controller.resetOtpController,
                    label: 'Reset Verification Code',
                    hintText: 'e.g. 4920',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: controller.newPasswordController,
                    label: AppStrings.newPassword,
                    hintText: 'Minimum 6 characters',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: controller.confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hintText: 'Re-enter your new password',
                    obscureText: true,
                    prefixIcon: Icons.lock_reset,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Update Password',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.confirmPasswordReset(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => controller.isResetCodeSent.value = false,
                      child: const Text('Change email/phone'),
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
