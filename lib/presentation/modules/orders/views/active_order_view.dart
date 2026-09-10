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
import '../../dashboard/controllers/dashboard_controller.dart';
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
        OrderEntity? order = controller.selectedOrder.value;
        if (order == null && Get.isRegistered<DashboardController>()) {
          final dashActive = Get.find<DashboardController>().activeOrder.value;
          if (dashActive != null) {
            order = dashActive;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.setActiveOrder(dashActive);
            });
          }
        }
        if (order == null && controller.activeOrders.isNotEmpty) {
          order = controller.activeOrders.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.selectedOrder.value = order;
          });
        }

        if (controller.isLoading.value && order == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (order == null) {
          return RefreshIndicator(
            onRefresh: () => controller.loadOrders(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                        const SizedBox(height: 16),
                        Text('No active delivery order', style: AppTextStyles.titleMedium()),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Get.offNamed(AppRoutes.main),
                          child: const Text('Back to Dashboard'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => controller.loadOrders(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh Orders'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadOrders(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Stepper Card (5 Exact Steps)
                      _buildStatusProgressCard(order),
                      const SizedBox(height: 10),

                      // Restaurant / Pickup Details
                      _buildPickupCard(context, order),
                      const SizedBox(height: 10),

                      // Customer / Dropoff Details
                      _buildDropoffCard(context, order),
                      const SizedBox(height: 10),

                      // Order Items Checklist
                      _buildItemsCard(order),
                      if (order.notes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildInstructionsCard(order),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar: Swipe button + Red outline Cancel Delivery button (Part 8 Section 4.3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwipeButton(
                        text: order.status.nextStepActionTitle,
                        activeColor: AppColors.primary,
                        onSwiped: () => controller.advanceActiveOrderStatus(),
                      ),
                      if (order.status == OrderStatus.accepted ||
                          order.status == OrderStatus.atPickup) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const Key('active_order_cancel_button'),
                            icon: const Icon(Icons.cancel_outlined,
                                color: AppColors.error, size: 16),
                            label: const Text(
                              'Cancel Delivery',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => controller.showCancelDeliveryDialog(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required String tooltip,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusProgressCard(OrderEntity order) {
    return CustomCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: StatusBadge(
                  text: order.orderNumber.startsWith('#')
                      ? order.orderNumber
                      : '#${order.orderNumber}',
                  type: BadgeType.info,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                text: order.status.displayName,
                type: order.status == OrderStatus.delivered
                    ? BadgeType.success
                    : BadgeType.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DeliveryEarningBadge(
            amount: order.riderEarnings,
            isCompact: true,
          ),
          const SizedBox(height: 10),
          MilestoneStepper(status: order.status, showLabels: true),
        ],
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, OrderEntity order) {
    final isHeadingToStore =
        order.status == OrderStatus.accepted || order.status == OrderStatus.atPickup;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: isHeadingToStore
          ? Border.all(color: AppColors.primary.withAlpha(140), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: StatusBadge(
                  text: 'PICKUP VENDOR',
                  type: BadgeType.warning,
                  icon: Icons.storefront_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleActionButton(
                    icon: Icons.directions_rounded,
                    tooltip: '1-Tap Maps to Vendor',
                    bgColor: AppColors.primaryContainer,
                    iconColor: AppColors.primary,
                    onTap: () => MapLauncherUtil.showMapOptionsModal(
                      context: context,
                      latitude: order.pickupLat,
                      longitude: order.pickupLng,
                      title: order.pickupName,
                      address: order.pickupAddress,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildCircleActionButton(
                    icon: Icons.phone_rounded,
                    tooltip: 'Call Store',
                    bgColor: AppColors.primaryContainer,
                    iconColor: AppColors.primary,
                    onTap: () => controller.callContact(order.pickupPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.pickupName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(order.pickupAddress, style: AppTextStyles.bodySmall()),
        ],
      ),
    );
  }

  Widget _buildDropoffCard(BuildContext context, OrderEntity order) {
    final isHeadingToCustomer =
        order.status == OrderStatus.pickedUp || order.status == OrderStatus.outForDelivery;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: isHeadingToCustomer
          ? Border.all(color: AppColors.success.withAlpha(160), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: StatusBadge(
                  text: 'CUSTOMER DROPOFF',
                  type: BadgeType.success,
                  icon: Icons.location_on_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleActionButton(
                    icon: Icons.directions_rounded,
                    tooltip: '1-Tap Maps to Customer',
                    bgColor: AppColors.primaryContainer,
                    iconColor: AppColors.primary,
                    onTap: () => MapLauncherUtil.showMapOptionsModal(
                      context: context,
                      latitude: order.dropoffLat,
                      longitude: order.dropoffLng,
                      title: order.customerName,
                      address: order.dropoffAddress,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildCircleActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    tooltip: 'Message Customer',
                    bgColor: const Color(0xFFF1F5F9),
                    iconColor: AppColors.textPrimaryLight,
                    onTap: () => controller.messageContact(order.customerPhone),
                  ),
                  const SizedBox(width: 6),
                  _buildCircleActionButton(
                    icon: Icons.phone_rounded,
                    tooltip: 'Call Customer',
                    bgColor: AppColors.successLight,
                    iconColor: AppColors.successDark,
                    onTap: () => controller.callContact(order.customerPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(order.dropoffAddress, style: AppTextStyles.bodySmall()),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderEntity order) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.orderItems,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          if (item.notes.isNotEmpty)
                            Text(
                              'Note: ${item.notes}',
                              style: AppTextStyles.bodySmall(color: AppColors.secondary),
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningDark.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warningDark, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Instructions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warningDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.notes,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
