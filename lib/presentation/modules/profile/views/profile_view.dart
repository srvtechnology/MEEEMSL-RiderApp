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
import 'rider_settings_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllProfileData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    ListTile(
                      leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                      title: const Text('Settings & Preferences'),
                      subtitle: const Text('Notifications, navigation, units & password', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => Get.to(() => const RiderSettingsView()),
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
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'R';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildRiderHeader(BuildContext context) {
    return Obx(() {
      final rider = controller.riderProfile.value;
      final user = controller.riderSettings.value.user;

      final name = (rider?.name != null && rider!.name.trim().isNotEmpty)
          ? rider.name.trim()
          : (user?.name != null && user!.name.trim().isNotEmpty)
              ? user.name.trim()
              : 'Ibrahim Koroma';

      final email = (rider?.email != null && rider!.email.trim().isNotEmpty)
          ? rider.email.trim()
          : (user?.email != null && user!.email.trim().isNotEmpty)
              ? user.email.trim()
              : 'rider.ibrahim@example.com';

      final phone = (rider?.phone != null && rider!.phone.trim().isNotEmpty)
          ? rider.phone.trim()
          : (user?.phone != null && user!.phone.trim().isNotEmpty)
              ? ((user.phoneCountryCode.isNotEmpty && !user.phone.startsWith('+'))
                  ? '${user.phoneCountryCode} ${user.phone}'
                  : user.phone)
              : '+232 76 123456';

      final avatarUrl = (rider?.avatar != null && rider!.avatar.trim().isNotEmpty)
          ? rider.avatar.trim()
          : (user?.image != null && user!.image!.trim().isNotEmpty)
              ? user.image!.trim()
              : '';

      final status = (rider?.status ?? rider?.approvalStatus ?? 'APPROVED').toUpperCase();
      final isSuspended = rider?.isSuspended ?? (status == 'SUSPENDED');
      final isApproved = !isSuspended && (rider?.isApproved ?? (status == 'APPROVED'));

      final BadgeType badgeType;
      final String badgeText;
      if (isSuspended) {
        badgeType = BadgeType.error;
        badgeText = 'SUSPENDED';
      } else if (isApproved) {
        badgeType = BadgeType.success;
        badgeText = 'APPROVED';
      } else {
        badgeType = BadgeType.warning;
        badgeText = 'IN REVIEW';
      }

      return CustomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          _getInitials(name),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        )
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
                              name,
                              style: AppTextStyles.headlineSmall(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(
                            text: badgeText,
                            type: badgeType,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(email, style: AppTextStyles.bodySmall()),
                      Row(
                        children: [
                          Expanded(child: Text(phone, style: AppTextStyles.bodySmall())),
                          TextButton.icon(
                            onPressed: () => _showEditProfileBottomSheet(context, rider, name, phone),
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
                      '${rider?.totalTrips ?? 0}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Text(AppStrings.totalDeliveries, style: AppTextStyles.labelSmall()),
                  ],
                ),
                Container(height: 24, width: 1, color: AppColors.lightCardBorder),
                Column(
                  children: [
                    Text(
                      '★ ${(rider?.rating ?? 5.0).toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.amber),
                    ),
                    Text('Rating', style: AppTextStyles.labelSmall()),
                  ],
                ),
                Container(height: 24, width: 1, color: AppColors.lightCardBorder),
                Column(
                  children: [
                    Text(
                      'Nle ${(rider?.walletBalance ?? 0.0).toStringAsFixed(1)}',
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

  void _showEditProfileBottomSheet(
    BuildContext context,
    dynamic rider,
    String initialName,
    String initialPhone,
  ) {
    final nameController = TextEditingController(text: initialName);
    final phoneController = TextEditingController(text: initialPhone);
    final vehicleNameController = TextEditingController(
        text: rider?.vehicleName ?? rider?.vehicle?.model ?? '');
    final vehicleNumberController = TextEditingController(
        text: rider?.vehicleNumber ?? rider?.vehicle?.licensePlate ?? '');

    String selectedVehicleType = rider?.vehicleType ?? '2_WHEELER';
    if (!['2_WHEELER', '3_WHEELER', '4_WHEELER', 'BICYCLE'].contains(selectedVehicleType)) {
      selectedVehicleType = '2_WHEELER';
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Rider Profile', style: AppTextStyles.headlineSmall()),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
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
                  const SizedBox(height: 14),
                  const Text(
                    'Vehicle Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildVehicleTypeChip('2_WHEELER', '2-Wheeler', Icons.two_wheeler, selectedVehicleType, (val) {
                        setSheetState(() => selectedVehicleType = val);
                      }),
                      _buildVehicleTypeChip('3_WHEELER', '3-Wheeler', Icons.electric_rickshaw_rounded, selectedVehicleType, (val) {
                        setSheetState(() => selectedVehicleType = val);
                      }),
                      _buildVehicleTypeChip('4_WHEELER', '4-Wheeler', Icons.directions_car_rounded, selectedVehicleType, (val) {
                        setSheetState(() => selectedVehicleType = val);
                      }),
                      _buildVehicleTypeChip('BICYCLE', 'Bicycle', Icons.pedal_bike_rounded, selectedVehicleType, (val) {
                        setSheetState(() => selectedVehicleType = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: vehicleNameController,
                    label: 'Vehicle Model / Name',
                    hintText: 'e.g. Honda CB Shine 125',
                    prefixIcon: Icons.minor_crash_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: vehicleNumberController,
                    label: 'Vehicle License Plate',
                    hintText: 'e.g. SL-AA-9988',
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
                            vehicleType: selectedVehicleType,
                            vehicleName: vehicleNameController.text.trim(),
                            vehicleNumber: vehicleNumberController.text.trim(),
                          );
                        },
                      )),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildVehicleTypeChip(
    String code,
    String label,
    IconData icon,
    String selectedCode,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selectedCode == code;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primaryContainer.withAlpha(50),
      onSelected: (_) => onSelected(code),
    );
  }
}
