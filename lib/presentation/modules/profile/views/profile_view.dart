import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/profile_controller.dart';
import 'documents_view.dart';
import 'operating_zones_view.dart';
import 'payout_info_view.dart';
import 'vehicle_info_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rider Avatar, Total Deliveries & Approval Status Card
            _buildRiderHeader(context),
            const SizedBox(height: 16),

            // Profile & Preferences Settings Sections
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                    title: const Text('Documents & Verification'),
                    subtitle: const Text('ID, Driver License, Insurance', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const DocumentsView()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.two_wheeler_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.vehicleDetails),
                    subtitle: const Text('2/3/4-Wheeler & Plate', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const VehicleInfoView()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.operatingZones),
                    subtitle: const Text('Select preferred districts', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const OperatingZonesView()),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.payoutInfo),
                    subtitle: const Text('Bank account & Mobile Money', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.to(() => const PayoutInfoView()),
                  ),
                  const Divider(),
                  Obx(() => SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                        title: const Text(AppStrings.darkMode),
                        value: controller.isDarkMode.value,
                        onChanged: (_) => controller.toggleTheme(),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Support & About
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                    title: const Text(AppStrings.helpSupport),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.snackbar('Support', '24/7 Rider Dispatch Hotline: +1 800 555 MEEEM'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: const Text(AppStrings.termsPrivacy),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Get.snackbar('Legal', 'Meeem Rider Partner Terms & Conditions 2026'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: AppColors.errorLight,
              leading: const Icon(Icons.logout_rounded, color: AppColors.errorDark),
              title: const Text(
                AppStrings.logout,
                style: TextStyle(color: AppColors.errorDark, fontWeight: FontWeight.w700),
              ),
              onTap: () => controller.logout(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderHeader(BuildContext context) {
    return Obx(() {
      final rider = controller.riderProfile.value;
      final isApproved = (rider?.approvalStatus ?? 'approved').toLowerCase() == 'approved';

      return CustomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: rider?.avatar.isNotEmpty == true ? NetworkImage(rider!.avatar) : null,
                  child: rider?.avatar.isEmpty ?? true
                      ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              rider?.name ?? 'Alex Johnson',
                              style: AppTextStyles.headlineSmall(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(
                            text: isApproved ? 'APPROVED' : 'IN REVIEW',
                            type: isApproved ? BadgeType.success : BadgeType.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(rider?.email ?? 'alex.rider@meeem.com', style: AppTextStyles.bodySmall()),
                      Row(
                        children: [
                          Expanded(child: Text(rider?.phone ?? '+232 76 123456', style: AppTextStyles.bodySmall())),
                          TextButton.icon(
                            onPressed: () => _showEditProfileBottomSheet(context, rider),
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${rider?.totalTrips ?? 1420}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Text(AppStrings.totalDeliveries, style: AppTextStyles.labelSmall()),
                  ],
                ),
                Container(height: 24, width: 1, color: AppColors.lightCardBorder),
                Column(
                  children: [
                    Text(
                      '★ ${rider?.rating ?? 4.92}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.amber),
                    ),
                    Text('Rating', style: AppTextStyles.labelSmall()),
                  ],
                ),
                Container(height: 24, width: 1, color: AppColors.lightCardBorder),
                Column(
                  children: [
                    Text(
                      '\$${rider?.walletBalance ?? 184.50}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.successDark),
                    ),
                    Text('Balance', style: AppTextStyles.labelSmall()),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showEditProfileBottomSheet(BuildContext context, dynamic rider) {
    final nameController = TextEditingController(text: rider?.name ?? '');
    final phoneController = TextEditingController(text: rider?.phone ?? '');
    final vehicleNameController = TextEditingController(text: rider?.vehicleName ?? '');
    final vehicleNumberController = TextEditingController(text: rider?.vehicleNumber ?? '');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Rider Profile', style: AppTextStyles.headlineSmall()),
              const SizedBox(height: 16),
              CustomTextField(
                controller: nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: vehicleNameController,
                label: 'Vehicle Model / Name',
                prefixIcon: Icons.two_wheeler,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: vehicleNumberController,
                label: 'Vehicle License Plate',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              Obx(() => CustomButton(
                    text: 'Save Changes',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      Get.back();
                      controller.updateRiderProfile(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        vehicleName: vehicleNameController.text.trim(),
                        vehicleNumber: vehicleNumberController.text.trim(),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
