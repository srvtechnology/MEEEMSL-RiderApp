import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../controllers/dashboard_controller.dart';

/// Radar Idle Widget displayed when Rider is Online without an active order
/// Conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md Section 1 & Section 7.4
class TelemetryRadarCard extends StatefulWidget {
  const TelemetryRadarCard({super.key});

  @override
  State<TelemetryRadarCard> createState() => _TelemetryRadarCardState();
}

class _TelemetryRadarCardState extends State<TelemetryRadarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.success.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Concentric Radar Pulse
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.successLight,
                    border: Border.all(
                      color: AppColors.success.withAlpha(80),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withAlpha(40),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    size: 36,
                    color: AppColors.successDark,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Radar Title & Subtitle
          const Text(
            'Auto-Dispatch Radar Active',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Searching for closest seller orders within your coverage zone. Telemetry is broadcasting to Freetown dispatch engine.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(),
            ),
          ),
          const SizedBox(height: 16),

          // Zone & Vehicle Compatibility Chips (Section 7.2 & 7.4)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      controller.riderZone,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightCardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.two_wheeler_rounded,
                        size: 13, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      controller.vehicleTypeInfo,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Live Coordinates / Telemetry heartbeat ticker
          Obx(() {
            final _ = controller.isOnline.value;
            final locService = controller.locationService;
            final pos = locService?.currentPosition.value;
            final isSocket =
                locService?.telemetryMode.value == TelemetryMode.socketStreaming;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSocket
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSocket
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSocket ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      pos != null
                          ? 'GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)} • ${isSocket ? "Socket.IO streaming (4s)" : "REST fallback"}'
                          : 'GPS: Acquiring satellite lock...',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isSocket
                            ? AppColors.successDark
                            : AppColors.warningDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
