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
import '../../../../domain/entities/operating_zone_entity.dart';
import '../controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initOnboardingData();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.onboardingTitle),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.prevOnboardingStep(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Top Stepper Indicator
            _buildStepperHeader(),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
    final stepIcons = [
      Icons.person_rounded,
      Icons.badge_rounded,
      Icons.two_wheeler_rounded,
      Icons.map_rounded,
      Icons.payments_rounded,
    ];

    return Obx(() {
      final currentStep = controller.onboardingStep.value;
      final progressPercent = ((currentStep + 1) / 5.0);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withAlpha(35),
          border: Border(bottom: BorderSide(color: AppColors.lightCardBorder.withAlpha(80))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step counter & Progress Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'STEP ${currentStep + 1} OF 5',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stepTitles[currentStep],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(progressPercent * 100).toInt()}% Done',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Animated Smooth Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: AppColors.lightCardBorder.withAlpha(120),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 12),

            // Stepper Icon Nodes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;

                Color nodeBg = AppColors.lightCardBorder.withAlpha(100);
                Color iconColor = AppColors.textSecondaryLight;
                if (isCompleted) {
                  nodeBg = AppColors.success;
                  iconColor = Colors.white;
                } else if (isCurrent) {
                  nodeBg = AppColors.primary;
                  iconColor = Colors.white;
                }

                return GestureDetector(
                  onTap: () {
                    // Only allow jumping to already completed steps or current
                    if (index < currentStep) {
                      controller.onboardingStep.value = index;
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: nodeBg,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : Icon(stepIcons[index], size: 16, color: iconColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
        // Verified Account Sync Callout
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.successLight.withAlpha(70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withAlpha(80)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sync_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details Synced',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.successDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pre-filled with your registered login credentials. Review or edit if needed.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Text('Personal Information', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Verify your identity and upload a professional profile photo.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        // Profile Photo Upload
        Center(
          child: Obx(() {
            final photoPath = controller.profilePhotoPath.value;

            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: photoPath.isNotEmpty
                            ? (photoPath.startsWith('http')
                                ? NetworkImage(photoPath) as ImageProvider
                                : FileImage(File(photoPath)))
                            : null,
                        child: photoPath.isEmpty
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPhotoSourcePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showPhotoSourcePicker(context),
                  icon: const Icon(Icons.upload, size: 16),
                  label: Text(
                    photoPath.isNotEmpty ? 'Change Photo' : AppStrings.uploadProfilePhoto,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: controller.fullNameController,
          label: AppStrings.fullName,
          hintText: 'e.g. Samuel Taylor',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.emailController,
          label: AppStrings.email,
          hintText: 'e.g. hadane3655@fanzher.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          suffixIcon: const Tooltip(
            message: 'Verified account email',
            child: Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.onboardingPhoneController,
          label: AppStrings.phoneNumber,
          hintText: 'e.g. +23276145892',
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
        // Security Banner
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withAlpha(45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your documents are encrypted and reviewed solely for Sierra Leone driver compliance and verification.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),

        Text('Verification Documents', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Enter your driver\'s license number and attach clear photos of required documents.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        CustomTextField(
          controller: controller.drivingLicenseNoController,
          label: "Driver's License ID Number",
          hintText: 'e.g. DL-10928374',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 18),

        // 1. National ID / Passport
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
          title: "Driver's License Document",
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
        const SizedBox(height: 16),

        // Document Quality Tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightCardBorder.withAlpha(100)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.secondary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tips: Ensure all 4 corners of documents are visible, text is crisp, and there is no camera glare.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
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
      final path = pathObservable.value;
      final isAttached = path.isNotEmpty;

      return CustomCard(
        backgroundColor: isAttached
            ? AppColors.successLight.withAlpha(40)
            : Theme.of(Get.context!).cardColor,
        border: Border.all(
          color: isAttached ? AppColors.success.withAlpha(100) : AppColors.lightCardBorder,
          width: isAttached ? 1.5 : 1,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isAttached ? AppColors.successLight : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isAttached && !path.startsWith('http') && File(path).existsSync()
                    ? Image.file(File(path), fit: BoxFit.cover)
                    : Icon(
                        isAttached ? Icons.check_circle_rounded : icon,
                        color: isAttached ? AppColors.successDark : AppColors.primary,
                        size: 22,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAttached ? AppColors.success : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAttached ? 'Ready to Submit' : 'JPG, PNG, PDF up to 10MB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isAttached ? FontWeight.w600 : FontWeight.normal,
                          color: isAttached ? AppColors.successDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.pickDocument(docType),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: isAttached ? AppColors.success.withAlpha(15) : AppColors.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(
                isAttached ? Icons.change_circle_outlined : Icons.upload_file_rounded,
                size: 16,
                color: isAttached ? AppColors.successDark : AppColors.primary,
              ),
              label: Text(
                isAttached ? 'Replace' : 'Upload',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isAttached ? AppColors.successDark : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // STEP 3: Vehicle Details (2-Wheeler, 3-Wheeler, 4-Wheeler, Bicycle)
  Widget _buildVehicleStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Vehicle Information', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Select your primary delivery vehicle type and enter details.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 20),

        // Vehicle Type Selector
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
                  value: '2_WHEELER',
                ),
                const SizedBox(height: 8),
                _buildVehicleTypeOption(
                  title: '3-Wheeler',
                  subtitle: 'Auto Rickshaw, TukTuk, Cargo Trike',
                  icon: Icons.electric_rickshaw_rounded,
                  value: '3_WHEELER',
                ),
                const SizedBox(height: 8),
                _buildVehicleTypeOption(
                  title: '4-Wheeler',
                  subtitle: 'Car, Sedan, Van, Delivery Truck',
                  icon: Icons.directions_car_rounded,
                  value: '4_WHEELER',
                ),
                const SizedBox(height: 8),
                _buildVehicleTypeOption(
                  title: 'Bicycle',
                  subtitle: 'Standard Bicycle, Cargo Bike',
                  icon: Icons.pedal_bike_rounded,
                  value: 'BICYCLE',
                ),
              ],
            )),
        const SizedBox(height: 20),

        CustomTextField(
          controller: controller.licensePlateController,
          label: AppStrings.vehiclePlate,
          hintText: 'e.g. SL-AA-9988',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.vehicleModelController,
          label: AppStrings.vehicleModel,
          hintText: 'e.g. Honda CB Shine 125',
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
    final isSelected = controller.vehicleType.value == value ||
        (controller.vehicleType.value.contains(title) && !value.contains('_'));

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

  // STEP 4: Preferred Operating Zones & Locations (From API)
  Widget _buildZonesStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step 4: Operating Zones', style: AppTextStyles.headlineSmall()),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22, color: AppColors.primary),
              tooltip: 'Reload Delivery Zones',
              onPressed: () => controller.loadOperatingZones(),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(AppStrings.selectZonesSubtitle, style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 14),

        // Live Coverage Badge
        Obx(() {
          final zoneCount = controller.selectedZones.length;
          final locCount = controller.selectedLocations.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin_drop, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$zoneCount Zones • $locCount Regions Selected',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: zoneCount > 0 ? AppColors.successLight : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    zoneCount > 0 ? 'Active Coverage' : 'Required',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: zoneCount > 0 ? AppColors.successDark : AppColors.warningDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        Obx(() {
          if (controller.isLoadingZones.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.operatingZonesList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    const Text('No operating zones loaded.'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.loadOperatingZones(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Loading Zones'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              for (final zone in controller.operatingZonesList) ...[
                _buildOperatingZoneCard(context, zone),
                const SizedBox(height: 12),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOperatingZoneCard(BuildContext context, OperatingZoneEntity zone) {
    return Obx(() {
      final isZoneSelected = controller.selectedZones.contains(zone.id);

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isZoneSelected ? AppColors.primaryContainer.withAlpha(40) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isZoneSelected ? AppColors.primary : AppColors.lightCardBorder,
            width: isZoneSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isZoneSelected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => controller.toggleZone(zone.id),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      if (zone.district.isNotEmpty)
                        Text(zone.district, style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ),
                StatusBadge(
                  text: '${zone.locations.length} Regions',
                  type: isZoneSelected ? BadgeType.info : BadgeType.success,
                ),
              ],
            ),
            if (isZoneSelected && zone.locations.isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Operating Locations / Sub-Regions:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  GestureDetector(
                    onTap: () {
                      final allSelected = zone.locations.every((l) => controller.selectedLocations.contains(l.name));
                      if (allSelected) {
                        for (final loc in zone.locations) {
                          controller.selectedLocations.remove(loc.name);
                        }
                      } else {
                        for (final loc in zone.locations) {
                          if (!controller.selectedLocations.contains(loc.name)) {
                            controller.selectedLocations.add(loc.name);
                          }
                        }
                      }
                    },
                    child: Text(
                      zone.locations.every((l) => controller.selectedLocations.contains(l.name))
                          ? 'Deselect All'
                          : 'Select All',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: zone.locations.map((loc) {
                  final isLocSelected = controller.selectedLocations.contains(loc.name);
                  return FilterChip(
                    label: Text(
                      loc.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isLocSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isLocSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isLocSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    onSelected: (_) => controller.toggleLocation(loc.name),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    });
  }

  // STEP 5: Payout Info (Bank Account vs Mobile Money) & Review
  Widget _buildPayoutStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Review & Payout', style: AppTextStyles.headlineSmall()),
        const SizedBox(height: 4),
        Text('Confirm your registration details and set up your delivery earnings payout.', style: AppTextStyles.bodyMedium()),
        const SizedBox(height: 16),

        // Comprehensive Summary Card
        CustomCard(
          backgroundColor: AppColors.primaryContainer.withAlpha(40),
          border: Border.all(color: AppColors.primary.withAlpha(60)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Application Summary', style: AppTextStyles.titleMedium()),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Ready to Submit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.successDark)),
                  ),
                ],
              ),
              const Divider(height: 16),
              Obx(() => Column(
                children: [
                  _buildSummaryRow('Applicant', controller.fullNameController.text.isNotEmpty ? controller.fullNameController.text : 'Rider'),
                  const SizedBox(height: 5),
                  _buildSummaryRow('Email', controller.emailController.text.isNotEmpty ? controller.emailController.text : '-'),
                  const SizedBox(height: 5),
                  _buildSummaryRow('Phone', controller.onboardingPhoneController.text.isNotEmpty ? controller.onboardingPhoneController.text : '-'),
                  const SizedBox(height: 5),
                  _buildSummaryRow('Vehicle', '${controller.vehicleType.value} • ${controller.vehicleModelController.text} (${controller.licensePlateController.text})'),
                  const SizedBox(height: 5),
                  _buildSummaryRow('License No', controller.drivingLicenseNoController.text.isNotEmpty ? controller.drivingLicenseNoController.text : 'Pending'),
                  const SizedBox(height: 5),
                  _buildSummaryRow('Coverage', '${controller.selectedZones.length} Zones (${controller.selectedLocations.length} Regions)'),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Documents', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      Row(
                        children: [
                          _buildDocMiniBadge('ID', controller.nationalIdFrontPath.value.isNotEmpty),
                          const SizedBox(width: 4),
                          _buildDocMiniBadge('DL', controller.driverLicensePath.value.isNotEmpty),
                          const SizedBox(width: 4),
                          _buildDocMiniBadge('Insurance', controller.vehicleInsurancePath.value.isNotEmpty),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Payout Method', style: AppTextStyles.titleMedium()),
        const SizedBox(height: 8),

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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocMiniBadge(String label, bool isAttached) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAttached ? AppColors.successLight : AppColors.lightCardBorder.withAlpha(120),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAttached ? AppColors.success.withAlpha(120) : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAttached ? Icons.check : Icons.circle_outlined,
            size: 10,
            color: isAttached ? AppColors.successDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAttached ? AppColors.successDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
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
