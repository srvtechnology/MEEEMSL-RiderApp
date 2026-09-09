import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/earnings_entity.dart';
import '../../../../domain/usecases/earnings/get_earnings_breakdown_usecase.dart';
import '../../../../domain/usecases/earnings/request_payout_usecase.dart';
import '../widgets/payout_request_bottom_sheet.dart';

class EarningsController extends GetxController {
  final GetEarningsBreakdownUseCase getEarningsBreakdownUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;

  EarningsController({
    required this.getEarningsBreakdownUseCase,
    required this.requestPayoutUseCase,
  });

  final isLoading = false.obs;
  final selectedPeriod = 'weekly'.obs; // daily, weekly, monthly
  final earningsData = Rxn<EarningsEntity>();

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    isLoading.value = true;
    final result = await getEarningsBreakdownUseCase(selectedPeriod.value);
    isLoading.value = false;

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (data) => earningsData.value = data,
    );
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadEarnings();
  }

  void openPayoutModal() {
    Get.bottomSheet(
      PayoutRequestBottomSheet(
        availableBalance: earningsData.value?.availablePayout ?? 0.0,
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
        loadEarnings();
        Get.snackbar('Payout Initiated', 'Transfer of Nle $amount sent to your bank account',
            snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F8EE));
      },
    );
  }
}
