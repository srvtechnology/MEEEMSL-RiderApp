import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../domain/entities/payout_info_entity.dart';
import '../controllers/profile_controller.dart';

class PayoutInfoView extends StatefulWidget {
  const PayoutInfoView({super.key});

  @override
  State<PayoutInfoView> createState() => _PayoutInfoViewState();
}

class _PayoutInfoViewState extends State<PayoutInfoView> {
  final ProfileController controller = Get.find<ProfileController>();

  late PaymentOption currentOption;
  final bankNameCtrl = TextEditingController();
  final branchNameCtrl = TextEditingController();
  final holderNameCtrl = TextEditingController();
  final accountNumCtrl = TextEditingController();
  final bbanCtrl = TextEditingController();
  final bankAddressCtrl = TextEditingController();

  final mobileNumCtrl = TextEditingController();
  final agentNumCtrl = TextEditingController();

  StreamSubscription? _payoutSubscription;
  StreamSubscription? _riderSubscription;

  @override
  void initState() {
    super.initState();
    _populateFields(controller.payoutInfo.value);

    _payoutSubscription = controller.payoutInfo.listen((info) {
      if (mounted) {
        _populateFields(info);
      }
    });

    _riderSubscription = controller.riderProfile.listen((_) {
      if (mounted && holderNameCtrl.text.isEmpty) {
        _populateFields(controller.payoutInfo.value);
      }
    });
  }

  void _populateFields(PayoutInfoEntity? info) {
    final rider = controller.riderProfile.value;
    final riderName = rider?.name ?? '';
    final riderPhone = rider?.phone ?? '';

    setState(() {
      currentOption = info?.paymentOption ?? PaymentOption.bank;

      bankNameCtrl.text = info?.bankName ?? 'Sierra Leone Commercial Bank';
      branchNameCtrl.text = info?.branchName ?? '';
      holderNameCtrl.text = (info?.accountHolderName?.isNotEmpty == true)
          ? info!.accountHolderName!
          : (riderName.isNotEmpty ? riderName : 'Ibrahim Koroma');
      accountNumCtrl.text = info?.accountNumber ?? '•••• 8829';
      bbanCtrl.text = info?.bbanNumber ?? '';
      bankAddressCtrl.text = info?.bankAddress ?? '';

      mobileNumCtrl.text = (info?.mobileNumber?.isNotEmpty == true)
          ? info!.mobileNumber!
          : (riderPhone.isNotEmpty ? riderPhone : '76123456');
      agentNumCtrl.text = info?.agentNumber ?? '';
    });
  }

  @override
  void dispose() {
    _payoutSubscription?.cancel();
    _riderSubscription?.cancel();
    bankNameCtrl.dispose();
    branchNameCtrl.dispose();
    holderNameCtrl.dispose();
    accountNumCtrl.dispose();
    bbanCtrl.dispose();
    bankAddressCtrl.dispose();
    mobileNumCtrl.dispose();
    agentNumCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (currentOption == PaymentOption.bank) {
      final bank = bankNameCtrl.text.trim();
      final accNum = accountNumCtrl.text.trim();
      final holder = holderNameCtrl.text.trim();

      if (bank.isEmpty) {
        Get.snackbar('Validation', 'Please enter your bank name',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (accNum.isEmpty) {
        Get.snackbar('Validation', 'Please enter your bank account number',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (holder.isEmpty) {
        Get.snackbar('Validation', 'Please enter the bank account holder name',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final info = PayoutInfoEntity(
        paymentOption: PaymentOption.bank,
        preferredPayoutMethod: 'Bank Transfer',
        bankName: bank,
        branchName: branchNameCtrl.text.trim().isNotEmpty ? branchNameCtrl.text.trim() : null,
        accountHolderName: holder,
        accountNumber: accNum,
        bbanNumber: bbanCtrl.text.trim().isNotEmpty ? bbanCtrl.text.trim() : null,
        bankAddress: bankAddressCtrl.text.trim().isNotEmpty ? bankAddressCtrl.text.trim() : null,
      );
      controller.savePayoutInfo(info);
    } else {
      final phone = mobileNumCtrl.text.trim();
      if (phone.isEmpty) {
        Get.snackbar('Validation', 'Please enter your Mobile Money phone number',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final opt = currentOption.apiValue;
      final info = PayoutInfoEntity(
        paymentOption: currentOption,
        preferredPayoutMethod: 'Mobile Wallet',
        mobileMoneyOption: opt,
        mobileNumber: phone,
        agentNumber: agentNumCtrl.text.trim().isNotEmpty ? agentNumCtrl.text.trim() : null,
      );
      controller.savePayoutInfo(info);
    }
  }

  Widget _buildOptionTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payoutInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Payout Details',
            onPressed: () => controller.loadPayoutInfo(showLoading: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadPayoutInfo(showLoading: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payout & Direct Deposit', style: AppTextStyles.headlineSmall()),
                      const SizedBox(height: 4),
                      Text(
                        'Choose how you want to receive your weekly earnings and instant cashouts.',
                        style: AppTextStyles.bodyMedium(),
                      ),
                      const SizedBox(height: 20),

                      // 3-Option Method Selector Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightCardBorder),
                        ),
                        child: Row(
                          children: [
                            _buildOptionTab(
                              title: AppStrings.bank,
                              isSelected: currentOption == PaymentOption.bank,
                              onTap: () => setState(() => currentOption = PaymentOption.bank),
                            ),
                            _buildOptionTab(
                              title: AppStrings.orangeMoney,
                              isSelected: currentOption == PaymentOption.orangeMoney,
                              onTap: () => setState(() => currentOption = PaymentOption.orangeMoney),
                            ),
                            _buildOptionTab(
                              title: AppStrings.afriMoney,
                              isSelected: currentOption == PaymentOption.afriMoney,
                              onTap: () => setState(() => currentOption = PaymentOption.afriMoney),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      if (currentOption == PaymentOption.bank) ...[
                        CustomTextField(
                          controller: bankNameCtrl,
                          label: '${AppStrings.bankName} *',
                          hintText: 'Sierra Leone Commercial Bank',
                          prefixIcon: Icons.account_balance_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: branchNameCtrl,
                          label: AppStrings.branchName,
                          hintText: 'Head Office / Siaka Stevens',
                          prefixIcon: Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: holderNameCtrl,
                          label: '${AppStrings.accountHolder} *',
                          hintText: 'Ibrahim Koroma',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: accountNumCtrl,
                          label: '${AppStrings.accountNumber} *',
                          hintText: '•••• 8829',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.numbers_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: bbanCtrl,
                          label: '${AppStrings.bbanNumber} (Optional)',
                          hintText: 'SL0010001000123456789',
                          prefixIcon: Icons.tag,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: bankAddressCtrl,
                          label: '${AppStrings.bankAddress} (Optional)',
                          hintText: '15 Siaka Stevens St, Freetown',
                          prefixIcon: Icons.place_outlined,
                        ),
                      ] else if (currentOption == PaymentOption.orangeMoney) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: Color(0xFFC2410C)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppStrings.mobileWalletOrangeNotice,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mobileNumCtrl,
                          label: '${AppStrings.mobileNumber} *',
                          hintText: '+232 76 123456',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: agentNumCtrl,
                          label: AppStrings.agentNumber,
                          hintText: 'AG-9081',
                          prefixIcon: Icons.badge_outlined,
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: Color(0xFF15803D)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppStrings.mobileWalletAfriNotice,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mobileNumCtrl,
                          label: '${AppStrings.mobileNumber} *',
                          hintText: '+232 77 123456',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: agentNumCtrl,
                          label: AppStrings.agentNumber,
                          hintText: 'AG-9081',
                          prefixIcon: Icons.badge_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: AppColors.lightCardBorder)),
              ),
              child: Obx(
                () => CustomButton(
                  text: 'Save Payout Details',
                  icon: Icons.check,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value ? null : _onSave,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
