import '../../../../domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/delivery_earning_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/orders_controller.dart';
import 'order_details_view.dart';

class OrderHistoryView extends GetView<OrdersController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Delivered', 'delivered'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', 'cancelled'),
                    ],
                  ),
                )),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orderHistory.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.orderHistory.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshOrders,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  size: 56,
                                  color: AppColors.primary.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getEmptyTitle(),
                                style: AppTextStyles.titleMedium().copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getEmptySubtitle(),
                                style: AppTextStyles.bodySmall().copyWith(color: AppColors.textSecondaryLight),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => controller.loadOrders(),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Refresh Deliveries'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
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
                onRefresh: controller.refreshOrders,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.orderHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = controller.orderHistory[index];
                    final isActive = order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled;
                    final badgeType = order.status == OrderStatus.delivered
                        ? BadgeType.success
                        : (order.status == OrderStatus.cancelled ? BadgeType.error : BadgeType.info);

                    return CustomCard(
                      onTap: () => Get.to(() => OrderDetailsView(order: order)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    order.orderNumber.startsWith('#')
                                        ? order.orderNumber
                                        : '#${order.orderNumber}',
                                    style: AppTextStyles.titleMedium(),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'IN PROGRESS',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              StatusBadge(
                                text: order.status.displayName,
                                type: badgeType,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(order.pickupName, style: AppTextStyles.bodyLarge()),
                          const SizedBox(height: 2),
                          Text('To: ${order.dropoffAddress}', style: AppTextStyles.bodySmall()),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Formatters.formatDate(order.createdAt),
                                style: AppTextStyles.bodySmall(),
                              ),
                              DeliveryEarningBadge(amount: order.riderEarnings, isCompact: true),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getEmptyTitle() {
    switch (controller.historyFilter.value) {
      case 'active':
        return 'No active deliveries';
      case 'delivered':
        return 'No delivered orders yet';
      case 'cancelled':
        return 'No cancelled deliveries';
      default:
        return 'No orders found';
    }
  }

  String _getEmptySubtitle() {
    switch (controller.historyFilter.value) {
      case 'active':
        return 'New delivery assignments will appear here once accepted.';
      case 'delivered':
        return 'Completed deliveries and realized earnings will be listed here.';
      case 'cancelled':
        return 'Trips that were cancelled or timed out will be shown here.';
      default:
        return 'Deliveries assigned to you will appear here once dispatched.';
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.historyFilter.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => controller.filterHistory(value),
    );
  }
}
