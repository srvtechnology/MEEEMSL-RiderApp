import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../domain/entities/rider_revenue_entity.dart';
import '../controllers/earnings_controller.dart';
import '../widgets/balance_ledger_list.dart';
import '../widgets/payout_requests_list.dart';
import '../widgets/revenue_delivery_card.dart';
import '../widgets/revenue_kpi_card.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myRevenue),
        actions: [
          Obx(() => IconButton(
                icon: controller.isLoading.value && controller.revenueData.value != null
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.loadAll(),
              )),
        ],
      ),
      body: Obx(() {
        final revenue = controller.revenueData.value;
        if (revenue == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = revenue?.summary ??
            const RiderRevenueSummaryEntity(
              netBalance: 0,
              totalDeliveredRevenue: 0,
              prepaidDeliveredRevenue: 0,
              codDeliveredRevenue: 0,
              codCashCollectedTotal: 0,
              pendingInProgressRevenue: 0,
              deliveredCount: 0,
              inProgressCount: 0,
              totalDeliveriesCount: 0,
              currency: 'NLe',
            );

        final effectiveNetBalance = controller.effectiveNetBalance;
        final hasPendingPayout = controller.hasPendingPayout;
        final activePendingReq = controller.activePendingPayoutRequest;
        final selectedSection = controller.selectedSectionIndex.value;
        final deliveries = revenue?.deliveries ?? const <RiderRevenueDeliveryEntity>[];

        return RefreshIndicator(
          onRefresh: () => controller.loadAll(showLoading: false),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // 1. Top KPI Cards + Pending Banner + 3-Tab Switcher
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.isLoading.value && revenue != null) ...[
                        const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          child: LinearProgressIndicator(minHeight: 2.5),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // KPI (a): Withdrawable Wallet (`summary.netBalance`) + "Request Payout" CTA
                      WithdrawableWalletCard(
                        balance: effectiveNetBalance,
                        currency: summary.currency,
                        hasPendingPayoutRequest: hasPendingPayout,
                        isSubmittingPayout: controller.isSubmittingPayout.value,
                        payoutMethodLabel: controller.effectivePayoutMethod,
                        onRequestPayout: controller.canRequestPayout
                            ? () => controller.openPayoutModal()
                            : null,
                      ),

                      // Amber Pending Payout Request Banner (Guide Section 8.3)
                      if (hasPendingPayout) ...[
                        const SizedBox(height: 12),
                        PendingPayoutBanner(
                          pendingRequest: activePendingReq,
                          fallbackAmount: effectiveNetBalance,
                          currency: summary.currency,
                          onViewPayouts: selectedSection != 2
                              ? () => controller.selectSection(2)
                              : null,
                        ),
                      ],
                      const SizedBox(height: 12),

                      // KPI (b): Total Delivery Earnings (`summary.totalDeliveredRevenue`)
                      RevenueKpiCard.delivered(
                        amount: summary.totalDeliveredRevenue,
                        count: summary.deliveredCount,
                        currency: summary.currency,
                      ),
                      const SizedBox(height: 12),

                      // KPI (c) & KPI (d): Prepaid (AfriMoney) vs COD Earnings & Cash Collected
                      // Avoids IntrinsicHeight double-pass layout cost for smoother scrolling
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 136),
                              child: RevenueKpiCard.prepaid(
                                amount: summary.prepaidDeliveredRevenue,
                                currency: summary.currency,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 136),
                              child: RevenueKpiCard.cod(
                                codDeliveryEarnings: summary.codDeliveredRevenue,
                                codCashCollectedTotal: summary.codCashCollectedTotal,
                                currency: summary.currency,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // In-Progress Potential Card (Active In-Transit Drops)
                      RevenueKpiCard.inProgress(
                        amount: summary.pendingInProgressRevenue,
                        count: summary.inProgressCount,
                        currency: summary.currency,
                      ),
                      const SizedBox(height: 18),

                      // 2. Three Transparency Section Tabs (Guide Section 8.2)
                      _buildMainSectionTabs(
                        selectedIndex: selectedSection,
                        deliveriesCount: summary.totalDeliveriesCount,
                        ledgerCount: controller.ledgerData.value?.transactions.length,
                        payoutsCount: controller.payoutStatus.value?.history.length,
                        hasPendingPayout: hasPendingPayout,
                        surfaceVariant: surfaceVariant,
                        textPrimary: textPrimary,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. Active Tab Content (Virtualized with SliverList.builder!)
              if (selectedSection == 0) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildDeliveryFiltersHeader(
                      context: context,
                      revenue: revenue,
                      summary: summary,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      surfaceVariant: surfaceVariant,
                      borderColor: borderColor,
                    ),
                  ),
                ),
                if (controller.revenueError.value != null && revenue == null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildRevenueErrorCard(
                        context,
                        textPrimary,
                        textSecondary,
                        borderColor,
                      ),
                    ),
                  )
                else if (deliveries.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildEmptyDeliveriesCard(
                        context,
                        textPrimary,
                        textSecondary,
                        borderColor,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: deliveries.length,
                      addAutomaticKeepAlives: false,
                      itemBuilder: (context, index) => RevenueDeliveryCard(
                        key: ValueKey(deliveries[index].assignmentId),
                        delivery: deliveries[index],
                        currency: summary.currency,
                      ),
                    ),
                  ),
              ] else if (selectedSection == 1)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: BalanceLedgerList(
                      ledger: controller.ledgerData.value,
                      filteredTransactions: controller.filteredLedgerTransactions,
                      selectedFilter: controller.selectedLedgerFilter.value,
                      currency: summary.currency,
                      isLoading: controller.isLedgerLoading.value,
                      errorMessage: controller.ledgerError.value,
                      onFilterChanged: controller.setLedgerFilter,
                      onRetry: () => controller.loadBalanceTransactions(),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: PayoutRequestsList(
                      payoutStatus: controller.payoutStatus.value,
                      fallbackPayoutMethod: controller.effectivePayoutMethod,
                      fallbackAccountSnapshot: controller.effectivePayoutAccountSnapshot,
                      currency: summary.currency,
                      isLoading: controller.isPayoutsLoading.value,
                      errorMessage: controller.payoutsError.value,
                      canRequestPayout: controller.canRequestPayout,
                      onRequestPayout: () => controller.openPayoutModal(),
                      onRetry: () => controller.loadPayoutRequests(),
                      onManagePayoutAccount: () => controller.openManagePayoutAccount(),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMainSectionTabs({
    required int selectedIndex,
    required int deliveriesCount,
    required int? ledgerCount,
    required int? payoutsCount,
    required bool hasPendingPayout,
    required Color surfaceVariant,
    required Color textPrimary,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildMainTabItem(
            key: const Key('section_tab_deliveries'),
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.local_shipping_outlined,
            label: AppStrings.deliverySettlements,
            badgeText: '$deliveriesCount',
            textPrimary: textPrimary,
          ),
          _buildMainTabItem(
            key: const Key('section_tab_ledger'),
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.menu_book_outlined,
            label: 'Ledger',
            badgeText: ledgerCount != null ? '$ledgerCount' : null,
            textPrimary: textPrimary,
          ),
          _buildMainTabItem(
            key: const Key('section_tab_payouts'),
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.payments_outlined,
            label: 'Payouts',
            badgeText: payoutsCount != null ? '$payoutsCount' : null,
            showAlertDot: hasPendingPayout,
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabItem({
    Key? key,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
    String? badgeText,
    bool showAlertDot = false,
    required Color textPrimary,
  }) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: () => controller.selectSection(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(55),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : textPrimary,
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withAlpha(45)
                            : AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  if (showAlertDot)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryFiltersHeader({
    required BuildContext context,
    required RiderRevenueDataEntity? revenue,
    required RiderRevenueSummaryEntity summary,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color surfaceVariant,
    required Color borderColor,
  }) {
    if (controller.revenueError.value != null && revenue == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(context, isDark, textPrimary, textSecondary, borderColor),
        const SizedBox(height: 12),
        _buildStatusTabs(summary, surfaceVariant, textPrimary, borderColor),
        const SizedBox(height: 10),
        _buildPeriodFilterChips(isDark, textPrimary, borderColor),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Delivery Settlement Breakdown',
                style: AppTextStyles.titleMedium(color: textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (controller.isFilterLoading.value)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '${revenue?.deliveries.length ?? 0} shown',
                style: AppTextStyles.bodySmall(color: textSecondary),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRevenueErrorCard(
    BuildContext context,
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
            'Could Not Load Revenue',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            controller.revenueError.value ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => controller.loadRevenue(),
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 40)),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeliveriesCard(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 46, color: textSecondary),
          const SizedBox(height: 12),
          Text(
            'No Deliveries Found',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no delivery revenue records matching the selected filters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller.searchController,
        style: TextStyle(fontSize: 13.5, color: textPrimary),
        onChanged: (val) => controller.onSearchChanged(val),
        onSubmitted: (val) => controller.setSearchQuery(val),
        decoration: InputDecoration(
          filled: false,
          hintText: AppStrings.searchOrdersOrStores,
          hintStyle: TextStyle(fontSize: 13, color: textSecondary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            size: 20,
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                  onPressed: () => controller.clearSearch(),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusTabs(
    RiderRevenueSummaryEntity summary,
    Color surfaceVariant,
    Color textPrimary,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildStatusTabItem(
            'All (${summary.totalDeliveriesCount})',
            'all',
            textPrimary,
          ),
          _buildStatusTabItem(
            'Delivered (${summary.deliveredCount})',
            'delivered',
            textPrimary,
          ),
          _buildStatusTabItem(
            'In Progress (${summary.inProgressCount})',
            'inprogress',
            textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabItem(String label, String statusKey, Color textPrimary) {
    final isSelected = controller.selectedStatus.value == statusKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setStatusFilter(statusKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilterChips(bool isDark, Color textPrimary, Color borderColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip(AppStrings.allTime, 'all', isDark, textPrimary, borderColor),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.today, 'today', isDark, textPrimary, borderColor),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.thisWeek, 'week', isDark, textPrimary, borderColor),
          const SizedBox(width: 8),
          _buildPeriodChip(AppStrings.thisMonth, 'month', isDark, textPrimary, borderColor),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    String label,
    String periodKey,
    bool isDark,
    Color textPrimary,
    Color borderColor,
  ) {
    final isSelected = controller.selectedPeriod.value == periodKey;
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
      side: BorderSide(color: isSelected ? AppColors.primary : borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => controller.setPeriodFilter(periodKey),
    );
  }
}
