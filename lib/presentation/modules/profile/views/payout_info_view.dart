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

  late PayoutMethodType currentMethod;
  final bankNameCtrl = TextEditingController();
  final accountNumCtrl = TextEditingController();
  final holderNameCtrl = TextEditingController();
  final routingCtrl = TextEditingController();

  final mmProviderCtrl = TextEditingController();
  final mmNumberCtrl = TextEditingController();
  final mmBeneficiaryCtrl = TextEditingController();

  StreamSubscription? _payoutSubscription;
  StreamSubscription? _riderSubscription;

  static const List<String> popularMMProviders = [
    'Orange Money',
    'Afrimoney',
    'QMoney',
    'MTN MoMo',
  ];

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
      currentMethod = info?.methodType ?? PayoutMethodType.bank;

      bankNameCtrl.text = info?.bankName ?? 'Sierra Leone Commercial Bank';
      accountNumCtrl.text = info?.accountNumber ?? '•••• 8829';
      holderNameCtrl.text = (info?.accountHolderName?.isNotEmpty == true)
          ? info!.accountHolderName!
          : (riderName.isNotEmpty ? riderName : 'Ibrahim Koroma');
      routingCtrl.text = info?.routingNumber ?? '021000021';

      mmProviderCtrl.text = (info?.mobileMoneyProvider?.isNotEmpty == true)
          ? info!.mobileMoneyProvider!
          : 'Orange Money';
      mmNumberCtrl.text = (info?.mobileMoneyNumber?.isNotEmpty == true)
          ? info!.mobileMoneyNumber!
          : (riderPhone.isNotEmpty ? riderPhone : '76123456');
      mmBeneficiaryCtrl.text = (info?.beneficiaryName?.isNotEmpty == true)
          ? info!.beneficiaryName!
          : (riderName.isNotEmpty ? riderName : 'Ibrahim Koroma');
    });
  }

  @override
  void dispose() {
    _payoutSubscription?.cancel();
    _riderSubscription?.cancel();
    bankNameCtrl.dispose();
    accountNumCtrl.dispose();
    holderNameCtrl.dispose();
    routingCtrl.dispose();
    mmProviderCtrl.dispose();
    mmNumberCtrl.dispose();
    mmBeneficiaryCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (currentMethod == PayoutMethodType.bank) {
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
    } else {
      final provider = mmProviderCtrl.text.trim();
      final phone = mmNumberCtrl.text.trim();
      final beneficiary = mmBeneficiaryCtrl.text.trim();

      if (provider.isEmpty) {
        Get.snackbar('Validation', 'Please select or enter your Mobile Money provider',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (phone.isEmpty) {
        Get.snackbar('Validation', 'Please enter your Mobile Money phone number',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (beneficiary.isEmpty) {
        Get.snackbar('Validation', 'Please enter the registered beneficiary name',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    final info = PayoutInfoEntity(
      methodType: currentMethod,
      bankName: bankNameCtrl.text.trim(),
      accountNumber: accountNumCtrl.text.trim(),
      accountHolderName: holderNameCtrl.text.trim(),
      routingNumber: routingCtrl.text.trim(),
      mobileMoneyProvider: mmProviderCtrl.text.trim(),
      mobileMoneyNumber: mmNumberCtrl.text.trim(),
      beneficiaryName: mmBeneficiaryCtrl.text.trim(),
    );

    controller.savePayoutInfo(info);
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

                      // Method Selector Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lightCardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => currentMethod = PayoutMethodType.bank),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: currentMethod == PayoutMethodType.bank
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.bankAccount,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: currentMethod == PayoutMethodType.bank
                                            ? Colors.white
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => currentMethod = PayoutMethodType.mobileMoney),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: currentMethod == PayoutMethodType.mobileMoney
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.mobileMoney,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: currentMethod == PayoutMethodType.mobileMoney
                                            ? Colors.white
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      if (currentMethod == PayoutMethodType.bank) ...[
                        CustomTextField(
                          controller: bankNameCtrl,
                          label: AppStrings.bankName,
                          hintText: 'Sierra Leone Commercial Bank',
                          prefixIcon: Icons.account_balance_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: accountNumCtrl,
                          label: AppStrings.accountNumber,
                          hintText: '•••• 8829',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.tag,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: holderNameCtrl,
                          label: AppStrings.accountHolder,
                          hintText: 'Ibrahim Koroma',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: routingCtrl,
                          label: 'Routing / Sort Code / IBAN',
                          hintText: '021000021',
                          prefixIcon: Icons.tag,
                        ),
                      ] else ...[
                        CustomTextField(
                          controller: mmProviderCtrl,
                          label: AppStrings.mobileMoneyProvider,
                          hintText: 'Orange Money',
                          prefixIcon: Icons.phone_android_outlined,
                        ),
                        const SizedBox(height: 8),
                        // Quick Provider Selector Chips
                        Wrap(
                          spacing: 8,
                          children: popularMMProviders.map((prov) {
                            final isSelected = mmProviderCtrl.text == prov;
                            return ChoiceChip(
                              label: Text(prov),
                              selected: isSelected,
                              selectedColor: AppColors.primaryContainer.withAlpha(50),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  mmProviderCtrl.text = prov;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mmNumberCtrl,
                          label: AppStrings.mobileMoneyNumber,
                          hintText: '76123456',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: mmBeneficiaryCtrl,
                          label: AppStrings.beneficiaryName,
                          hintText: 'Ibrahim Koroma',
                          prefixIcon: Icons.person_outline,
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
