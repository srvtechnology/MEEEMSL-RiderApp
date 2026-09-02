import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/profile_controller.dart';

class OperatingZonesView extends GetView<ProfileController> {
  const OperatingZonesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.operatingZones),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferred Delivery Zones',
                      style: AppTextStyles.headlineSmall(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.selectZonesSubtitle,
                      style: AppTextStyles.bodyMedium(),
                    ),
                    const SizedBox(height: 20),

                    // Zones List
                    Obx(() {
                      if (controller.operatingZones.isEmpty && controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.operatingZones.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final zone = controller.operatingZones[index];

                          return GestureDetector(
                            onTap: () => controller.toggleZoneSelection(zone.id),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: zone.isSelected ? AppColors.primaryContainer : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: zone.isSelected ? AppColors.primary : AppColors.lightCardBorder,
                                  width: zone.isSelected ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: zone.isSelected,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) => controller.toggleZoneSelection(zone.id),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          zone.name,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${zone.district} • ${zone.activeRiders} Active Riders Nearby',
                                          style: AppTextStyles.bodySmall(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(
                                    text: '${zone.surgeMultiplier}x Surge',
                                    type: zone.surgeMultiplier > 1.2
                                        ? BadgeType.warning
                                        : (zone.surgeMultiplier > 1.0 ? BadgeType.info : BadgeType.success),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: AppColors.lightCardBorder)),
              ),
              child: CustomButton(
                text: 'Save Preferred Zones',
                icon: Icons.check,
                isLoading: controller.isLoading.value,
                onPressed: () => controller.saveOperatingZones(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
