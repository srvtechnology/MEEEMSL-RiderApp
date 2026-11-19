import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/rider_ledger_model.dart';
import '../../../../data/models/rider_revenue_model.dart';
import '../../../../domain/entities/earnings_entity.dart';
import '../../../../domain/entities/rider_ledger_entity.dart';
import '../../../../domain/entities/rider_revenue_entity.dart';
import '../../../../domain/repositories/earnings_repository.dart';
import '../../../../domain/usecases/earnings/get_balance_transactions_usecase.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/get_payout_requests_usecase.dart';
import '../../../../domain/usecases/earnings/get_rider_revenue_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../../../../domain/usecases/earnings/submit_payout_request_usecase.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../routes/app_routes.dart';
import '../widgets/payout_request_bottom_sheet.dart';

class EarningsController extends GetxController {
  final GetRiderRevenueUseCase? _riderRevenueUseCase;
  final GetEarningsBreakdownUseCase getEarningsBreakdownUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;
  final GetBalanceTransactionsUseCase? _balanceTransactionsUseCase;
  final GetPayoutRequestsUseCase? _payoutRequestsUseCase;
  final SubmitPayoutRequestUseCase? _submitPayoutRequestUseCase;

  EarningsController({
    GetRiderRevenueUseCase? getRiderRevenueUseCase,
    required this.getEarningsBreakdownUseCase,
    required this.requestPayoutUseCase,
    GetBalanceTransactionsUseCase? getBalanceTransactionsUseCase,
    GetPayoutRequestsUseCase? getPayoutRequestsUseCase,
    SubmitPayoutRequestUseCase? submitPayoutRequestUseCase,
  })  : _riderRevenueUseCase = getRiderRevenueUseCase,
        _balanceTransactionsUseCase = getBalanceTransactionsUseCase,
        _payoutRequestsUseCase = getPayoutRequestsUseCase,
        _submitPayoutRequestUseCase = submitPayoutRequestUseCase;

  GetRiderRevenueUseCase get getRiderRevenueUseCase =>
      _riderRevenueUseCase ??
      (Get.isRegistered<GetRiderRevenueUseCase>()
          ? Get.find<GetRiderRevenueUseCase>()
          : GetRiderRevenueUseCase(Get.find<EarningsRepository>()));

  GetBalanceTransactionsUseCase? get getBalanceTransactionsUseCase {
    if (_balanceTransactionsUseCase != null) return _balanceTransactionsUseCase;
    if (Get.isRegistered<GetBalanceTransactionsUseCase>()) {
      return Get.find<GetBalanceTransactionsUseCase>();
    }
    if (Get.isRegistered<EarningsRepository>()) {
      return GetBalanceTransactionsUseCase(Get.find<EarningsRepository>());
    }
    return null;
  }

  GetPayoutRequestsUseCase? get getPayoutRequestsUseCase {
    if (_payoutRequestsUseCase != null) return _payoutRequestsUseCase;
    if (Get.isRegistered<GetPayoutRequestsUseCase>()) {
      return Get.find<GetPayoutRequestsUseCase>();
    }
    if (Get.isRegistered<EarningsRepository>()) {
      return GetPayoutRequestsUseCase(Get.find<EarningsRepository>());
    }
    return null;
  }

  SubmitPayoutRequestUseCase? get submitPayoutRequestUseCase {
    if (_submitPayoutRequestUseCase != null) return _submitPayoutRequestUseCase;
    if (Get.isRegistered<SubmitPayoutRequestUseCase>()) {
      return Get.find<SubmitPayoutRequestUseCase>();
    }
    if (Get.isRegistered<EarningsRepository>()) {
      return SubmitPayoutRequestUseCase(Get.find<EarningsRepository>());
    }
    return null;
  }

  GetStorage? get _storage =>
      Get.isRegistered<GetStorage>() ? Get.find<GetStorage>() : null;

  // UI State Observables
  final isLoading = false.obs;
  final isFilterLoading = false.obs;
  final isLedgerLoading = false.obs;
  final isPayoutsLoading = false.obs;
  final isSubmittingPayout = false.obs;

  // Section Tabs: 0 = Delivery Settlements, 1 = Balance Ledger, 2 = Payout Requests
  final selectedSectionIndex = 0.obs;

  // Delivery Filters
  final selectedStatus = 'all'.obs; // 'all', 'delivered', 'inprogress'
  final selectedPeriod = 'all'.obs; // 'all', 'today', 'week', 'month'
  final searchQuery = ''.obs;

  // Ledger Filter: 'all', 'DELIVERY_FULFILLED', 'COD_DELIVERY_COLLECTED', 'PAYOUT_DISBURSED'
  final selectedLedgerFilter = 'all'.obs;

  // Error Observables
  final revenueError = RxnString();
  final ledgerError = RxnString();
  final payoutsError = RxnString();

  // Data Observables
  final revenueData = Rxn<RiderRevenueDataEntity>();
  final ledgerData = Rxn<RiderBalanceLedgerEntity>();
  final payoutStatus = Rxn<RiderPayoutStatusEntity>();
  final earningsData = Rxn<EarningsEntity>();

  final searchController = TextEditingController();
  Timer? _searchDebounce;
  int _revenueRequestSeq = 0;

  // Freshness timestamps to avoid redundant API hits on rapid tab switching
  DateTime? _lastRevenueFetchAt;
  DateTime? _lastLedgerFetchAt;
  DateTime? _lastPayoutsFetchAt;
  static const Duration _staleTtl = Duration(seconds: 20);

  // Computed Wallet & Payout Getters (reactive inside Obx)
  String get currency => revenueData.value?.summary.currency ?? 'NLe';

  double get effectiveNetBalance {
    final rev = revenueData.value;
    if (rev != null) return rev.summary.withdrawableBalance;
    final payouts = payoutStatus.value;
    if (payouts != null) return payouts.netBalance;
    final ledger = ledgerData.value;
    if (ledger != null) return ledger.netBalance;
    return 0.0;
  }

  bool get hasPendingPayout {
    final revSummary = revenueData.value?.summary;
    final payouts = payoutStatus.value;
    return (revSummary?.hasPendingPayoutRequest ?? false) ||
        (revSummary?.pendingPayoutRequest != null) ||
        (payouts?.hasPendingRequest ?? false);
  }

  RiderPayoutRequestEntity? get activePendingPayoutRequest {
    return payoutStatus.value?.effectivePendingRequest ??
        revenueData.value?.summary.pendingPayoutRequest;
  }

  bool get canRequestPayout =>
      effectiveNetBalance > 0 && !hasPendingPayout && !isSubmittingPayout.value;

  String? get effectivePayoutMethod {
    final fromPayouts = payoutStatus.value?.payoutMethod;
    if (fromPayouts != null && fromPayouts.trim().isNotEmpty) return fromPayouts;
    final bank = revenueData.value?.riderBankDetails;
    if (bank != null && bank.hasConfiguredDetails) return bank.displayMethod;
    return null;
  }

  String? get effectivePayoutAccountSnapshot {
    final fromPayouts = payoutStatus.value?.payoutAccountSnapshot;
    if (fromPayouts != null && fromPayouts.trim().isNotEmpty) {
      return fromPayouts;
    }
    final bank = revenueData.value?.riderBankDetails;
    if (bank != null && bank.formattedSnapshot.isNotEmpty) {
      return bank.formattedSnapshot;
    }
    return null;
  }

  bool get hasConfiguredPayoutAccount {
    final snapshot = effectivePayoutAccountSnapshot;
    if (snapshot != null && snapshot.trim().isNotEmpty) return true;
    return revenueData.value?.riderBankDetails?.hasConfiguredDetails ?? false;
  }

  List<RiderBalanceTransactionEntity> get filteredLedgerTransactions {
    final all = ledgerData.value?.transactions ?? const <RiderBalanceTransactionEntity>[];
    final filter = selectedLedgerFilter.value;
    if (filter == 'all') return all;
    return all.where((tx) => tx.reason.toUpperCase() == filter).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // 1. Hydrate cached snapshots immediately for 0ms first paint
    _restoreFromCache();
    // 2. Prioritize the primary visible endpoint (/revenue) first; Ledger & Payouts load lazily on tab tap
    loadRevenue(showLoading: revenueData.value == null);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _restoreFromCache() {
    final storage = _storage;
    if (storage == null) return;
    try {
      final rawRev = storage.read(AppConstants.revenueCacheKey);
      if (rawRev is Map) {
        revenueData.value = RiderRevenueDataModel.fromJson(
          Map<String, dynamic>.from(rawRev),
        );
      }
    } catch (_) {}
    try {
      final rawLedger = storage.read(AppConstants.balanceLedgerCacheKey);
      if (rawLedger is Map) {
        ledgerData.value = RiderBalanceLedgerModel.fromJson(
          Map<String, dynamic>.from(rawLedger),
        );
      }
    } catch (_) {}
    try {
      final rawPayouts = storage.read(AppConstants.payoutStatusCacheKey);
      if (rawPayouts is Map) {
        payoutStatus.value = RiderPayoutStatusModel.fromJson(
          Map<String, dynamic>.from(rawPayouts),
        );
      }
    } catch (_) {}
  }

  void _cacheRevenueIfDefault(RiderRevenueDataEntity data) {
    final storage = _storage;
    if (storage == null) return;
    if (selectedStatus.value != 'all' ||
        selectedPeriod.value != 'all' ||
        searchQuery.value.isNotEmpty) {
      return;
    }
    if (data is RiderRevenueDataModel) {
      try {
        storage.write(AppConstants.revenueCacheKey, data.toJson());
      } catch (_) {}
    }
  }

  void _cacheLedger(RiderBalanceLedgerEntity data) {
    final storage = _storage;
    if (storage == null) return;
    if (data is RiderBalanceLedgerModel) {
      try {
        storage.write(AppConstants.balanceLedgerCacheKey, data.toJson());
      } catch (_) {}
    }
  }

  void _cachePayoutStatus(RiderPayoutStatusEntity data) {
    final storage = _storage;
    if (storage == null) return;
    if (data is RiderPayoutStatusModel) {
      try {
        storage.write(AppConstants.payoutStatusCacheKey, data.toJson());
      } catch (_) {}
    }
  }

  bool _isStale(DateTime? lastFetched) {
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched) >= _staleTtl;
  }

  /// Smart tab-switch refresh: refreshes only the active section if its data is stale.
  Future<void> refreshIfStale() async {
    final idx = selectedSectionIndex.value;
    if (idx == 0) {
      if (_isStale(_lastRevenueFetchAt)) {
        await loadRevenue(showLoading: false);
      }
    } else if (idx == 1) {
      await Future.wait([
        if (_isStale(_lastRevenueFetchAt)) loadRevenue(showLoading: false),
        if (_isStale(_lastLedgerFetchAt)) loadBalanceTransactions(showLoading: false),
      ]);
    } else {
      await Future.wait([
        if (_isStale(_lastRevenueFetchAt)) loadRevenue(showLoading: false),
        if (_isStale(_lastPayoutsFetchAt)) loadPayoutRequests(showLoading: false),
      ]);
    }
  }

  /// Refreshes revenue summary/deliveries, balance ledger, and payout requests in parallel.
  /// Used for explicit pull-to-refresh, AppBar refresh, post-delivery OTP, and post-payout submission.
  Future<void> loadAll({bool showLoading = true}) async {
    await Future.wait([
      loadRevenue(showLoading: showLoading),
      loadBalanceTransactions(showLoading: showLoading),
      loadPayoutRequests(showLoading: showLoading),
    ]);
  }

  /// Switches the active transparency tab (0: Deliveries, 1: Ledger, 2: Payouts)
  /// and lazily fetches Ledger/Payouts only when visited or stale.
  void selectSection(int index) {
    if (index < 0 || index > 2) return;
    selectedSectionIndex.value = index;
    if (index == 1 &&
        !isLedgerLoading.value &&
        (ledgerData.value == null || _isStale(_lastLedgerFetchAt))) {
      loadBalanceTransactions(showLoading: ledgerData.value == null);
    } else if (index == 2 &&
        !isPayoutsLoading.value &&
        (payoutStatus.value == null || _isStale(_lastPayoutsFetchAt))) {
      loadPayoutRequests(showLoading: payoutStatus.value == null);
    }
  }

  /// Sets the Balance Ledger reason filter ('all', 'DELIVERY_FULFILLED', 'COD_DELIVERY_COLLECTED', 'PAYOUT_DISBURSED').
  void setLedgerFilter(String reason) {
    if (selectedLedgerFilter.value == reason) return;
    selectedLedgerFilter.value = reason;
  }

  /// Loads full Rider Revenue, Wallet KPIs & Deliveries (`GET /mobileapi/rider/revenue`)
  Future<void> loadRevenue({bool showLoading = true}) async {
    final seq = ++_revenueRequestSeq;
    revenueError.value = null;

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

    if (seq != _revenueRequestSeq) return;

    if (showLoading) {
      isLoading.value = false;
    } else {
      isFilterLoading.value = false;
    }

    result.fold(
      (failure) {
        revenueError.value = failure.message;
        _showSnackbar('Error', failure.message, isError: true);
      },
      (data) {
        revenueError.value = null;
        revenueData.value = data;
        _lastRevenueFetchAt = DateTime.now();
        _cacheRevenueIfDefault(data);

        // Reconcile pending payout details lazily only if pending exists or changed
        if (data.summary.hasPendingPayoutRequest &&
            data.summary.pendingPayoutRequest == null &&
            payoutStatus.value?.effectivePendingRequest == null &&
            !isPayoutsLoading.value) {
          loadPayoutRequests(showLoading: false);
        } else if (!data.summary.hasPendingPayoutRequest &&
            data.summary.pendingPayoutRequest == null &&
            (payoutStatus.value?.hasPendingRequest ?? false)) {
          loadPayoutRequests(showLoading: false);
        }
      },
    );
  }

  /// Loads chronological Balance Ledger (`GET /mobileapi/rider/balance-transactions`)
  Future<void> loadBalanceTransactions({bool showLoading = true}) async {
    final useCase = getBalanceTransactionsUseCase;
    if (useCase == null) return;

    ledgerError.value = null;
    if (showLoading && ledgerData.value == null) {
      isLedgerLoading.value = true;
    }

    final result = await useCase();
    isLedgerLoading.value = false;

    result.fold(
      (failure) {
        ledgerError.value = failure.message;
      },
      (data) {
        ledgerError.value = null;
        ledgerData.value = data;
        _lastLedgerFetchAt = DateTime.now();
        _cacheLedger(data);
      },
    );
  }

  /// Loads Payout Request status & history (`GET /mobileapi/rider/payout-requests`)
  Future<void> loadPayoutRequests({bool showLoading = true}) async {
    final useCase = getPayoutRequestsUseCase;
    if (useCase == null) return;

    payoutsError.value = null;
    if (showLoading && payoutStatus.value == null) {
      isPayoutsLoading.value = true;
    }

    final result = await useCase();
    isPayoutsLoading.value = false;

    result.fold(
      (failure) {
        payoutsError.value = failure.message;
      },
      (data) {
        payoutsError.value = null;
        payoutStatus.value = data;
        _lastPayoutsFetchAt = DateTime.now();
        _cachePayoutStatus(data);
      },
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

  /// Debounced handler for the search text input to avoid hammering the API per keystroke.
  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    searchQuery.value = query;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadRevenue(showLoading: false);
    });
  }

  /// Updates search query immediately and queries backend/mock engine.
  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    loadRevenue(showLoading: false);
  }

  /// Clears search filter
  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    if (searchQuery.value.isNotEmpty) {
      searchQuery.value = '';
      loadRevenue(showLoading: false);
    }
  }

  /// Legacy earnings loader (retained only for backward compatibility; no longer invoked on init)
  Future<void> loadEarnings() async {
    final result = await getEarningsBreakdownUseCase('weekly');
    result.fold(
      (failure) => null,
      (data) => earningsData.value = data,
    );
  }

  Future<void> openManagePayoutAccount() async {
    await Get.toNamed(AppRoutes.payoutInfo);
    await loadAll(showLoading: false);
  }

  void openPayoutModal() {
    if (!canRequestPayout) {
      if (hasPendingPayout) {
        _showSnackbar(
          'Request Pending',
          'A payout request is already pending disbursement by Admin.',
          isWarning: true,
        );
      } else if (effectiveNetBalance <= 0) {
        _showSnackbar(
          'Insufficient Balance',
          'Your withdrawable wallet balance must be greater than $currency 0.00.',
          isWarning: true,
        );
      }
      return;
    }

    Get.bottomSheet(
      PayoutRequestBottomSheet(
        availableBalance: effectiveNetBalance,
        currency: currency,
        payoutMethod: effectivePayoutMethod,
        payoutAccountSnapshot: effectivePayoutAccountSnapshot,
        hasConfiguredPayoutAccount: hasConfiguredPayoutAccount,
        onSubmitted: (note) => submitPayoutRequest(sellerNote: note),
        onManagePayoutAccount: () {
          Get.back();
          openManagePayoutAccount();
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  /// Submits a withdrawal request (`POST /mobileapi/rider/payout-requests`)
  /// for the rider's full available `netBalance`.
  Future<bool> submitPayoutRequest({String? sellerNote}) async {
    if (isSubmittingPayout.value) return false;

    if (effectiveNetBalance <= 0) {
      _showSnackbar(
        'Insufficient Balance',
        'Insufficient balance. Your current net balance must be greater than $currency 0.00.',
        isError: true,
      );
      return false;
    }

    if (hasPendingPayout) {
      _showSnackbar(
        'Payout Pending',
        'A payout request is already pending disbursement by Admin.',
        isWarning: true,
      );
      return false;
    }

    final useCase = submitPayoutRequestUseCase;
    if (useCase == null) {
      _showSnackbar('Error', 'Payout service is currently unavailable.', isError: true);
      return false;
    }

    isSubmittingPayout.value = true;
    final result = await useCase(sellerNote: sellerNote);
    isSubmittingPayout.value = false;

    return result.fold(
      (failure) {
        _showSnackbar('Payout Request Failed', failure.message, isError: true);
        return false;
      },
      (createdRequest) {
        // Immediately reflect pending request in local state so UI disables CTA & shows amber banner
        final existingStatus = payoutStatus.value;
        final updatedHistory = [
          createdRequest,
          ...(existingStatus?.history ?? const <RiderPayoutRequestEntity>[])
              .where((r) => r.id != createdRequest.id),
        ];
        final updatedStatus = RiderPayoutStatusModel(
          netBalance: existingStatus?.netBalance ?? effectiveNetBalance,
          payoutMethod: createdRequest.payoutMethod ?? existingStatus?.payoutMethod,
          payoutAccountSnapshot: createdRequest.payoutAccountSnapshot ??
              existingStatus?.payoutAccountSnapshot,
          pendingRequest: createdRequest,
          history: updatedHistory,
        );
        payoutStatus.value = updatedStatus;
        _cachePayoutStatus(updatedStatus);

        // Reload all authoritative server feeds in background
        loadAll(showLoading: false);
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadAllProfileData(force: false);
        }

        final formattedAmt = Formatters.formatRevenueAmount(
          createdRequest.requestedAmount,
          currency: currency,
        );
        _showSnackbar(
          'Payout Request Submitted',
          'Your request for $formattedAmt has been submitted for Admin disbursement.',
          isSuccess: true,
        );
        return true;
      },
    );
  }

  void _showSnackbar(
    String title,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    if (Get.overlayContext == null) return;
    Color bgColor = const Color(0xFFEFF6FF);
    Color textColor = const Color(0xFF1E3A8A);
    if (isError) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFB91C1C);
    } else if (isSuccess) {
      bgColor = const Color(0xFFE8F8EE);
      textColor = const Color(0xFF065F46);
    } else if (isWarning) {
      bgColor = const Color(0xFFFFFBEB);
      textColor = const Color(0xFF92400E);
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor,
      colorText: textColor,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}
