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
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Delivered', 'delivered'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cancelled', 'cancelled'),
                  ],
                )),
          ),
          const Divider(),

          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.orderHistory.isEmpty) {
                return Center(
                  child: Text('No orders found', style: AppTextStyles.bodyMedium()),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orderHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = controller.orderHistory[index];
                  return CustomCard(
                    onTap: () => Get.to(() => OrderDetailsView(order: order)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderNumber.startsWith('#')
                                  ? order.orderNumber
                                  : '#${order.orderNumber}',
                              style: AppTextStyles.titleMedium(),
                            ),
                            StatusBadge(
                              text: order.status.displayName,
                              type: order.status == OrderStatus.delivered
                                  ? BadgeType.success
                                  : BadgeType.warning,
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
              );
            }),
          ),
        ],
      ),
    );
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
