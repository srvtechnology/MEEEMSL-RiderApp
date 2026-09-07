import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/map_launcher_util.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/delivery_earning_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/swipe_button.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/orders_controller.dart';
import '../widgets/milestone_stepper.dart';
import '../../../routes/app_routes.dart';

class ActiveOrderView extends GetView<OrdersController> {
  const ActiveOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.activeOrder),
        actions: [
          IconButton(
            tooltip: 'Live Navigation',
            icon: const Icon(Icons.navigation_rounded, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.navigation),
          ),
        ],
      ),
      body: Obx(() {
        final order = controller.selectedOrder.value;
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                Text('No active delivery order', style: AppTextStyles.titleMedium()),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.offNamed(AppRoutes.main),
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Stepper Card (5 Exact Steps)
                    _buildStatusProgressCard(order),
                    const SizedBox(height: 16),

                    // Restaurant / Pickup Details
                    _buildPickupCard(context, order),
                    const SizedBox(height: 16),

                    // Customer / Dropoff Details
                    _buildDropoffCard(context, order),
                    const SizedBox(height: 16),

                    // Order Items Checklist
                    _buildItemsCard(order),
                    const SizedBox(height: 16),

                    // Special Instructions
                    if (order.notes.isNotEmpty) ...[
                      _buildInstructionsCard(order),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Swipe Confirmation Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                child: SwipeButton(
                  text: order.status.nextStepActionTitle,
                  activeColor: AppColors.primary,
                  onSwiped: () => controller.advanceActiveOrderStatus(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusProgressCard(OrderEntity order) {
    return CustomCard(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(
                    text: order.orderNumber.startsWith('#') ? order.orderNumber : '#${order.orderNumber}',
                    type: BadgeType.info,
                  ),
                  const SizedBox(width: 8),
                  DeliveryEarningBadge(amount: order.riderEarnings, isCompact: true),
                ],
              ),
              StatusBadge(
                text: order.status.displayName,
                type: order.status == OrderStatus.delivered ? BadgeType.success : BadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          MilestoneStepper(status: order.status, showLabels: true),
        ],
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, OrderEntity order) {
    final isHeadingToStore = order.status == OrderStatus.accepted || order.status == OrderStatus.atPickup;

    return CustomCard(
      border: isHeadingToStore
          ? Border.all(color: AppColors.warningDark.withAlpha(120), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(text: 'PICKUP VENDOR', type: BadgeType.warning, icon: Icons.storefront_rounded),
              Row(
                children: [
                  IconButton(
                    tooltip: '1-Tap Maps to Vendor',
                    icon: const Icon(Icons.directions, size: 20, color: AppColors.primary),
                    onPressed: () => MapLauncherUtil.showMapOptionsModal(
                      context: context,
                      latitude: order.pickupLat,
                      longitude: order.pickupLng,
                      title: order.pickupName,
                      address: order.pickupAddress,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Call Store',
                    icon: const Icon(Icons.phone, size: 20, color: AppColors.primary),
                    onPressed: () => controller.callContact(order.pickupPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.pickupName, style: AppTextStyles.titleLarge()),
          const SizedBox(height: 2),
          Text(order.pickupAddress, style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildDropoffCard(BuildContext context, OrderEntity order) {
    final isHeadingToCustomer = order.status == OrderStatus.pickedUp || order.status == OrderStatus.outForDelivery;

    return CustomCard(
      border: isHeadingToCustomer
          ? Border.all(color: AppColors.success.withAlpha(120), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(text: 'CUSTOMER DROPOFF', type: BadgeType.success, icon: Icons.location_on_rounded),
              Row(
                children: [
                  IconButton(
                    tooltip: '1-Tap Maps to Customer',
                    icon: const Icon(Icons.directions, size: 20, color: AppColors.primary),
                    onPressed: () => MapLauncherUtil.showMapOptionsModal(
                      context: context,
                      latitude: order.dropoffLat,
                      longitude: order.dropoffLng,
                      title: order.customerName,
                      address: order.dropoffAddress,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Message Customer',
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primary),
                    onPressed: () => controller.messageContact(order.customerPhone),
                  ),
                  IconButton(
                    tooltip: 'Call Customer',
                    icon: const Icon(Icons.phone, size: 20, color: AppColors.primary),
                    onPressed: () => controller.callContact(order.customerPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.customerName, style: AppTextStyles.titleLarge()),
          const SizedBox(height: 2),
          Text(order.dropoffAddress, style: AppTextStyles.bodyMedium()),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderEntity order) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.orderItems, style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.bodyMedium()),
                          if (item.notes.isNotEmpty)
                            Text('Note: ${item.notes}', style: AppTextStyles.bodySmall(color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningDark.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warningDark, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Instructions',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warningDark),
                ),
                const SizedBox(height: 4),
                Text(
                  order.notes,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
