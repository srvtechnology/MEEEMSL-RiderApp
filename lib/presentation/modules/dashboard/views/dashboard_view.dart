import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.two_wheeler_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meeem Rider',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Obx(() => Text(
                      controller.isOnline.value ? 'Online • GPS Active' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        color: controller.isOnline.value ? AppColors.success : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online / Offline Switch Hero Card
              _buildOnlineStatusCard(context),
              const SizedBox(height: 14),

              // Rider Account Status & Stats Strip
              _buildAccountStatusStrip(context),
              const SizedBox(height: 16),

              // Active Order Banner (If on a trip)
              _buildActiveOrderBanner(context),

              // Today's Earnings Summary Card
              _buildEarningsCard(context),
              const SizedBox(height: 16),

              // 4-Grid Metrics Overview
              _buildMetricsGrid(context),
              const SizedBox(height: 20),

              // Simulated Test Order Trigger (Convenient for Testing & Live Demonstration)
              _buildSimulatedOrderTrigger(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
                const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const StatusBadge(text: 'APPROVED', type: BadgeType.success),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.totalDeliveries,
                      style: AppTextStyles.labelSmall(),
                    ),
                    Text(
                      '${controller.totalDeliveries.value} Trips',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOnlineStatusCard(BuildContext context) {
    return Obx(() {
      final isOnline = controller.isOnline.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.successLight : Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline ? AppColors.success.withAlpha(80) : AppColors.lightCardBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.offlineGray,
                    shape: BoxShape.circle,
                    boxShadow: isOnline
                        ? [
                            BoxShadow(
                              color: AppColors.success.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? AppStrings.youAreOnline : AppStrings.youAreOffline,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isOnline ? AppColors.successDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online • Periodic GPS tracking active' : AppStrings.goOnlineToEarn,
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ],
            ),
            Switch.adaptive(
              value: isOnline,
              activeTrackColor: AppColors.success,
              onChanged: (_) => controller.toggleOnline(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActiveOrderBanner(BuildContext context) {
    return Obx(() {
      final order = controller.activeOrder.value;
      if (order == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: CustomCard(
          backgroundColor: AppColors.primaryContainer,
          border: Border.all(color: AppColors.primaryLight.withAlpha(60), width: 1.5),
          onTap: () => Get.toNamed(AppRoutes.activeOrder),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    text: 'STEP: ${order.status.displayName.toUpperCase()}',
                    type: BadgeType.info,
                    icon: Icons.navigation_rounded,
                  ),
                  Text(
                    Formatters.formatCurrency(order.riderEarnings),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Destination: ${order.dropoffAddress}',
                style: AppTextStyles.titleMedium(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer: ${order.customerName}',
                    style: AppTextStyles.bodySmall(),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: AppTextStyles.labelSmall(color: AppColors.primary),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardHeaderGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.todaysEarnings,
                style: AppTextStyles.labelMedium(color: Colors.white70),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.earnings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Wallet',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                Formatters.formatCurrency(controller.todayEarnings.value),
                style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 36),
              )),
          const SizedBox(height: 8),
          Text(
            'Updated just now • Instant payout available',
            style: AppTextStyles.bodySmall(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _buildMetricItem(
              context,
              title: AppStrings.completedOrders,
              value: '${controller.todayDeliveries.value} Trips Today',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.onlineHours,
              value: '${controller.onlineHours.value} hrs',
              icon: Icons.access_time_rounded,
              color: AppColors.info,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.acceptanceRate,
              value: '${controller.acceptanceRate.value}%',
              icon: Icons.thumb_up_alt_outlined,
              color: AppColors.secondary,
            ),
            _buildMetricItem(
              context,
              title: AppStrings.rating,
              value: '★ ${controller.rating.value}',
              icon: Icons.star_border_rounded,
              color: Colors.amber,
            ),
          ],
        ));
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall(),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedOrderTrigger(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚡ Test Incoming Order Alert',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  'Trigger a live order ping with 60s countdown timer',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(80, 36),
            ),
            onPressed: () => controller.simulateIncomingOrder(),
            child: const Text('Simulate (60s)', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
