import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class PayoutRequestBottomSheet extends StatefulWidget {
  final double availableBalance;
  final Function(double amount, String method) onSubmitted;

  const PayoutRequestBottomSheet({
    super.key,
    required this.availableBalance,
    required this.onSubmitted,
  });

  @override
  State<PayoutRequestBottomSheet> createState() => _PayoutRequestBottomSheetState();
}

class _PayoutRequestBottomSheetState extends State<PayoutRequestBottomSheet> {
  final amountController = TextEditingController();
  String selectedMethod = 'Direct Bank Transfer (•••• 8829)';

  @override
  void initState() {
    super.initState();
    amountController.text = widget.availableBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Instant Cash Out', style: AppTextStyles.headlineSmall()),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Available: ${Formatters.formatCurrency(widget.availableBalance)}',
            style: AppTextStyles.bodyMedium(color: AppColors.primary),
          ),
          const SizedBox(height: 20),

          // Payout Amount
          CustomTextField(
            controller: amountController,
            label: 'Amount to Withdraw',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.payments_outlined,
          ),
          const SizedBox(height: 16),

          // Bank Account Selection
          const Text('Destination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(selectedMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: 'Confirm Cash Out',
            type: ButtonType.secondary,
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim()) ?? widget.availableBalance;
              widget.onSubmitted(amount, selectedMethod);
            },
          ),
        ],
      ),
    );
  }
}
