import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class RiderSettingsView extends GetView<ProfileController> {
  const RiderSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: Obx(() {
        final settings = controller.riderSettings.value;
        final notifs = settings.notifications;
        final nav = settings.navigation;
        final prefs = settings.appPreferences;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: Notifications
              _buildSectionHeader('Notification Preferences', Icons.notifications_outlined),
              CustomCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Order & Dispatch Alerts'),
                      subtitle: const Text('Receive notifications for new order offers', style: TextStyle(fontSize: 12)),
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
                      subtitle: const Text('Incentives, bonuses and platform updates', style: TextStyle(fontSize: 12)),
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
                      subtitle: const Text('Play chime when receiving delivery orders', style: TextStyle(fontSize: 12)),
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
                      subtitle: const Text('Vibrate on incoming dispatch alerts', style: TextStyle(fontSize: 12)),
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

              // SECTION 2: Navigation
              _buildSectionHeader('Navigation & Route', Icons.navigation_outlined),
              CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Default Navigation App'),
                      subtitle: Text(nav.defaultMapApp, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _showMapAppPicker(context, nav.defaultMapApp),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Voice Guidance'),
                      subtitle: const Text('Turn-by-turn voice prompts', style: TextStyle(fontSize: 12)),
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
                      subtitle: const Text('Prioritize non-toll routes where available', style: TextStyle(fontSize: 12)),
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

              // SECTION 3: App Preferences
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

              // SECTION 4: Security & Password
              _buildSectionHeader('Account Security', Icons.lock_outline),
              CustomCard(
                child: ListTile(
                  leading: const Icon(Icons.password_rounded, color: AppColors.primary),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account login password', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
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

  void _showMapAppPicker(BuildContext context, String current) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
    );
  }

  void _showThemePicker(BuildContext context, String current) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

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
              Text('Change Account Password', style: AppTextStyles.headlineSmall()),
              const SizedBox(height: 6),
              Text('Enter your current password and pick a new one.', style: AppTextStyles.bodyMedium()),
              const SizedBox(height: 20),
              CustomTextField(
                controller: currentPassController,
                label: 'Current Password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: newPassController,
                label: 'New Password (min 6 characters)',
                obscureText: true,
                prefixIcon: Icons.lock_reset,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: confirmPassController,
                label: 'Confirm New Password',
                obscureText: true,
                prefixIcon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    text: 'Update Password',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (newPassController.text.trim() != confirmPassController.text.trim()) {
                        Get.snackbar('Validation', 'New passwords do not match');
                        return;
                      }
                      controller.changePassword(
                        currentPassword: currentPassController.text.trim(),
                        newPassword: newPassController.text.trim(),
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
