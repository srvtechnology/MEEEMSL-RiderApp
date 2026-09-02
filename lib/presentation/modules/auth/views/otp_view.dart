import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOtp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    '\${AppStrings.otpSubtitle} \${controller.phoneNumber.value}',
                    style: AppTextStyles.bodyMedium(),
                  )),
              const SizedBox(height: 36),

              // 6-Digit OTP Field
              CustomTextField(
                controller: controller.otpTextController,
                hintText: '• • • • • •',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_outline,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 24),

              // Timer & Resend Button
              Center(
                child: Obx(() {
                  if (controller.canResendOtp.value) {
                    return TextButton.icon(
                      onPressed: () => controller.sendOtp(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(AppStrings.resendOtp),
                    );
                  }
                  return Text(
                    '\${AppStrings.resendIn} \${controller.resendTimerSeconds.value}s',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify Button
              Obx(() => CustomButton(
                    text: AppStrings.verifyOtp,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.verifyOtp(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
