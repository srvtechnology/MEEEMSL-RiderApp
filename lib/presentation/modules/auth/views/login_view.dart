import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Brand Logo
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logo/logo-icon.png',
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Text(
                        'Delivery Partner App',
                        style: AppTextStyles.labelSmall(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                AppStrings.welcomeBack,
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.loginSubtitle,
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 28),

              // Login Mode Toggle Chips (Email & Password vs Phone & OTP)
              Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lightCardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.isEmailLoginMode.value = true,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: controller.isEmailLoginMode.value
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.loginWithEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: controller.isEmailLoginMode.value
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.isEmailLoginMode.value = false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !controller.isEmailLoginMode.value
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  AppStrings.loginWithPhone,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: !controller.isEmailLoginMode.value
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // Form fields based on selected login mode
              Obx(() {
                if (controller.isEmailLoginMode.value) {
                  return _buildEmailPasswordForm(context);
                } else {
                  return _buildPhoneOtpForm(context);
                }
              }),

              const SizedBox(height: 28),

              // Register Prompt
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Want to become a rider? ",
                      style: AppTextStyles.bodyMedium(),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.onboarding),
                      child: Text(
                        "Start Onboarding",
                        style: AppTextStyles.labelLarge(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              // Footnote
              Center(
                child: Text(
                  'By continuing, you agree to Meeem Terms of Service & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller.loginEmailController,
          label: AppStrings.email,
          hintText: 'alex.rider@meeem.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
              controller: controller.loginPasswordController,
              label: AppStrings.password,
              hintText: '••••••••',
              obscureText: !controller.isPasswordVisible.value,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => controller.togglePasswordVisibility(),
              ),
            )),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              AppStrings.forgotPassword,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(() => CustomButton(
              text: 'Sign In',
              isLoading: controller.isLoading.value,
              onPressed: () => controller.loginWithEmailPassword(),
            )),
      ],
    );
  }

  Widget _buildPhoneOtpForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightCardBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Obx(() => DropdownButton<String>(
                      value: controller.selectedCountryCode.value,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      items: const [
                        DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                        DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                        DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                        DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
                        DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                      ],
                      onChanged: (val) {
                        if (val != null) controller.selectedCountryCode.value = val;
                      },
                    )),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomTextField(
                controller: controller.phoneTextController,
                hintText: '555 019 2834',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Obx(() => CustomButton(
              text: AppStrings.sendOtp,
              isLoading: controller.isLoading.value,
              onPressed: () => controller.sendOtp(),
            )),
      ],
    );
  }
}
