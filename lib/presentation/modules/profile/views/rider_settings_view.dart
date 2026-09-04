import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/profile_controller.dart';
import 'operating_zones_view.dart';

class RiderSettingsView extends GetView<ProfileController> {
  const RiderSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Settings',
            onPressed: () => controller.refreshFullSettings(),
          ),
        ],
      ),
      body: Obx(() {
        final settings = controller.riderSettings.value;
        final user = settings.user ??
            (controller.riderProfile.value != null
                ? null
                : null);
        final rider = settings.rider ?? controller.riderProfile.value;
        final notifs = settings.notifications;
        final nav = settings.navigation;
        final prefs = settings.appPreferences;
        final devices = settings.registeredDevices;

        return RefreshIndicator(
          onRefresh: () => controller.refreshFullSettings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: Rider Account & Status Overview (Section 7.1)
                _buildSectionHeader('Account & Verification', Icons.badge_outlined),
                _buildAccountOverviewCard(context, user, rider),
                const SizedBox(height: 20),

                // SECTION 2: Account Security (Section 7.2)
                _buildSectionHeader('Account Security', Icons.shield_outlined),
                CustomCard(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.password_rounded, color: AppColors.primary, size: 22),
                    ),
                    title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Keep your rider account protected with a strong password (min 6 chars)',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 3: Preferred Delivery Coverage & Zones (Section 7.1 & 7.2)
                _buildSectionHeader('Delivery Coverage & Zones', Icons.map_outlined),
                _buildCoverageCard(context, rider),
                const SizedBox(height: 20),

                // SECTION 4: Notifications Preferences (Section 7)
                _buildSectionHeader('Notification Preferences', Icons.notifications_outlined),
                CustomCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Order & Dispatch Alerts'),
                        subtitle: const Text(
                          'Receive notifications for new order offers',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: notifs.orderAlerts,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            notifications: notifs.copyWith(orderAlerts: val),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Promotional Alerts'),
                        subtitle: const Text(
                          'Incentives, bonuses and platform updates',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: notifs.promotionalAlerts,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            notifications: notifs.copyWith(promotionalAlerts: val),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Sound Alerts'),
                        subtitle: const Text(
                          'Play chime when receiving delivery orders',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: notifs.soundEnabled,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            notifications: notifs.copyWith(soundEnabled: val),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Vibration'),
                        subtitle: const Text(
                          'Vibrate on incoming dispatch alerts',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: notifs.vibrationEnabled,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            notifications: notifs.copyWith(vibrationEnabled: val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 5: Navigation & Route (Section 7)
                _buildSectionHeader('Navigation & Route', Icons.navigation_outlined),
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Default Navigation App'),
                        subtitle: Text(
                          nav.defaultMapApp,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => _showMapAppPicker(context, nav.defaultMapApp),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Voice Guidance'),
                        subtitle: const Text(
                          'Turn-by-turn voice prompts',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: nav.voiceGuidance,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            navigation: nav.copyWith(voiceGuidance: val),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Avoid Tolls'),
                        subtitle: const Text(
                          'Prioritize non-toll routes where available',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: nav.avoidTolls,
                        onChanged: (val) {
                          controller.updateRiderSettings(
                            navigation: nav.copyWith(avoidTolls: val),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 6: Display & Units (Section 7)
                _buildSectionHeader('Display & Units', Icons.tune_outlined),
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Distance Unit'),
                        subtitle: Text(prefs.distanceUnit == 'KM' ? 'Kilometers (km)' : 'Miles (mi)'),
                        trailing: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'KM', label: Text('KM')),
                            ButtonSegment(value: 'MILES', label: Text('Miles')),
                          ],
                          selected: {prefs.distanceUnit},
                          onSelectionChanged: (set) {
                            controller.updateRiderSettings(
                              appPreferences: prefs.copyWith(distanceUnit: set.first),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Theme Mode'),
                        subtitle: Text(prefs.theme),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => _showThemePicker(context, prefs.theme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION 7: Multi-Device Sessions & Push Tokens (Section 7.1 & Section 9)
                _buildSectionHeader('Active Devices & Push Sessions', Icons.devices_outlined),
                _buildRegisteredDevicesCard(context, devices),
                const SizedBox(height: 24),

                // SECTION 8: App Platform Info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'MEEEM Delivery Network — Rider Mobile App',
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiaryLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0 (API Part 1 Conforming)',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight.withAlpha(180)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.headlineSmall()),
        ],
      ),
    );
  }

  Widget _buildAccountOverviewCard(BuildContext context, dynamic user, dynamic rider) {
    final riderId = rider?.id ?? user?.id ?? 'cm7rider0001';
    final riderName = user?.name ?? rider?.name ?? 'Ibrahim Koroma';
    final riderEmail = user?.email ?? rider?.email ?? 'rider.ibrahim@example.com';
    final isEmailVerified = user?.isEmailVerified ?? true;
    final phone = (user?.phoneCountryCode != null ? '${user.phoneCountryCode} ' : '+232 ') +
        (user?.phone ?? rider?.phone ?? '76123456');
    final status = rider?.status ?? rider?.approvalStatus ?? 'APPROVED';
    final isApproved = status.toString().toUpperCase() == 'APPROVED';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(Icons.person, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            riderEmail,
                            style: AppTextStyles.bodySmall(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isEmailVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: status.toString().toUpperCase(),
                type: isApproved ? BadgeType.success : BadgeType.warning,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 6),
                  Text(phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: riderId));
                  Get.snackbar(
                    'Copied',
                    'Rider ID copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'ID: $riderId',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageCard(BuildContext context, dynamic rider) {
    final List<String> zones = (rider?.selectedZones is List && (rider.selectedZones as List).isNotEmpty)
        ? (rider.selectedZones as List).map((e) => e.toString()).toList()
        : ['ZONE 1', 'ZONE 2'];
    final List<String> locations = (rider?.selectedLocations is List && (rider.selectedLocations as List).isNotEmpty)
        ? (rider.selectedLocations as List).map((e) => e.toString()).toList()
        : ['NO 2 RIVER', 'BAW BAW', 'HAMILTON', 'LAKKA'];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Preferred Operating Zones', style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => Get.to(() => const OperatingZonesView()),
                icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                label: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: zones
                .map((zone) => Chip(
                      label: Text(zone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.primaryContainer,
                      labelStyle: const TextStyle(color: AppColors.primary),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ))
                .toList(),
          ),
          if (locations.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Regions Covered: ${locations.join(', ')}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisteredDevicesCard(BuildContext context, List<dynamic> devices) {
    if (devices.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Device Session', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      'Registered for instant dispatch alerts',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
              const StatusBadge(text: 'THIS DEVICE', type: BadgeType.info),
            ],
          ),
        ),
      );
    }

    final currentId = controller.currentDeviceId.value;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Registered devices receiving order dispatch push notifications (FCM/APNS).',
              style: AppTextStyles.bodySmall(),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final d = devices[index];
              final isCurrent = d.deviceId == currentId || (index == 0 && currentId.isEmpty);
              final isIos = d.platform.toString().toLowerCase() == 'ios';
              final model = d.deviceModel.toString().isNotEmpty ? d.deviceModel.toString() : 'Mobile Device';

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primaryContainer : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIos ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
                      color: isCurrent ? AppColors.primary : AppColors.textSecondaryLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                model,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              const StatusBadge(text: 'THIS DEVICE', type: BadgeType.info),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.platform.toString().toUpperCase()} • ${isCurrent ? 'Active Now' : 'Last active recently'}',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                  if (!isCurrent)
                    IconButton(
                      icon: const Icon(Icons.link_off_rounded, color: AppColors.error, size: 20),
                      tooltip: 'Revoke Device Session',
                      onPressed: () => controller.revokeDeviceSession(d.deviceId.toString()),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMapAppPicker(BuildContext context, String current) {
    Get.bottomSheet(
      Material(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Text('Choose Default Map App', style: AppTextStyles.headlineSmall()),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Google Maps'),
                trailing: current == 'GOOGLE_MAPS' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    navigation: controller.riderSettings.value.navigation.copyWith(defaultMapApp: 'GOOGLE_MAPS'),
                  );
                },
              ),
              ListTile(
                title: const Text('Waze'),
                trailing: current == 'WAZE' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    navigation: controller.riderSettings.value.navigation.copyWith(defaultMapApp: 'WAZE'),
                  );
                },
              ),
              ListTile(
                title: const Text('Apple Maps'),
                trailing: current == 'APPLE_MAPS' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    navigation: controller.riderSettings.value.navigation.copyWith(defaultMapApp: 'APPLE_MAPS'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, String current) {
    Get.bottomSheet(
      Material(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Text('Theme Mode', style: AppTextStyles.headlineSmall()),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('System Default'),
                trailing: current == 'SYSTEM' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    appPreferences: controller.riderSettings.value.appPreferences.copyWith(theme: 'SYSTEM'),
                  );
                  Get.changeThemeMode(ThemeMode.system);
                },
              ),
              ListTile(
                title: const Text('Dark Mode'),
                trailing: current == 'DARK' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    appPreferences: controller.riderSettings.value.appPreferences.copyWith(theme: 'DARK'),
                  );
                  Get.changeThemeMode(ThemeMode.dark);
                },
              ),
              ListTile(
                title: const Text('Light Mode'),
                trailing: current == 'LIGHT' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateRiderSettings(
                    appPreferences: controller.riderSettings.value.appPreferences.copyWith(theme: 'LIGHT'),
                  );
                  Get.changeThemeMode(ThemeMode.light);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    final obscureCurrent = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Change Account Password', style: AppTextStyles.headlineSmall()),
                        const SizedBox(height: 2),
                        Text(
                          'Conforming to Section 7.2 API Specification',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => CustomTextField(
                    controller: currentPassController,
                    label: 'Current Password',
                    obscureText: obscureCurrent.value,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textSecondaryLight,
                      ),
                      onPressed: () => obscureCurrent.value = !obscureCurrent.value,
                    ),
                  )),
              const SizedBox(height: 14),
              Obx(() => CustomTextField(
                    controller: newPassController,
                    label: 'New Password (min 6 characters)',
                    obscureText: obscureNew.value,
                    prefixIcon: Icons.key_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textSecondaryLight,
                      ),
                      onPressed: () => obscureNew.value = !obscureNew.value,
                    ),
                  )),
              const SizedBox(height: 14),
              Obx(() => CustomTextField(
                    controller: confirmPassController,
                    label: 'Confirm New Password',
                    obscureText: obscureConfirm.value,
                    prefixIcon: Icons.check_circle_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textSecondaryLight,
                      ),
                      onPressed: () => obscureConfirm.value = !obscureConfirm.value,
                    ),
                  )),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'Update Password',
                    icon: Icons.check_rounded,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      final curr = currentPassController.text.trim();
                      final next = newPassController.text.trim();
                      final conf = confirmPassController.text.trim();

                      if (curr.isEmpty) {
                        Get.snackbar('Input Error', 'Please enter your current password.');
                        return;
                      }
                      if (next.length < 6) {
                        Get.snackbar('Validation', 'New password must be at least 6 characters.');
                        return;
                      }
                      if (next != conf) {
                        Get.snackbar('Validation', 'New passwords do not match.');
                        return;
                      }
                      controller.changePassword(
                        currentPassword: curr,
                        newPassword: next,
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
