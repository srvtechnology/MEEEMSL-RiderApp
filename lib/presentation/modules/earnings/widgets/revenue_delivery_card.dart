import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/rider_revenue_entity.dart';

class RevenueDeliveryCard extends StatefulWidget {
  final RiderRevenueDeliveryEntity delivery;
  final String currency;

  const RevenueDeliveryCard({
    super.key,
    required this.delivery,
    this.currency = 'Nle',
  });

  @override
  State<RevenueDeliveryCard> createState() => _RevenueDeliveryCardState();
}

class _RevenueDeliveryCardState extends State<RevenueDeliveryCard> {
  bool _isExpanded = false;

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      final parts = value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '${widget.currency} $parts';
    } else {
      final whole = value.truncate();
      final decimals = ((value - whole).abs() * 100).round().toString().padLeft(2, '0');
      final parts = whole.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '${widget.currency} $parts.$decimals';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${Formatters.formatShortDate(date)}, ${Formatters.formatTime(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final del = widget.delivery;
    final isDelivered = del.isDelivered;
    final date = del.deliveredAt ?? del.offeredAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDelivered
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF93C5FD).withAlpha(120),
          width: isDelivered ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDelivered ? 8 : 14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Order #, Date, Status Badge)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${del.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(date),
                          style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusBadge(isDelivered, del.status),
              ],
            ),
          ),

          const Divider(height: 1),

          // 2. Locations (Store Pickup & Customer Drop)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                // Store Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            del.store.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          if (del.store.address.isNotEmpty)
                            Text(
                              del.store.address,
                              style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Customer Drop
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            del.customer.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          if (del.customer.dropAddress.isNotEmpty)
                            Text(
                              del.customer.dropAddress,
                              style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
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

          // 3. Package Items Accordion / Preview
          Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B).withAlpha(120)
                : const Color(0xFFF8FAFC),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Items in this package (${del.totalItemsCount})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      children: del.items.map((item) => _buildItemRow(item)).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 4. Footer & Realized Total Amount Rule
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Delivery Charge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Charge',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatAmount(del.deliveryCharge),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),

                // Right: Realized Total Amount Badge (Green if delivered, Amber if pending)
                if (isDelivered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Text(
                          'Total Earned: ${_formatAmount(del.totalAmount ?? del.deliveryCharge)}',
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, size: 15, color: Color(0xFFD97706)),
                        SizedBox(width: 5),
                        Text(
                          'Pending (Upon Delivery)',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDelivered, String rawStatus) {
    if (isDelivered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withAlpha(120)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 13, color: Color(0xFF059669)),
            SizedBox(width: 4),
            Text(
              'Delivered',
              style: TextStyle(
                color: Color(0xFF047857),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else {
      final formatted = rawStatus.replaceAll('_', ' ').toLowerCase();
      final title = formatted.isNotEmpty
          ? '${formatted[0].toUpperCase()}${formatted.substring(1)}'
          : 'In Progress';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withAlpha(120)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(
              'In Progress - $title',
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildItemRow(RevenueOrderItemEntity item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Image / Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.image != null && item.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 38,
                      height: 38,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined, size: 16, color: Colors.grey),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 38,
                      height: 38,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 38,
                    height: 38,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 10),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity}x ${item.name}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantName != null && item.variantName!.isNotEmpty)
                  Text(
                    item.variantName!,
                    style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Item Shipping / Delivery Fee
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Fee: ${_formatAmount(item.shippingAmount)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _formatAmount(item.price),
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
