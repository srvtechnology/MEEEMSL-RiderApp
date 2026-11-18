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
    this.currency = 'NLe',
  });

  @override
  State<RevenueDeliveryCard> createState() => _RevenueDeliveryCardState();
}

class _RevenueDeliveryCardState extends State<RevenueDeliveryCard> {
  bool _isExpanded = false;

  String _formatAmount(double value) {
    return Formatters.formatRevenueAmount(value, currency: widget.currency);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBorder = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

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
              ? cardBorder
              : const Color(0xFF93C5FD).withAlpha(isDark ? 160 : 140),
          width: isDelivered ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 24 : (isDelivered ? 8 : 14)),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Order #, Date, Delivery Status Badge)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        del.orderNumber.startsWith('#')
                            ? del.orderNumber
                            : '#${del.orderNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              Formatters.formatShortDateTime(date),
                              style: AppTextStyles.bodySmall(color: textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(isDelivered, del.status, isDark),
              ],
            ),
          ),

          // 2. Payment Channel & Settlement Status Badges (Section 8.2)
          if (del.paymentMethod != null || del.settlementStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (del.paymentMethod != null && del.paymentMethod!.isNotEmpty)
                    _buildPaymentMethodBadge(del.paymentMethod!, isDark),
                  if (del.settlementStatus != null && del.settlementStatus!.isNotEmpty)
                    _buildSettlementStatusBadge(del.settlementStatus!, isDark),
                ],
              ),
            ),

          const Divider(height: 1),

          // 3. Locations (Store Pickup & Customer Drop)
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
                        color: isDark
                            ? const Color(0xFF1E3A8A).withAlpha(110)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            del.store.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (del.store.address.isNotEmpty)
                            Text(
                              del.store.address,
                              style: AppTextStyles.bodySmall(color: textSecondary),
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
                        color: isDark
                            ? const Color(0xFF064E3B).withAlpha(120)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            del.customer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (del.customer.dropAddress.isNotEmpty)
                            Text(
                              del.customer.dropAddress,
                              style: AppTextStyles.bodySmall(color: textSecondary),
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

          // 4. COD Cash Collected Strip (if COD cash collected)
          if (del.codAmountCollected != null && del.codAmountCollected! > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF451A03).withAlpha(140)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withAlpha(isDark ? 160 : 120),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'COD Cash Collected (Doorstep)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatAmount(del.codAmountCollected!),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),

          // 5. Payout Disbursement Receipt Strip (if PAID_OUT)
          if ((del.settlementStatus ?? '').toUpperCase() == 'PAID_OUT' &&
              (del.payoutReference != null || del.payoutDisbursedAt != null))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF064E3B).withAlpha(110)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(110),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        if (del.payoutMethod != null && del.payoutMethod!.isNotEmpty)
                          'Paid via ${del.payoutMethod}',
                        if (del.payoutReference != null && del.payoutReference!.isNotEmpty)
                          'Ref: ${del.payoutReference}',
                        if (del.payoutDisbursedAt != null)
                          Formatters.formatShortDateTime(del.payoutDisbursedAt!),
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 6. Package Items Accordion / Preview
          Container(
            color: isDark
                ? const Color(0xFF0F172A).withAlpha(130)
                : const Color(0xFFF8FAFC),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Items in this package (${del.totalItemsCount})',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: del.items.isEmpty
                        ? Text(
                            'No itemized product details available.',
                            style: TextStyle(fontSize: 12, color: textSecondary),
                          )
                        : Column(
                            children: del.items
                                .map((item) => _buildItemRow(
                                    item, isDark, textPrimary, textSecondary))
                                .toList(),
                          ),
                  ),
                ],
              ],
            ),
          ),

          // 7. Footer: Delivery Fee & Realized Earnings Badge (Wrap prevents narrow-screen overflow)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                // Left: Delivery Fee
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delivery Fee',
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatAmount(del.deliveryCharge),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),

                // Right: Realized Total Amount Badge (Green if delivered, Amber if pending)
                if (isDelivered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withAlpha(140)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF059669),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Total Earned: ${_formatAmount(del.totalAmount ?? del.deliveryCharge)}',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF065F46),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF451A03).withAlpha(150)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Pending (Upon Delivery)',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF92400E),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildPaymentMethodBadge(String rawMethod, bool isDark) {
    final normalized = rawMethod.toUpperCase();
    final isPrepaid = normalized == 'AFRIMONEY';

    final bgColor = isPrepaid
        ? (isDark ? const Color(0xFF312E81).withAlpha(150) : const Color(0xFFEEF2FF))
        : (isDark ? const Color(0xFF451A03).withAlpha(150) : const Color(0xFFFFF7ED));
    final borderColor = isPrepaid
        ? const Color(0xFF6366F1).withAlpha(130)
        : const Color(0xFFF97316).withAlpha(140);
    final fgColor = isPrepaid
        ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
        : (isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPrepaid ? Icons.phone_android_rounded : Icons.payments_outlined,
            size: 12.5,
            color: fgColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isPrepaid ? 'AFRIMONEY (Prepaid)' : 'COD (Cash)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fgColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementStatusBadge(String rawSettlement, bool isDark) {
    final normalized = rawSettlement.toUpperCase();
    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String label;

    switch (normalized) {
      case 'YET_TO_PAY':
        bg = isDark ? const Color(0xFF0C4A6E).withAlpha(150) : const Color(0xFFE0F2FE);
        border = const Color(0xFF0284C7).withAlpha(130);
        fg = isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1);
        icon = Icons.account_balance_wallet_outlined;
        label = 'Yet to Pay (In Wallet)';
        break;
      case 'PAID_OUT':
        bg = isDark ? const Color(0xFF064E3B).withAlpha(150) : const Color(0xFFECFDF5);
        border = const Color(0xFF10B981).withAlpha(140);
        fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
        icon = Icons.check_circle_outline_rounded;
        label = 'Paid Out';
        break;
      case 'COD_COLLECTED_BY_RIDER':
        bg = isDark ? const Color(0xFF451A03).withAlpha(150) : const Color(0xFFFFFBEB);
        border = const Color(0xFFF59E0B).withAlpha(140);
        fg = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
        icon = Icons.handshake_outlined;
        label = 'COD Collected (Cash in Hand)';
        break;
      case 'PENDING':
      default:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        border = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
        fg = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
        icon = Icons.schedule_rounded;
        label = 'Pending Settlement';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isDelivered, String rawStatus, bool isDark) {
    if (isDelivered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF064E3B).withAlpha(140)
              : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withAlpha(120)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: 13,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
            ),
            const SizedBox(width: 4),
            Text(
              'Delivered',
              style: TextStyle(
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
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

      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 165),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E3A8A).withAlpha(150)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6).withAlpha(120)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1D4ED8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildItemRow(
    RevenueOrderItemEntity item,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final thumbBg = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                      color: thumbBg,
                      child: Icon(Icons.image_outlined, size: 16, color: textSecondary),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 38,
                      height: 38,
                      color: thumbBg,
                      child: Icon(Icons.shopping_bag_outlined, size: 16, color: textSecondary),
                    ),
                  )
                : Container(
                    width: 38,
                    height: 38,
                    color: thumbBg,
                    child: Icon(Icons.shopping_bag_outlined, size: 16, color: textSecondary),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity}x ${item.name}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantName != null && item.variantName!.isNotEmpty)
                  Text(
                    item.variantName!,
                    style: AppTextStyles.bodySmall(color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Fee: ${_formatAmount(item.shippingAmount)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
              Text(
                _formatAmount(item.price),
                style: TextStyle(
                  fontSize: 10.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
