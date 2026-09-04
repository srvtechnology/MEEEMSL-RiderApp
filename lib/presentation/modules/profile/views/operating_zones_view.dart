import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

class OperatingZonesView extends StatefulWidget {
  const OperatingZonesView({super.key});

  @override
  State<OperatingZonesView> createState() => _OperatingZonesViewState();
}

class _OperatingZonesViewState extends State<OperatingZonesView> {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.operatingZones.isEmpty) {
        controller.loadOperatingZones();
      } else {
        controller.syncOperatingZonesWithProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.operatingZones),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Delivery Zones',
            onPressed: () => controller.loadOperatingZones(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadOperatingZones(showLoading: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      const SizedBox(height: 14),

                      // Live Coverage Summary Badge & Quick Selection Bar
                      Obx(() {
                        final zonesCount = controller.totalSelectedZonesCount;
                        final locsCount = controller.totalSelectedLocationsCount;
                        final totalZones = controller.operatingZones.length;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withAlpha(35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withAlpha(45)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$zonesCount of $totalZones Zones • $locsCount Regions Selected',
                                  style: AppTextStyles.bodySmall().copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              if (controller.operatingZones.isNotEmpty) ...[
                                InkWell(
                                  onTap: () => controller.selectAllZonesAndLocations(),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      'Select All',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => controller.clearAllZonesAndLocations(),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

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

                        if (controller.operatingZones.isEmpty && !controller.isLoading.value) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.location_off_rounded, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No operating zones found',
                                    style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => controller.loadOperatingZones(),
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.operatingZones.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final zone = controller.operatingZones[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: zone.isSelected ? AppColors.primaryContainer.withAlpha(25) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: zone.isSelected ? AppColors.primary : AppColors.lightCardBorder,
                                  width: zone.isSelected ? 1.6 : 1,
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
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Covered Regions / Points:',
                                            style: AppTextStyles.labelSmall(color: AppColors.textSecondaryLight),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: zone.locations.map((loc) {
                                              final isLocSelected = loc.isSelected;

                                              return FilterChip(
                                                label: Text(loc.name),
                                                selected: isLocSelected,
                                                selectedColor: AppColors.primaryContainer.withAlpha(50),
                                                checkmarkColor: AppColors.primary,
                                                showCheckmark: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: BorderSide(
                                                    color: isLocSelected ? AppColors.primary : AppColors.lightCardBorder,
                                                    width: isLocSelected ? 1.2 : 1,
                                                  ),
                                                ),
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
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: AppColors.lightCardBorder)),
              ),
              child: Obx(
                () => CustomButton(
                  text: 'Save Preferred Zones & Regions',
                  icon: Icons.check,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value ? null : () => controller.saveOperatingZones(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
