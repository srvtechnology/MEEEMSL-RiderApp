import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/order_entity.dart';

class OrderDetailsView extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip Details ${order.orderNumber.startsWith('#') ? order.orderNumber : '#${order.orderNumber}'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fare Summary Hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardHeaderGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip Payout', style: AppTextStyles.labelSmall(color: Colors.white70)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Formatters.formatCurrency(order.riderEarnings),
                            style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(
                    text: order.status == OrderStatus.delivered
                        ? 'COMPLETED'
                        : order.status.displayName.toUpperCase(),
                    type: order.status == OrderStatus.delivered
                        ? BadgeType.success
                        : (order.status == OrderStatus.cancelled ? BadgeType.error : BadgeType.info),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Summary
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Route', style: AppTextStyles.titleMedium()),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.pickupName, style: AppTextStyles.titleSmall()),
                            Text(order.pickupAddress, style: AppTextStyles.bodySmall()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.customerName, style: AppTextStyles.titleSmall()),
                            Text(order.dropoffAddress, style: AppTextStyles.bodySmall()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(AppStrings.orderItems, style: AppTextStyles.titleMedium()),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 10),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                              child: Text(
                                item.name,
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Proof of Delivery Photo (Part 3 Section 4.3 & 5.3)
            if (order.proofPhotoUrl != null && order.proofPhotoUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Handover Proof Photo', style: AppTextStyles.titleMedium()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: order.proofPhotoUrl!.startsWith('http')
                          ? Image.network(
                              order.proofPhotoUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 120,
                                color: AppColors.lightSurfaceVariant,
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                ),
                              ),
                            )
                          : Image.file(
                              File(order.proofPhotoUrl!),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 120,
                                color: AppColors.lightSurfaceVariant,
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
