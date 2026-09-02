import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
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
                      ? 'Enter the 6-digit reset code sent to ${controller.resetMaskedDestination.value.isNotEmpty ? controller.resetMaskedDestination.value : controller.resetIdentityController.text} and choose a new password.'
                      : 'Enter your registered email address or phone number to receive a 6-digit password reset code.',
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(height: 32),

                if (!isCodeSent) ...[
                  // Step 1: Request Reset Code
                  CustomTextField(
                    controller: controller.resetIdentityController,
                    label: 'Email or Phone Number',
                    hintText: 'e.g. rider.ibrahim@example.com or +23276123456',
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
                    hintText: '• • • • • •',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_reset,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
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
                    prefixIcon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 20),

                  // Timer & Resend button
                  Center(
                    child: Obx(() {
                      if (controller.canResendOtp.value) {
                        return TextButton.icon(
                          onPressed: () => controller.sendResetCode(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Resend Reset Code'),
                        );
                      }
                      return Text(
                        'Resend code in ${controller.resendTimerSeconds.value}s',
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

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
