import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/navigation_controller.dart';

class NavigationView extends GetView<NavigationController> {
  const NavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Real Google Maps View
          _buildGoogleMap(context),

          // Top Turn Instruction Banner & Destination Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTurnBanner(context),
                  const SizedBox(height: 10),
                  _buildDestinationHeader(context),
                ],
              ),
            ),
          ),

          // Floating Map Action Controls (Recenter & Fit Bounds)
          Positioned(
            right: 16,
            bottom: 235,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'nav_fit_bounds_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  onPressed: () => controller.fitRouteBounds(),
                  child: const Icon(Icons.crop_free_rounded, size: 20),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'nav_recenter_btn',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () => controller.recenterRider(),
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Bottom Navigation Summary Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomTripCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Obx(() {
      return GoogleMap(
        initialCameraPosition: controller.initialCameraPosition,
        onMapCreated: controller.onMapCreated,
        markers: controller.markers.toSet(),
        polylines: controller.polylines.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        trafficEnabled: true,
        mapToolbarEnabled: false,
        onCameraMoveStarted: controller.onCameraMoveStarted,
      );
    });
  }

  Widget _buildTurnBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.currentStepInstruction.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 2),
                Text(
                  'Live turn-by-turn navigation active',
                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationHeader(BuildContext context) {
    final isStore = controller.isHeadingToPickup;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isStore ? Icons.storefront_rounded : Icons.location_on_rounded,
            color: isStore ? AppColors.warningDark : AppColors.secondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.targetTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  controller.targetAddress,
                  style: AppTextStyles.bodySmall(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primary, size: 20),
            onPressed: () => controller.callTarget(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTripCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ETA, Remaining Distance & Speed
            Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                        children: [
                          Text(
                            '${controller.remainingMinutes.value} mins',
                            style: AppTextStyles.navigationEta(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('ETA', style: AppTextStyles.labelSmall()),
                        ],
                      )),
                ),
                Expanded(
                  child: Obx(() => Column(
                        children: [
                          Text(
                            Formatters.formatDistance(controller.remainingDistance.value),
                            style: AppTextStyles.navigationEta(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Distance', style: AppTextStyles.labelSmall()),
                        ],
                      )),
                ),
                Expanded(
                  child: Obx(() => Column(
                        children: [
                          Text(
                            '${controller.currentSpeedKmh.value} km/h',
                            style: AppTextStyles.navigationEta(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Speed', style: AppTextStyles.labelSmall()),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // 1-Tap Navigation Buttons for Google Maps & Apple Maps
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppStrings.openInGoogleMaps,
                    icon: Icons.open_in_new_rounded,
                    type: ButtonType.outline,
                    onPressed: () => controller.openGoogleMaps(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: AppStrings.openInAppleMaps,
                    icon: Icons.map_outlined,
                    type: ButtonType.outline,
                    onPressed: () => controller.openAppleMaps(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Return to Order',
              icon: Icons.arrow_back,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
