import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/earnings_entity.dart';
import '../../../../domain/entities/rider_revenue_entity.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/get_rider_revenue_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../widgets/payout_request_bottom_sheet.dart';

class EarningsController extends GetxController {
  final GetRiderRevenueUseCase? _riderRevenueUseCase;
  final GetEarningsBreakdownUseCase getEarningsBreakdownUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;

  EarningsController({
    GetRiderRevenueUseCase? getRiderRevenueUseCase,
    required this.getEarningsBreakdownUseCase,
    required this.requestPayoutUseCase,
  }) : _riderRevenueUseCase = getRiderRevenueUseCase;

  GetRiderRevenueUseCase get getRiderRevenueUseCase =>
      _riderRevenueUseCase ??
      (Get.isRegistered<GetRiderRevenueUseCase>()
          ? Get.find<GetRiderRevenueUseCase>()
          : GetRiderRevenueUseCase(Get.find()));

  // UI State Observables
  final isLoading = false.obs;
  final isFilterLoading = false.obs;
  final selectedStatus = 'all'.obs; // 'all', 'delivered', 'inprogress'
  final selectedPeriod = 'all'.obs; // 'all', 'today', 'week', 'month'
  final searchQuery = ''.obs;

  // Data Observables
  final revenueData = Rxn<RiderRevenueDataEntity>();
  final earningsData = Rxn<EarningsEntity>();

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRevenue();
    loadEarnings();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Loads full Part 6 Rider Revenue & Earnings data
  Future<void> loadRevenue({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    } else {
      isFilterLoading.value = true;
    }

    final result = await getRiderRevenueUseCase(
      status: selectedStatus.value,
      period: selectedPeriod.value,
      search: searchQuery.value,
    );

    if (showLoading) {
      isLoading.value = false;
    } else {
      isFilterLoading.value = false;
    }

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => revenueData.value = data,
    );
  }

  /// Sets status filter tab ('all', 'delivered', 'inprogress')
  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    loadRevenue(showLoading: false);
  }

  /// Sets period chip filter ('all', 'today', 'week', 'month')
  void setPeriodFilter(String period) {
    if (selectedPeriod.value == period) return;
    selectedPeriod.value = period;
    loadRevenue(showLoading: false);
  }

  /// Updates search query and queries backend/mock engine
  void setSearchQuery(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    loadRevenue(showLoading: false);
  }

  /// Clears search filter
  void clearSearch() {
    searchController.clear();
    setSearchQuery('');
  }

  /// Legacy earnings loader (for charts & backward compatibility)
  Future<void> loadEarnings() async {
    final result = await getEarningsBreakdownUseCase('weekly');
    result.fold(
      (failure) => null,
      (data) => earningsData.value = data,
    );
  }

  void openPayoutModal() {
    final available = revenueData.value?.summary.totalDeliveredRevenue ??
        earningsData.value?.availablePayout ??
        0.0;
    Get.bottomSheet(
      PayoutRequestBottomSheet(
        availableBalance: available,
        onSubmitted: (amount, method) => _submitPayout(amount, method),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitPayout(double amount, String method) async {
    isLoading.value = true;
    final result = await requestPayoutUseCase(amount, method);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (success) {
        Get.back(); // close modal
        loadRevenue();
        loadEarnings();
        Get.snackbar('Payout Initiated', 'Transfer of Nle $amount sent to your bank account',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }
}
