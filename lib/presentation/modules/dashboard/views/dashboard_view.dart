import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/active_delivery_card.dart';
import '../widgets/incoming_offer_card.dart';
import '../widgets/telemetry_radar_card.dart';
import '../../../routes/app_routes.dart';

/// Redesigned Rider App Dashboard
/// Conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Online / Shift Status Hero Switch
              _buildOnlineStatusCard(context),
              const SizedBox(height: 14),

              // 2. Account Status & Delivery Count Strip
              _buildAccountStatusStrip(context),
              const SizedBox(height: 16),

              // 3. Dynamic Center Stage:
              //    - Case A: High-Priority 60s Waterfall Offer (Section 2)
              //    - Case B: Active Delivery Mission Cockpit (Sections 3 & 5)
              //    - Case C: Auto-Dispatch Radar Mode (Section 1 & 7.4)
              _buildDynamicCenterStage(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // Rider Avatar / Initials with Status Ring
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    controller.riderInitials,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Obx(() => Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: controller.isOnline.value
                            ? AppColors.success
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.riderName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Section 1 Telemetry Connectivity Badge
                _buildTelemetryStatusPill(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 24),
          onPressed: () => Get.toNamed(AppRoutes.notifications),
        ),
      ],
    );
  }

  Widget _buildTelemetryStatusPill() {
    return Obx(() {
      final isOnline = controller.isOnline.value;
      if (!isOnline) {
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Offline',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        );
      }

      final loc = controller.locationService;
      final mode = loc?.telemetryMode.value ?? TelemetryMode.idle;
      final isSocket = mode == TelemetryMode.socketStreaming;

      return Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isSocket ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isSocket ? AppColors.success : AppColors.warning)
                      .withAlpha(120),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isSocket ? 'Socket.IO Live (4s)' : 'REST Fallback',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSocket ? AppColors.successDark : AppColors.warningDark,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOnlineStatusCard(BuildContext context) {
    return Obx(() {
      final isOnline = controller.isOnline.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.successLight : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isOnline
                ? AppColors.success.withAlpha(70)
                : AppColors.lightCardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? AppColors.success.withAlpha(20)
                  : Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.offlineGray,
                    shape: BoxShape.circle,
                    boxShadow: isOnline
                        ? [
                            BoxShadow(
                              color: AppColors.success.withAlpha(120),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? "You're Online" : "You're Offline",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isOnline
                              ? AppColors.successDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        isOnline
                            ? 'Ready for dispatch • GPS telemetry active'
                            : AppStrings.goOnlineToEarn,
                        style: AppTextStyles.bodySmall(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: isOnline,
                  activeTrackColor: AppColors.success,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (_) => controller.toggleOnline(),
                ),
              ],
            ),
            if (isOnline) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            controller.riderZone,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.two_wheeler_rounded,
                          size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        controller.vehicleTypeInfo,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAccountStatusStrip(BuildContext context) {
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.accountStatus,
                      style: AppTextStyles.labelSmall(),
                    ),
                    Text(
                      controller.approvalStatus.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const StatusBadge(text: 'APPROVED', type: BadgeType.success),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.totalDeliveries,
                  style: AppTextStyles.labelSmall(),
                ),
                Text(
                  '${controller.totalDeliveries.value} Trips',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDynamicCenterStage(BuildContext context) {
    return Obx(() {
      // 1. High Priority 60s Waterfall Offer (Section 2)
      final incoming = controller.incomingOrder.value;
      if (incoming != null) {
        return IncomingOfferCard(order: incoming);
      }

      // 2. Active Delivery Mission Cockpit (Sections 3 & 5)
      final active = controller.activeOrder.value;
      if (active != null) {
        return ActiveDeliveryCard(order: active);
      }

      // 3. Online Radar Mode (Section 1 & 7.4)
      if (controller.isOnline.value) {
        return const TelemetryRadarCard();
      }

      // 4. Offline Empty Notice
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightCardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.power_settings_new_rounded,
                  size: 28, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Shift is Currently Paused',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Turn on the switch above to connect to Socket.IO and begin receiving customer delivery requests.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
      );
    });
  }
}
