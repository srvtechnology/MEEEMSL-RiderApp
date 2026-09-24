import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

/// Screen 2: Reset Password (Verify OTP & Set New Password)
/// Conforms to MOBILE_RIDER_FORGOT_PASSWORD_API_DOC.md (Screen 2)
class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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

              // Key Icon Badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.vpn_key_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Create New Password',
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 8),

              // Destination chips / info
              Obx(() {
                final email = controller.resetEmail.value;
                final phone = controller.resetPhone.value;
                final destination = controller.resetMaskedDestination.value.isNotEmpty
                    ? controller.resetMaskedDestination.value
                    : controller.resetIdentityController.text;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter the 6-digit reset code sent to your registered credentials.',
                      style: AppTextStyles.bodyMedium(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (phone.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.primary),
                            label: Text(phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                            side: BorderSide(color: AppColors.lightCardBorder),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (email.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                            label: Text(email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                            side: BorderSide(color: AppColors.lightCardBorder),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (email.isEmpty && phone.isEmpty && destination.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
                            label: Text(destination, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                            side: BorderSide(color: AppColors.lightCardBorder),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 28),

              // Input 1: 6-Digit OTP Code
              CustomTextField(
                controller: controller.resetOtpController,
                label: '6-Digit Verification Code',
                hintText: '• • • • • •',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_reset,
                autofocus: true,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 16),

              // Input 2: New Password (with eye toggle)
              Obx(() => CustomTextField(
                    controller: controller.newPasswordController,
                    label: AppStrings.newPassword,
                    hintText: 'Minimum 6 characters',
                    obscureText: !controller.isNewPasswordVisible.value,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondaryLight,
                        size: 20,
                      ),
                      onPressed: () => controller.toggleNewPasswordVisibility(),
                    ),
                  )),
              const SizedBox(height: 16),

              // Input 3: Confirm New Password (with eye toggle)
              Obx(() => CustomTextField(
                    controller: controller.confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hintText: 'Re-enter your new password',
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    prefixIcon: Icons.check_circle_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondaryLight,
                        size: 20,
                      ),
                      onPressed: () => controller.toggleConfirmPasswordVisibility(),
                    ),
                  )),
              const SizedBox(height: 24),

              // Resend OTP Section with Countdown Timer
              Center(
                child: Obx(() {
                  if (controller.canResendOtp.value) {
                    return TextButton.icon(
                      onPressed: controller.isLoading.value ? null : () => controller.resendResetOtp(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Resend OTP',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: controller.resendTimerSeconds.value <= 10
                            ? Colors.red
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Resend code in ${controller.resendTimerSeconds.value}s',
                        style: AppTextStyles.bodyMedium(
                          color: controller.resendTimerSeconds.value <= 10
                              ? Colors.red
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Submit Button: "Reset Password & Sign In"
              Obx(() => CustomButton(
                    text: AppStrings.resetPasswordAndSignIn,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.confirmPasswordReset(),
                  )),
              const SizedBox(height: 16),

              // Change Email / Phone Link
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Change Email or Phone Number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
