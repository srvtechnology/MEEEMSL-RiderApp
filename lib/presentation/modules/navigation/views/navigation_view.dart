import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
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
          // 1. Fullscreen Real-Time Google Maps Canvas
          _buildGoogleMap(context),

          // 2. Top Turn-by-Turn Navigation HUD (Zomato-style Floating Banner)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTurnNavigationHud(context),
                ],
              ),
            ),
          ),

          // 3. Floating Quick-Action Controls (Right Column: 3D Driving Mode, Traffic, Overview, Recenter)
          Positioned(
            right: 16,
            bottom: 270,
            child: _buildFloatingControls(context),
          ),

          // 4. Floating "Re-center Navigation" Pill (appears when rider manually explores map)
          Positioned(
            left: 0,
            right: 0,
            bottom: 265,
            child: _buildRecenterBanner(),
          ),

          // 5. Zomato-style Bottom Delivery Action Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomDeliverySheet(context),
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
        myLocationEnabled: false, // Rider is drawn with custom animated directional vehicle marker
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        trafficEnabled: controller.isTrafficEnabled.value,
        mapToolbarEnabled: false,
        onCameraMoveStarted: controller.onCameraMoveStarted,
      );
    });
  }

  /// Zomato-style Top Turn-by-Turn Maneuver HUD
  Widget _buildTurnNavigationHud(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate premium contrast
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Maneuver Direction Icon Bubble
          Obx(() {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                controller.currentManeuverIcon.value,
                color: Colors.white,
                size: 30,
              ),
            );
          }),
          const SizedBox(width: 14),

          // Maneuver Distance & Road Instruction
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                      controller.currentManeuverTitle.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 3),
                Obx(() => Text(
                      controller.currentStepInstruction.value,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 5),
                // Live Navigation Pulsing Indicator
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), // Emerald Green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE GPS NAVIGATION • ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sound Toggle Button
          Obx(() {
            final isMuted = controller.isMuted.value;
            return IconButton(
              icon: Icon(
                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: isMuted ? Colors.white38 : Colors.white,
                size: 22,
              ),
              onPressed: () => controller.toggleMute(),
              tooltip: isMuted ? 'Unmute Audio' : 'Mute Audio',
            );
          }),
        ],
      ),
    );
  }

  /// Floating Map Controls (Right Side Column)
  Widget _buildFloatingControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3D Driving Mode vs 2D Route Overview Toggle
        Obx(() {
          final is3d = controller.is3dNavigationMode.value;
          return FloatingActionButton.small(
            heroTag: 'nav_3d_toggle_btn',
            backgroundColor: is3d ? AppColors.primary : Colors.white,
            foregroundColor: is3d ? Colors.white : AppColors.primary,
            elevation: 4,
            onPressed: () => controller.toggleCameraMode(),
            tooltip: is3d ? '3D Driving Perspective Active' : 'Switch to 3D Driving View',
            child: Icon(
              is3d ? Icons.view_in_ar_rounded : Icons.map_rounded,
              size: 20,
            ),
          );
        }),
        const SizedBox(height: 10),

        // Live Traffic Toggle
        Obx(() {
          final traffic = controller.isTrafficEnabled.value;
          return FloatingActionButton.small(
            heroTag: 'nav_traffic_btn',
            backgroundColor: traffic ? const Color(0xFFE0F2FE) : Colors.white,
            foregroundColor: traffic ? const Color(0xFF0284C7) : Colors.black54,
            elevation: 4,
            onPressed: () => controller.toggleTraffic(),
            tooltip: 'Toggle Live Traffic',
            child: const Icon(Icons.traffic_rounded, size: 20),
          );
        }),
        const SizedBox(height: 10),

        // Fit Full Route Overview Bounds
        FloatingActionButton.small(
          heroTag: 'nav_fit_bounds_btn',
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 4,
          onPressed: () => controller.fitRouteBounds(),
          tooltip: 'Fit Whole Route',
          child: const Icon(Icons.crop_free_rounded, size: 20),
        ),
        const SizedBox(height: 10),

        // Recenter on Rider
        FloatingActionButton.small(
          heroTag: 'nav_recenter_btn',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () => controller.recenterRider(),
          tooltip: 'Recenter on Rider',
          child: const Icon(Icons.my_location_rounded, size: 20),
        ),
        const SizedBox(height: 10),

        // Open in External Google Maps (Turn-by-turn App)
        FloatingActionButton.small(
          heroTag: 'nav_external_maps_btn',
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFEA4335), // Google Maps red
          elevation: 4,
          onPressed: () => controller.openExternalMaps(),
          tooltip: 'Open in Google Maps App',
          child: const Icon(Icons.directions_rounded, size: 20),
        ),
      ],
    );
  }

  /// Re-center Navigation Banner when rider pans the map
  Widget _buildRecenterBanner() {
    return Obx(() {
      if (controller.isFollowingRider.value) {
        return const SizedBox.shrink();
      }
      return Center(
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          color: AppColors.primary,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => controller.recenterRider(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Re-center Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Zomato-style Floating Bottom Delivery Action Sheet
  Widget _buildBottomDeliverySheet(BuildContext context) {
    return Obx(() {
      final isStore = controller.isHeadingToPickup;
      final order = controller.activeOrder;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Center pull handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Top Status & Order Number Badge Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Delivery Stage Badge (Tap to toggle leg preview)
                  GestureDetector(
                    onTap: () => controller.toggleTargetLeg(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStore ? const Color(0xFFFFF3E0) : const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isStore ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isStore ? Icons.storefront_rounded : Icons.home_rounded,
                            size: 14,
                            color: isStore ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isStore ? 'STORE PICKUP' : 'CUSTOMER DROPOFF',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isStore ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Order Number
                  Text(
                    order?.orderNumber.isNotEmpty == true ? '#${order!.orderNumber}' : '#ORDER-ACTIVE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Destination Name, Address & 1-Tap Call/Message/Maps Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar / Icon Circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isStore ? AppColors.warningLight : AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isStore ? Icons.storefront_rounded : Icons.person_pin_circle_rounded,
                      color: isStore ? AppColors.warningDark : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Destination Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.targetTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 13, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                controller.targetAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 1-Tap Quick Call Contact
                  IconButton.filledTonal(
                    onPressed: () => controller.callTarget(),
                    icon: const Icon(Icons.phone, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    tooltip: 'Call Contact',
                  ),
                  const SizedBox(width: 4),

                  // 1-Tap Quick Message Contact
                  IconButton.filledTonal(
                    onPressed: () => controller.messageTarget(),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: Colors.black87,
                      visualDensity: VisualDensity.compact,
                    ),
                    tooltip: 'Message Contact',
                  ),
                  const SizedBox(width: 4),

                  // 1-Tap External Google Maps
                  IconButton.filledTonal(
                    onPressed: () => controller.openExternalMaps(),
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.secondary,
                      visualDensity: VisualDensity.compact,
                    ),
                    tooltip: 'Open in Google Maps',
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Live Telemetry Row: ETA, Distance, Speed (Zomato-style KPI Bar)
              Row(
                children: [
                  // ETA
                  Expanded(
                    child: _buildTelemetryTile(
                      icon: Icons.timer_rounded,
                      iconColor: AppColors.primary,
                      title: '${controller.remainingMinutes.value} mins',
                      subtitle: 'ESTIMATED ARRIVAL',
                      isHighlight: true,
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.withAlpha(50)),

                  // Distance
                  Expanded(
                    child: _buildTelemetryTile(
                      icon: Icons.route_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: Formatters.formatDistance(controller.remainingDistance.value),
                      subtitle: 'DISTANCE',
                    ),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.withAlpha(50)),

                  // Live Speed
                  Expanded(
                    child: _buildTelemetryTile(
                      icon: Icons.speed_rounded,
                      iconColor: const Color(0xFF16A34A),
                      title: '${controller.currentSpeedKmh.value} km/h',
                      subtitle: 'RIDER SPEED',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // In-App Milestone Action Button (e.g. "I Have Arrived" / "Order Details")
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: controller.milestoneActionLabel,
                      icon: controller.milestoneActionIcon,
                      type: ButtonType.primary,
                      onPressed: () => controller.advanceMilestone(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.outlined(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Return to Order Details',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTelemetryTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isHighlight ? AppColors.primary : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
