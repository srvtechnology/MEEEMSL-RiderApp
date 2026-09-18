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

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (controller.otpFlowType.value == OtpFlowType.twoFactorLogin) {
          controller.clearPreAuthToken();
          controller.cancelTwoFactorExpiryTimer();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            if (controller.otpFlowType.value == OtpFlowType.twoFactorLogin) {
              return const Text('Two-Factor Authentication');
            }
            if (controller.otpFlowType.value == OtpFlowType.registration) {
              return Text(controller.phoneNumber.value.isNotEmpty
                  ? 'Phone Verification'
                  : 'Account Verification');
            }
            return const Text(AppStrings.verifyOtp);
          }),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 2FA Security Badge
                Obx(() {
                  if (controller.otpFlowType.value != OtpFlowType.twoFactorLogin) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '2-Step Security Verification',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Title
                Obx(() {
                  if (controller.otpFlowType.value == OtpFlowType.twoFactorLogin) {
                    return Text(
                      'Enter 6-Digit Code',
                      style: AppTextStyles.headlineLarge(),
                    );
                  }
                  if (controller.otpFlowType.value == OtpFlowType.registration) {
                    return Text(
                      controller.phoneNumber.value.isNotEmpty
                          ? 'Verify Your Phone'
                          : 'Verify Your Account',
                      style: AppTextStyles.headlineLarge(),
                    );
                  }
                  return Text(
                    'Enter Verification Code',
                    style: AppTextStyles.headlineLarge(),
                  );
                }),
                const SizedBox(height: 8),

                // Subtitle / Destination info
                Obx(() {
                  if (controller.otpFlowType.value == OtpFlowType.twoFactorLogin) {
                    final phone = controller.twoFactorMaskedPhone.value;
                    final email = controller.twoFactorMaskedEmail.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'For your account security, a 6-digit verification code has been dispatched to your registered credentials.',
                          style: AppTextStyles.bodyMedium(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (phone.isNotEmpty)
                              Chip(
                                avatar: const Icon(Icons.phone_android, size: 16, color: AppColors.primary),
                                label: Text(phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                backgroundColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.shade100,
                                side: BorderSide(color: AppColors.lightCardBorder),
                                visualDensity: VisualDensity.compact,
                              ),
                            if (email.isNotEmpty)
                              Chip(
                                avatar: const Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                                label: Text(email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                backgroundColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.shade100,
                                side: BorderSide(color: AppColors.lightCardBorder),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    );
                  }

                  final isReg = controller.otpFlowType.value == OtpFlowType.registration;
                  final target = isReg
                      ? (controller.phoneNumber.value.isNotEmpty
                          ? controller.phoneNumber.value
                          : controller.registrationEmail.value)
                      : controller.phoneNumber.value;
                  final method = (isReg && controller.phoneNumber.value.isNotEmpty) ? 'via SMS ' : '';
                  return Text(
                    'A 6-digit verification OTP was sent ${method}to $target',
                    style: AppTextStyles.bodyMedium(),
                  );
                }),
                const SizedBox(height: 32),

                // 6-Digit OTP Field with Auto-Submit
                CustomTextField(
                  controller: controller.otpTextController,
                  hintText: '• • • • • •',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (val) {
                    // Auto-submit as soon as 6th digit is typed
                    if (val.trim().length == 6 && !controller.isLoading.value) {
                      controller.verifyOtp();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Expiry Countdown (if in 2FA mode)
                Obx(() {
                  if (controller.otpFlowType.value != OtpFlowType.twoFactorLogin) {
                    return const SizedBox.shrink();
                  }
                  final expiry = controller.twoFactorCodeExpirySeconds.value;
                  if (expiry <= 0) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFE65100)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Code has expired. Please tap resend below.',
                              style: TextStyle(fontSize: 12, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: expiry < 60 ? Colors.red : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Code valid for ${_formatSeconds(expiry)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: expiry < 60 ? Colors.red : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Timer & Resend Button
                Center(
                  child: Obx(() {
                    if (controller.canResendOtp.value) {
                      return TextButton.icon(
                        onPressed: controller.isLoading.value ? null : () => controller.resendCurrentOtp(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(AppStrings.resendOtp),
                      );
                    }
                    return Text(
                      'Resend code in ${controller.resendTimerSeconds.value}s',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // Verify Button
                Obx(() {
                  String buttonText = AppStrings.verifyOtp;
                  if (controller.otpFlowType.value == OtpFlowType.twoFactorLogin) {
                    buttonText = 'Verify & Sign In';
                  } else if (controller.otpFlowType.value == OtpFlowType.registration) {
                    buttonText = 'Verify & Complete';
                  }
                  return CustomButton(
                    text: buttonText,
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.verifyOtp(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
