import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wallet),
      ),
      body: Obx(() {
        final data = controller.earningsData.value;
        if (data == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadEarnings(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Card
                _buildAvailableBalanceCard(data?.availablePayout ?? 642.50),
                const SizedBox(height: 16),

                // Period Switcher
                _buildPeriodSelector(),
                const SizedBox(height: 16),

                // Weekly Bar Chart Graphic
                _buildBarChart(data),
                const SizedBox(height: 16),

                // Earnings Breakdown
                _buildBreakdownCard(data),
                const SizedBox(height: 16),

                // Recent Transactions
                _buildTransactionsList(data),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvailableBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.cardHeaderGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.availableForPayout, style: AppTextStyles.labelMedium(color: Colors.white70)),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(balance),
            style: AppTextStyles.earningsAmount(color: Colors.white, fontSize: 34),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: AppStrings.cashOut,
            type: ButtonType.secondary,
            height: 44,
            icon: Icons.flash_on_rounded,
            onPressed: () => controller.openPayoutModal(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Obx(() => Row(
          children: [
            _buildTabChip('Daily', 'daily'),
            const SizedBox(width: 8),
            _buildTabChip('Weekly', 'weekly'),
            const SizedBox(width: 8),
            _buildTabChip('Monthly', 'monthly'),
          ],
        ));
  }

  Widget _buildTabChip(String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(dynamic data) {
    if (data == null) return const SizedBox.shrink();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Performance', style: AppTextStyles.titleMedium()),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: (data.dailyData as List).map<Widget>((item) {
                final heightFactor = item.amount > 0 ? (item.amount / 200.0).clamp(0.1, 1.0) : 0.05;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.amount > 0 ? '\$${item.amount.toInt()}' : '',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: (90 * heightFactor).toDouble(),
                      decoration: BoxDecoration(
                        color: item.amount > 0 ? AppColors.primary : AppColors.lightCardBorder,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(item.day, style: AppTextStyles.labelSmall()),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(dynamic data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout Breakdown', style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          _buildBreakdownRow(AppStrings.baseFare, data?.basePay ?? 598.00),
          _buildBreakdownRow(AppStrings.customerTips, data?.tips ?? 184.20, isHighlight: true),
          _buildBreakdownRow(AppStrings.surgeBonus, data?.surgeBonuses ?? 110.00),
          const Divider(height: 20),
          _buildBreakdownRow('Total Gross', data?.weeklyEarnings ?? 892.20, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String title, double amount, {bool isHighlight = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)
                : AppTextStyles.bodyMedium(),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isHighlight ? AppColors.successDark : (isTotal ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(dynamic data) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.payoutHistory, style: AppTextStyles.titleMedium()),
          const SizedBox(height: 12),
          if (data?.recentTransactions != null)
            ...((data.recentTransactions as List).map((tx) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: tx.amount > 0 ? AppColors.successLight : AppColors.primaryContainer,
                    child: Icon(
                      tx.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.amount > 0 ? AppColors.successDark : AppColors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(tx.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(Formatters.formatShortDate(tx.date), style: AppTextStyles.bodySmall()),
                  trailing: Text(
                    Formatters.formatCurrency(tx.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tx.amount > 0 ? AppColors.successDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ))),
        ],
      ),
    );
  }
}
