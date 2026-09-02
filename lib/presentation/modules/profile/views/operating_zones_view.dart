import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
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
                      'Delivery Zones & Hierarchical Locations',
                      style: AppTextStyles.headlineSmall(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select preferred delivery zones and specific internal delivery regions you want to cover.',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    const SizedBox(height: 20),

                    // Zones & Hierarchical Locations List
                    Obx(() {
                      if (controller.operatingZones.isEmpty && controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.operatingZones.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final zone = controller.operatingZones[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: zone.isSelected ? AppColors.primaryContainer.withAlpha(40) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: zone.isSelected ? AppColors.primary : AppColors.lightCardBorder,
                                width: zone.isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Zone Header
                                InkWell(
                                  onTap: () => controller.toggleZoneSelection(zone.id),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
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
                                              if (zone.description.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  zone.description,
                                                  style: AppTextStyles.bodySmall(),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(25),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${zone.locations.length} regions',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Internal Region Locations (Hierarchical)
                                if (zone.locations.isNotEmpty) ...[
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Covered Regions / Points:',
                                          style: AppTextStyles.labelSmall(color: AppColors.textSecondaryLight),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: zone.locations.map((loc) {
                                            final isLocSelected = loc.isSelected || zone.isSelected;

                                            return FilterChip(
                                              label: Text(loc.name),
                                              selected: isLocSelected,
                                              selectedColor: AppColors.primaryContainer,
                                              checkmarkColor: AppColors.primary,
                                              labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isLocSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isLocSelected ? AppColors.primary : AppColors.textPrimaryLight,
                                              ),
                                              onSelected: (_) => controller.toggleLocationSelection(zone.id, loc.id),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
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
                text: 'Save Preferred Zones & Regions',
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
