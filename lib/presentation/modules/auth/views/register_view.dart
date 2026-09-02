import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal & Vehicle Details',
                style: AppTextStyles.headlineSmall(),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.registerSubtitle,
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 28),

              // Full Name
              CustomTextField(
                controller: controller.fullNameController,
                label: AppStrings.fullName,
                hintText: 'John Doe',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: controller.emailController,
                label: AppStrings.email,
                hintText: 'john.doe@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Vehicle Type Dropdown
              const Text(
                AppStrings.vehicleType,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.vehicleType.value,
                        items: const [
                          DropdownMenuItem(value: 'Motorcycle', child: Text('🏍️ Motorcycle / Scooter')),
                          DropdownMenuItem(value: 'Bicycle', child: Text('🚲 Bicycle / E-Bike')),
                          DropdownMenuItem(value: 'Car', child: Text('🚗 Car / Sedan')),
                          DropdownMenuItem(value: 'Van', child: Text('🚐 Delivery Van')),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.vehicleType.value = val;
                        },
                      ),
                    )),
              ),
              const SizedBox(height: 16),

              // Vehicle Model
              CustomTextField(
                controller: controller.vehicleModelController,
                label: AppStrings.vehicleModel,
                hintText: 'e.g. Honda CB500X',
                prefixIcon: Icons.two_wheeler_outlined,
              ),
              const SizedBox(height: 16),

              // License Plate
              CustomTextField(
                controller: controller.licensePlateController,
                label: AppStrings.vehiclePlate,
                hintText: 'e.g. NY-9820-AA',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 36),

              // Submit Button
              Obx(() => CustomButton(
                    text: 'Complete Application',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.submitFullOnboarding(),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
