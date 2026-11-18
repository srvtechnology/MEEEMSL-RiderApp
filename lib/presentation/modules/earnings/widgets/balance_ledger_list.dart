import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/rider_ledger_entity.dart';

/// Displays the chronological Balance Ledger (`GET /mobileapi/rider/balance-transactions`).
/// Clearly differentiates:
/// - `CREDIT` + `DELIVERY_FULFILLED` (+ adds to withdrawable wallet)
/// - `CREDIT` + `COD_DELIVERY_COLLECTED` (tracked in ledger; 0 wallet balance change, cash in hand)
/// - `DEBIT`  + `PAYOUT_DISBURSED` (- deducts from withdrawable wallet)
class BalanceLedgerList extends StatelessWidget {
  final RiderBalanceLedgerEntity? ledger;
  final List<RiderBalanceTransactionEntity> filteredTransactions;
  final String selectedFilter;
  final String currency;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRetry;

  const BalanceLedgerList({
    super.key,
    required this.ledger,
    required this.filteredTransactions,
    required this.selectedFilter,
    this.currency = 'NLe',
    required this.isLoading,
    this.errorMessage,
    required this.onFilterChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    if (isLoading && ledger == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null && ledger == null) {
      return _buildErrorCard(context, isDark, textPrimary, textSecondary, borderColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Credits / Debits / Net Wallet Summary Strip
        if (ledger != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildLedgerMetric(
                    label: 'Total Credits',
                    amount: ledger!.balanceCreditsTotal,
                    color: const Color(0xFF059669),
                    textSecondary: textSecondary,
                  ),
                ),
                Container(width: 1, height: 34, color: borderColor),
                Expanded(
                  child: _buildLedgerMetric(
                    label: 'Total Disbursed',
                    amount: ledger!.balanceDebitsTotal,
                    color: const Color(0xFFDC2626),
                    textSecondary: textSecondary,
                  ),
                ),
                Container(width: 1, height: 34, color: borderColor),
                Expanded(
                  child: _buildLedgerMetric(
                    label: 'Net Wallet',
                    amount: ledger!.netBalance,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 2. Reason Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Entries', 'all', isDark, textPrimary),
              const SizedBox(width: 8),
              _buildFilterChip('Prepaid Credit', 'DELIVERY_FULFILLED', isDark, textPrimary),
              const SizedBox(width: 8),
              _buildFilterChip('COD Collected', 'COD_DELIVERY_COLLECTED', isDark, textPrimary),
              const SizedBox(width: 8),
              _buildFilterChip('Payouts', 'PAYOUT_DISBURSED', isDark, textPrimary),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Ledger Audit Trail',
                style: AppTextStyles.titleMedium(color: textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${filteredTransactions.length} ${filteredTransactions.length == 1 ? 'entry' : 'entries'}',
              style: AppTextStyles.bodySmall(color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 4. Ledger Entries List or Empty State
        if (filteredTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(Icons.menu_book_rounded, size: 42, color: textSecondary),
                const SizedBox(height: 10),
                Text(
                  'No Ledger Entries Yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedFilter == 'all'
                      ? 'Completed AfriMoney deliveries, COD deliveries, and admin payouts will appear here.'
                      : 'No transactions match this filter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                ),
              ],
            ),
          )
        else
          Column(
            children: filteredTransactions
                .map((tx) => _buildTransactionCard(context, tx, isDark, textPrimary, textSecondary, borderColor))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildLedgerMetric({
    required String label,
    required double amount,
    required Color color,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatRevenueAmount(amount, currency: currency),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, bool isDark, Color textPrimary) {
    final isSelected = selectedFilter == key;
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : textPrimary,
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onFilterChanged(key),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    RiderBalanceTransactionEntity tx,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    late final Color accentColor;
    late final Color badgeBg;
    late final IconData icon;
    late final String title;
    late final String amountPrefix;
    late final String walletImpactTag;

    if (tx.isDebit || tx.isPayoutDisbursed) {
      accentColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      badgeBg = isDark ? const Color(0xFF450A0A).withAlpha(150) : const Color(0xFFFEF2F2);
      icon = Icons.outbound_rounded;
      title = 'Payout Disbursed';
      amountPrefix = '-';
      walletImpactTag = 'DEBIT • Deducted from Wallet';
    } else if (tx.isCodCollected) {
      accentColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      badgeBg = isDark ? const Color(0xFF451A03).withAlpha(150) : const Color(0xFFFFFBEB);
      icon = Icons.payments_outlined;
      title = 'COD Delivery Fee Collected';
      amountPrefix = '';
      walletImpactTag = 'CASH IN HAND • 0 Wallet Change';
    } else {
      accentColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      badgeBg = isDark ? const Color(0xFF064E3B).withAlpha(150) : const Color(0xFFECFDF5);
      icon = Icons.add_circle_outline_rounded;
      title = 'Prepaid Delivery Credited';
      amountPrefix = '+';
      walletImpactTag = 'CREDIT • Added to Wallet';
    }

    final formattedAmt =
        '$amountPrefix${Formatters.formatRevenueAmount(tx.amount, currency: currency)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatFullDateTime(tx.createdAt),
                      style: TextStyle(fontSize: 11.5, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formattedAmt,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTag(walletImpactTag, badgeBg, accentColor),
              if (tx.orderNumber != null && tx.orderNumber!.isNotEmpty)
                _buildTag(
                  tx.orderNumber!.startsWith('#') ? tx.orderNumber! : '#${tx.orderNumber}',
                  isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  textPrimary,
                ),
              if (tx.paymentMethod != null && tx.paymentMethod!.isNotEmpty)
                _buildTag(
                  tx.paymentMethod!,
                  isDark ? const Color(0xFF1E3A8A).withAlpha(140) : const Color(0xFFEFF6FF),
                  isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                ),
              if (tx.settlementStatus != null && tx.settlementStatus!.isNotEmpty)
                _buildTag(
                  _humanizeSettlement(tx.settlementStatus!),
                  isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  textSecondary,
                ),
            ],
          ),
          if (tx.note != null && tx.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              tx.note!.trim(),
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _humanizeSettlement(String status) {
    switch (status.toUpperCase()) {
      case 'YET_TO_PAY':
        return 'Yet to Pay';
      case 'PAID_OUT':
        return 'Paid Out';
      case 'COD_COLLECTED_BY_RIDER':
        return 'COD Collected';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Could Not Load Ledger',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 40)),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
