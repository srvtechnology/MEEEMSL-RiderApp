import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../domain/entities/rider_revenue_entity.dart';
import '../controllers/earnings_controller.dart';
import '../widgets/revenue_delivery_card.dart';
import '../widgets/revenue_kpi_card.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myRevenue),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.amber),
            tooltip: AppStrings.cashOut,
            onPressed: () => controller.openPayoutModal(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.loadRevenue(),
          ),
        ],
      ),
      body: Obx(() {
        final revenue = controller.revenueData.value;
        if (revenue == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = revenue?.summary ??
            const RiderRevenueSummaryEntity(
              totalDeliveredRevenue: 0,
              pendingInProgressRevenue: 0,
              deliveredCount: 0,
              inProgressCount: 0,
              totalDeliveriesCount: 0,
              currency: 'NLe',
            );

        return RefreshIndicator(
          onRefresh: () => controller.loadRevenue(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top KPI Summary Cards (Section 5.1)
                RevenueKpiCard.delivered(
                  amount: summary.totalDeliveredRevenue,
                  count: summary.deliveredCount,
                  currency: summary.currency,
                ),
                const SizedBox(height: 12),
                RevenueKpiCard.inProgress(
                  amount: summary.pendingInProgressRevenue,
                  count: summary.inProgressCount,
                  currency: summary.currency,
                ),
                const SizedBox(height: 18),

                // 2. Search Bar
                _buildSearchBar(context),
                const SizedBox(height: 14),

                // 3. Status Tabs (Section 5.2)
                _buildStatusTabs(summary),
                const SizedBox(height: 12),

                // 4. Period Filter Chips (Section 5.2)
                _buildPeriodFilterChips(),
                const SizedBox(height: 16),

                // 5. Deliveries List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deliveries & Package Items',
                      style: AppTextStyles.titleMedium(),
                    ),
                    if (controller.isFilterLoading.value)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${revenue?.deliveries.length ?? 0} shown',
                        style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. Deliveries Cards
                _buildDeliveriesList(revenue?.deliveries ?? [], summary.currency),

                const SizedBox(height: 20),

                // 7. Cash Out Action Button
                CustomButton(
                  text: 'Request Instant Cash Out',
                  type: ButtonType.primary,
                  icon: Icons.account_balance_wallet_outlined,
                  onPressed: () => controller.openPayoutModal(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightCardBorder),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (val) => controller.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: AppStrings.searchOrdersOrStores,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => controller.clearSearch(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusTabs(RiderRevenueSummaryEntity summary) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatusTabItem('All (${summary.totalDeliveriesCount})', 'all'),
          _buildStatusTabItem('Delivered (${summary.deliveredCount})', 'delivered'),
          _buildStatusTabItem('In Progress (${summary.inProgressCount})', 'inprogress'),
        ],
      ),
    );
  }

  Widget _buildStatusTabItem(String label, String statusKey) {
    final isSelected = controller.selectedStatus.value == statusKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setStatusFilter(statusKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(AppStrings.allTime, 'all'),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.today, 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.thisWeek, 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.thisMonth, 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String periodKey) {
    final isSelected = controller.selectedPeriod.value == periodKey;
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.lightSurfaceVariant,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => controller.setPeriodFilter(periodKey),
    );
  }

  Widget _buildDeliveriesList(List<RiderRevenueDeliveryEntity> deliveries, String currency) {
    if (deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No Deliveries Found',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'There are no delivery revenue records matching the selected filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: deliveries
          .map((delivery) => RevenueDeliveryCard(
                delivery: delivery,
                currency: currency,
              ))
          .toList(),
    );
  }
}
