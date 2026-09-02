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
  final controller = Get.find<ProfileController>();

  late PayoutMethodType currentMethod;
  final bankNameCtrl = TextEditingController();
  final accountNumCtrl = TextEditingController();
  final holderNameCtrl = TextEditingController();
  final routingCtrl = TextEditingController();

  final mmProviderCtrl = TextEditingController();
  final mmNumberCtrl = TextEditingController();
  final mmBeneficiaryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final info = controller.payoutInfo.value;
    currentMethod = info?.methodType ?? PayoutMethodType.bank;

    bankNameCtrl.text = info?.bankName ?? 'Chase Bank USA';
    accountNumCtrl.text = info?.accountNumber ?? '9920184920';
    holderNameCtrl.text = info?.accountHolderName ?? 'Alex Johnson';
    routingCtrl.text = info?.routingNumber ?? '021000021';

    mmProviderCtrl.text = info?.mobileMoneyProvider ?? 'M-Pesa';
    mmNumberCtrl.text = info?.mobileMoneyNumber ?? '+1 555 234 5678';
    mmBeneficiaryCtrl.text = info?.beneficiaryName ?? 'Alex Johnson';
  }

  @override
  void dispose() {
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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

                    // Method Selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
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

                    if (currentMethod == PayoutMethodType.bank) ...[
                      CustomTextField(
                        controller: bankNameCtrl,
                        label: AppStrings.bankName,
                        hintText: 'Chase Bank USA',
                        prefixIcon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: accountNumCtrl,
                        label: AppStrings.accountNumber,
                        hintText: '9920184920',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.numbers_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: holderNameCtrl,
                        label: AppStrings.accountHolder,
                        hintText: 'Alex Johnson',
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
                        hintText: 'e.g. M-Pesa, MTN MoMo, Airtel, GCash',
                        prefixIcon: Icons.phone_android_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: mmNumberCtrl,
                        label: AppStrings.mobileMoneyNumber,
                        hintText: '+1 555 234 5678',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: mmBeneficiaryCtrl,
                        label: AppStrings.beneficiaryName,
                        hintText: 'Alex Johnson',
                        prefixIcon: Icons.person_outline,
                      ),
                    ],
                  ],
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
              child: CustomButton(
                text: 'Save Payout Details',
                icon: Icons.check,
                isLoading: controller.isLoading.value,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
