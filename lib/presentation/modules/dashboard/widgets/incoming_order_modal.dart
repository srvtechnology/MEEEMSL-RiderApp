import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/delivery_earning_badge.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/dashboard_controller.dart';

class IncomingOrderModal extends GetView<DashboardController> {
  final OrderEntity order;

  const IncomingOrderModal({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Countdown Ring
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.newOrderRequest,
                    style: AppTextStyles.headlineMedium(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order ${order.orderNumber.startsWith('#') ? order.orderNumber : '#${order.orderNumber}'}',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              // Circular Countdown Widget
              Obx(() => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: controller.countdownSeconds.value / 60.0,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          backgroundColor: AppColors.secondaryContainer,
                        ),
                      ),
                      Text(
                        '${controller.countdownSeconds.value}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 20),

          // Earnings Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.cardHeaderGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.estimatedEarnings,
                      style: AppTextStyles.labelSmall(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(order.riderEarnings),
                      style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 30),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDistance(order.distanceKm),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDuration(order.estimatedDurationMin),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: DeliveryEarningBadge(amount: order.riderEarnings),
          ),
          const SizedBox(height: 16),

          // Pickup & Dropoff Route Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.pickupName,
                            style: AppTextStyles.titleMedium(),
                          ),
                          Text(
                            order.pickupAddress,
                            style: AppTextStyles.bodySmall(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: AppTextStyles.titleMedium(),
                          ),
                          Text(
                            order.dropoffAddress,
                            style: AppTextStyles.bodySmall(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Accept (Warm Amber CTA) & Decline
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomButton(
                  text: AppStrings.declineOrder,
                  type: ButtonType.outline,
                  customColor: AppColors.error,
                  onPressed: () => controller.declineIncomingOrder('Rider busy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: AppStrings.acceptOrder,
                  type: ButtonType.secondary,
                  icon: Icons.check_circle_rounded,
                  onPressed: () => controller.acceptIncomingOrder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
