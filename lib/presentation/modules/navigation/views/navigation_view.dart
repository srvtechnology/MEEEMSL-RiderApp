import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          // Realistic Stylized Vector Map Canvas
          _buildStylizedMap(context),

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

  Widget _buildStylizedMap(BuildContext context) {
    return Container(
      color: const Color(0xFFE5ECF4),
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: MapGridPainter(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Polyline Path Graphic
            Positioned(
              top: 250,
              left: 100,
              right: 100,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(120),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
            ),
            // Rider Live Marker (Arrow Pulsing)
            Positioned(
              top: 360,
              left: 170,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            // Destination Pin
            Positioned(
              top: 200,
              right: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            child: const Icon(Icons.turn_right_rounded, color: Colors.white, size: 28),
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
                    )),
                const SizedBox(height: 2),
                Text(
                  'Then continue straight for 1.2 km',
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() => Column(
                      children: [
                        Text(
                          '${controller.remainingMinutes.value} mins',
                          style: AppTextStyles.navigationEta(color: AppColors.primary),
                        ),
                        Text('ETA', style: AppTextStyles.labelSmall()),
                      ],
                    )),
                Obx(() => Column(
                      children: [
                        Text(
                          Formatters.formatDistance(controller.remainingDistance.value),
                          style: AppTextStyles.navigationEta(),
                        ),
                        Text('Distance', style: AppTextStyles.labelSmall()),
                      ],
                    )),
                Obx(() => Column(
                      children: [
                        Text(
                          '${controller.currentSpeedKmh.value} km/h',
                          style: AppTextStyles.navigationEta(),
                        ),
                        Text('Speed', style: AppTextStyles.labelSmall()),
                      ],
                    )),
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

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6E2EE)
      ..strokeWidth = 1.5;

    // Draw stylized road grid lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += 60) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
