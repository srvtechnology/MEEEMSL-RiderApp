import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/map_launcher_util.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/delivery_earning_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/order_entity.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import 'emergency_reassign_dialog.dart';

/// Comprehensive interactive delivery mission cockpit
/// Conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md Sections 3, 5, 6 & 8
class ActiveDeliveryCard extends StatelessWidget {
  final OrderEntity order;

  const ActiveDeliveryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    final isHeadingToStore =
        order.status == OrderStatus.accepted || order.status == OrderStatus.atPickup;

    final actionLabel = _getActionLabel(order.status);
    final actionIcon = _getActionIcon(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withAlpha(60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(120),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.orderNumber.startsWith('#')
                              ? order.orderNumber
                              : '#${order.orderNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: StatusBadge(
                          text: order.status.displayName.toUpperCase(),
                          type: BadgeType.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DeliveryEarningBadge(amount: order.riderEarnings),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Milestone Stepper Pipeline (Section 5.1 & 8)
                _buildMilestonePipeline(context, order.status),
                const SizedBox(height: 18),

                // Destination and Route Information
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightCardBorder),
                  ),
                  child: Column(
                    children: [
                      // Pickup Store Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isHeadingToStore
                                  ? AppColors.primaryContainer
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 16,
                              color: isHeadingToStore
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 2,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'PICKUP STORE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isHeadingToStore
                                            ? AppColors.primary
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (isHeadingToStore)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'CURRENT TARGET',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.pickupName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.phone_outlined,
                                    size: 18, color: AppColors.primary),
                                onPressed: () => _callPhone(order.pickupPhone),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.navigation_outlined,
                                    size: 18, color: AppColors.primary),
                                onPressed: () => _openMaps(
                                  order.pickupLat,
                                  order.pickupLng,
                                  order.pickupName,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),

                      // Customer Dropoff Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: !isHeadingToStore
                                  ? AppColors.successLight
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: !isHeadingToStore
                                  ? AppColors.success
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 2,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'CUSTOMER DROPOFF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: !isHeadingToStore
                                            ? AppColors.successDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (!isHeadingToStore)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'CURRENT TARGET',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.phone_outlined,
                                    size: 18, color: AppColors.success),
                                onPressed: () => _callPhone(order.customerPhone),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                                icon: const Icon(Icons.navigation_outlined,
                                    size: 18, color: AppColors.success),
                                onPressed: () => _openMaps(
                                  order.dropoffLat,
                                  order.dropoffLng,
                                  order.customerName,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Milestone Advancement Button
                CustomButton(
                  text: actionLabel,
                  icon: actionIcon,
                  customColor: AppColors.primary,
                  height: 48,
                  onPressed: () => controller.advanceActiveOrderMilestone(),
                ),
                const SizedBox(height: 12),

                // Full Trip Cockpit View & Emergency Reassign Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Get.dialog(
                        EmergencyReassignDialog(order: order),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.error),
                          SizedBox(width: 4),
                          Text(
                            'Emergency Reassign',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (Get.isRegistered<OrdersController>()) {
                          Get.find<OrdersController>().selectedOrder.value = order;
                        }
                        Get.toNamed(AppRoutes.navigation);
                      },
                      child: Row(
                        children: [
                          Text(
                            'Open Turn-by-Turn',
                            style: AppTextStyles.labelSmall(
                                color: AppColors.primary),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonePipeline(BuildContext context, OrderStatus status) {
    final steps = [
      {'name': 'Accepted', 'status': OrderStatus.accepted},
      {'name': 'At Store', 'status': OrderStatus.atPickup},
      {'name': 'Picked Up', 'status': OrderStatus.pickedUp},
      {'name': 'Delivering', 'status': OrderStatus.outForDelivery},
      {'name': 'Delivered', 'status': OrderStatus.delivered},
    ];

    final currentIndex = _getStatusIndex(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DELIVERY MILESTONE',
              style: AppTextStyles.labelSmall(),
            ),
            Text(
              status.stepNumberText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentIndex;
            final isCurrent = index == currentIndex;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : (isCurrent ? AppColors.primary : const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isCurrent ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < currentIndex
                            ? AppColors.success
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.atPickup:
        return 1;
      case OrderStatus.pickedUp:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      default:
        return 0;
    }
  }

  String _getActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return 'Arrived at Store';
      case OrderStatus.atPickup:
        return 'Confirm Items Picked Up';
      case OrderStatus.pickedUp:
        return 'Start Journey to Customer';
      case OrderStatus.outForDelivery:
        return 'Complete Delivery (OTP)';
      default:
        return 'View Active Delivery';
    }
  }

  IconData _getActionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return Icons.storefront_rounded;
      case OrderStatus.atPickup:
        return Icons.inventory_2_rounded;
      case OrderStatus.pickedUp:
        return Icons.two_wheeler_rounded;
      case OrderStatus.outForDelivery:
        return Icons.verified_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps(double lat, double lng, String title) async {
    await MapLauncherUtil.openGoogleMaps(
      latitude: lat,
      longitude: lng,
      label: title,
    );
  }
}
