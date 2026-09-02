import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Create Your Account',
                style: AppTextStyles.headlineLarge(),
              ),
              const SizedBox(height: 6),
              Text(
                'Register as a delivery partner with Meeem Network.',
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 28),

              // Full Name
              CustomTextField(
                controller: controller.registerNameController,
                label: 'Full Name',
                hintText: 'e.g. Ibrahim Koroma',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email Address
              CustomTextField(
                controller: controller.registerEmailController,
                label: 'Email Address',
                hintText: 'e.g. rider.ibrahim@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              // Phone with Country Code
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
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
                            value: controller.registerCountryCode.value,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, size: 20),
                            items: const [
                              DropdownMenuItem(value: '+232', child: Text('🇸🇱 +232')),
                              DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                              DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                            ],
                            onChanged: (val) {
                              if (val != null) controller.registerCountryCode.value = val;
                            },
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.registerPhoneController,
                      hintText: '76123456',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password
              Obx(() => CustomTextField(
                    controller: controller.registerPasswordController,
                    label: 'Password',
                    hintText: 'Minimum 6 characters',
                    obscureText: !controller.registerIsPasswordVisible.value,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.registerIsPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => controller.toggleRegisterPasswordVisibility(),
                    ),
                  )),
              const SizedBox(height: 28),

              // Submit Button
              Obx(() => CustomButton(
                    text: 'Register & Verify Email',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.selfRegisterRider(),
                  )),
              const SizedBox(height: 24),

              // Login Prompt
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already registered? ',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.login),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.labelLarge(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
