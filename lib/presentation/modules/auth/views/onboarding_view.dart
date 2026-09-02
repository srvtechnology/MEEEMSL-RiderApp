import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/payout_info_entity.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.onboardingTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.prevOnboardingStep(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Indicator
            _buildStepperHeader(),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Obx(() {
                  switch (controller.onboardingStep.value) {
                    case 0:
                      return _buildPersonalStep(context);
                    case 1:
                      return _buildDocumentsStep(context);
                    case 2:
                      return _buildVehicleStep(context);
                    case 3:
                      return _buildZonesStep(context);
                    case 4:
                      return _buildPayoutStep(context);
                    default:
                      return _buildPersonalStep(context);
                  }
                }),
              ),
            ),

            // Bottom Navigation Actions
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final stepTitles = ['Personal', 'Documents', 'Vehicle', 'Zones', 'Payout'];

    return Obx(() {
      final currentStep = controller.onboardingStep.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withAlpha(50),
          border: Border(bottom: BorderSide(color: AppColors.lightCardBorder)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.success
                              : (isCurrent ? AppColors.primary : AppColors.lightCardBorder),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent ? Colors.white : AppColors.textSecondaryLight,
                                  ),
                                ),
                        ),
                      ),
                      if (index < 4)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: index < currentStep ? AppColors.success : AppColors.lightCardBorder,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${currentStep + 1} of 5: ${stepTitles[currentStep]}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // STEP 1: Personal Info & Profile Photo
  Widget _buildPersonalStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Personal Information', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Upload your profile photo and enter your legal details.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 24),

        // Profile Photo Upload Card
        Center(
          child: Obx(() {
            final photoPath = controller.profilePhotoPath.value;

            return Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: photoPath.isNotEmpty
                          ? (photoPath.startsWith('http')
                              ? NetworkImage(photoPath) as ImageProvider
                              : FileImage(File(photoPath)))
                          : null,
                      child: photoPath.isEmpty
                          ? const Icon(Icons.person, size: 54, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPhotoSourcePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showPhotoSourcePicker(context),
                  child: const Text(AppStrings.uploadProfilePhoto, style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: controller.fullNameController,
          label: AppStrings.fullName,
          hintText: 'Alex Johnson',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.emailController,
          label: AppStrings.email,
          hintText: 'alex.rider@meeem.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.onboardingPhoneController,
          label: AppStrings.phoneNumber,
          hintText: '+1 555 234 5678',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
      ],
    );
  }

  void _showPhotoSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text(AppStrings.takePhoto),
              onTap: () {
                Get.back();
                controller.pickProfilePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.secondary),
              title: const Text(AppStrings.chooseGallery),
              onTap: () {
                Get.back();
                controller.pickProfilePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Verification Documents
  Widget _buildDocumentsStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Verification Documents', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Please upload clear photos of your official documents.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        // 1. National ID Front & Back
        _buildDocumentUploadCard(
          title: 'National ID / Passport (Front)',
          docType: 'national_id_front',
          pathObservable: controller.nationalIdFrontPath,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _buildDocumentUploadCard(
          title: 'National ID / Passport (Back)',
          docType: 'national_id_back',
          pathObservable: controller.nationalIdBackPath,
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 12),

        // 2. Driver's License
        _buildDocumentUploadCard(
          title: "Driver's License (Active)",
          docType: 'driver_license',
          pathObservable: controller.driverLicensePath,
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 12),

        // 3. Vehicle Insurance
        _buildDocumentUploadCard(
          title: 'Vehicle Insurance Certificate',
          docType: 'vehicle_insurance',
          pathObservable: controller.vehicleInsurancePath,
          icon: Icons.security_outlined,
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String docType,
    required RxString pathObservable,
    required IconData icon,
  }) {
    return Obx(() {
      final isAttached = pathObservable.value.isNotEmpty;

      return CustomCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAttached ? AppColors.successLight : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAttached ? Icons.check_circle : icon,
                color: isAttached ? AppColors.successDark : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    isAttached ? 'Attached & Ready' : 'JPG, PNG, or PDF up to 10MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAttached ? AppColors.successDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.pickDocument(docType),
              icon: Icon(isAttached ? Icons.edit : Icons.upload_file, size: 16),
              label: Text(isAttached ? 'Change' : 'Upload'),
            ),
          ],
        ),
      );
    });
  }

  // STEP 3: Vehicle Details (2-Wheeler, 3-Wheeler, 4-Wheeler)
  Widget _buildVehicleStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Vehicle Information', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Select your delivery vehicle type and enter details.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        // Vehicle Type Selector (2-Wheeler, 3-Wheeler, 4-Wheeler)
        const Text(
          AppStrings.vehicleType,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),

        Obx(() => Column(
              children: [
                _buildVehicleTypeOption(
                  title: '2-Wheeler',
                  subtitle: 'Motorcycle, Scooter, E-Bike',
                  icon: Icons.two_wheeler,
                  value: '2-Wheeler (Motorcycle / Scooter)',
                ),
                const SizedBox(height: 8),
                _buildVehicleTypeOption(
                  title: '3-Wheeler',
                  subtitle: 'Auto Rickshaw, TukTuk, Cargo Trike',
                  icon: Icons.electric_rickshaw_rounded,
                  value: '3-Wheeler (Auto Rickshaw / TukTuk)',
                ),
                const SizedBox(height: 8),
                _buildVehicleTypeOption(
                  title: '4-Wheeler',
                  subtitle: 'Car, Sedan, Van, Delivery Truck',
                  icon: Icons.directions_car_rounded,
                  value: '4-Wheeler (Car / Van / Delivery Truck)',
                ),
              ],
            )),
        const SizedBox(height: 20),

        CustomTextField(
          controller: controller.licensePlateController,
          label: AppStrings.vehiclePlate,
          hintText: 'e.g. RD-8842-NY',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.vehicleModelController,
          label: AppStrings.vehicleModel,
          hintText: 'e.g. Honda CB500X',
          prefixIcon: Icons.minor_crash_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.vehicleColorController,
                label: 'Vehicle Color',
                hintText: 'Sapphire Blue',
                prefixIcon: Icons.color_lens_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: controller.vehicleYearController,
                label: 'Model Year',
                hintText: '2023',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = controller.vehicleType.value == value;

    return GestureDetector(
      onTap: () => controller.vehicleType.value = value,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Theme.of(Get.context!).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: AppTextStyles.bodySmall()),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.lightCardBorder, size: 22),
          ],
        ),
      ),
    );
  }

  // STEP 4: Preferred Operating Zones
  Widget _buildZonesStep(BuildContext context) {
    final availableZones = [
      {'id': 'zone_1', 'name': 'Downtown Commercial District', 'district': 'Central Zone', 'surge': '1.2x Surge'},
      {'id': 'zone_2', 'name': 'North Heights & Uptown', 'district': 'North Zone', 'surge': '1.0x Normal'},
      {'id': 'zone_3', 'name': 'South Bay Marina & Waterfront', 'district': 'South Zone', 'surge': '1.15x Surge'},
      {'id': 'zone_4', 'name': 'Financial Hub & Market Street', 'district': 'East Zone', 'surge': '1.3x High Demand'},
      {'id': 'zone_5', 'name': 'Airport Logistics & Cargo Zone', 'district': 'Special Hub', 'surge': '1.1x Surge'},
      {'id': 'zone_6', 'name': 'West Campus & University Hub', 'district': 'West Zone', 'surge': '1.05x Normal'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Preferred Operating Zones', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text(AppStrings.selectZonesSubtitle, style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        Obx(
          () => Column(
            children: [
              for (int i = 0; i < availableZones.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildZoneItem(context, availableZones[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneItem(BuildContext context, Map<String, String> zone) {
    final isSelected = controller.selectedZones.contains(zone['id']);

    return GestureDetector(
      onTap: () => controller.toggleZone(zone['id']!),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primary,
              onChanged: (_) => controller.toggleZone(zone['id']!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zone['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(zone['district']!, style: AppTextStyles.bodySmall()),
                ],
              ),
            ),
            StatusBadge(
              text: zone['surge']!,
              type: zone['surge']!.contains('High') || zone['surge']!.contains('1.3')
                  ? BadgeType.warning
                  : (zone['surge']!.contains('Surge') ? BadgeType.info : BadgeType.success),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 5: Payout Info (Bank Account vs Mobile Money)
  Widget _buildPayoutStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Payout Information', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Set up where your delivery earnings and tips will be transferred.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        // Payout Method Selector
        Obx(() => Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightCardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.payoutMethodType.value = PayoutMethodType.bank,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: controller.payoutMethodType.value == PayoutMethodType.bank
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.bankAccount,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: controller.payoutMethodType.value == PayoutMethodType.bank
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
                      onTap: () => controller.payoutMethodType.value = PayoutMethodType.mobileMoney,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: controller.payoutMethodType.value == PayoutMethodType.mobileMoney
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.mobileMoney,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: controller.payoutMethodType.value == PayoutMethodType.mobileMoney
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

        Obx(() {
          if (controller.payoutMethodType.value == PayoutMethodType.bank) {
            return Column(
              children: [
                CustomTextField(
                  controller: controller.bankNameController,
                  label: AppStrings.bankName,
                  hintText: 'e.g. Chase Bank, Wells Fargo, Barclays',
                  prefixIcon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.accountNumberController,
                  label: AppStrings.accountNumber,
                  hintText: 'e.g. 9920184920',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.accountHolderController,
                  label: AppStrings.accountHolder,
                  hintText: 'Alex Johnson',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.routingNumberController,
                  label: 'Routing Number / IBAN',
                  hintText: 'e.g. 021000021',
                  prefixIcon: Icons.tag,
                ),
              ],
            );
          } else {
            return Column(
              children: [
                CustomTextField(
                  controller: controller.mobileMoneyProviderController,
                  label: AppStrings.mobileMoneyProvider,
                  hintText: 'e.g. M-Pesa, MTN MoMo, Airtel, GCash',
                  prefixIcon: Icons.phone_android_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.mobileMoneyNumberController,
                  label: AppStrings.mobileMoneyNumber,
                  hintText: '+1 555 234 5678',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.beneficiaryNameController,
                  label: AppStrings.beneficiaryName,
                  hintText: 'Alex Johnson',
                  prefixIcon: Icons.person_outline,
                ),
              ],
            );
          }
        }),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        border: Border(top: BorderSide(color: AppColors.lightCardBorder)),
      ),
      child: Obx(() {
        final currentStep = controller.onboardingStep.value;
        final isLastStep = currentStep == 4;

        return Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: AppStrings.back,
                  type: ButtonType.outline,
                  onPressed: () => controller.prevOnboardingStep(),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: CustomButton(
                text: isLastStep ? AppStrings.completeOnboarding : AppStrings.nextStep,
                type: isLastStep ? ButtonType.secondary : ButtonType.primary,
                isLoading: controller.isLoading.value,
                icon: isLastStep ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                onPressed: () => controller.nextOnboardingStep(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
