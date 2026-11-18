import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_button.dart';

/// Bottom sheet for submitting a Rider Payout Request (`POST /mobileapi/rider/payout-requests`).
/// Conforms to Section 6B & Section 8.3 of the Rider Payment Ledger Guide.
class PayoutRequestBottomSheet extends StatefulWidget {
  final double availableBalance;
  final String currency;
  final String? payoutMethod;
  final String? payoutAccountSnapshot;
  final bool hasConfiguredPayoutAccount;
  final Future<bool> Function(String? sellerNote) onSubmitted;
  final VoidCallback? onManagePayoutAccount;

  const PayoutRequestBottomSheet({
    super.key,
    required this.availableBalance,
    this.currency = 'NLe',
    this.payoutMethod,
    this.payoutAccountSnapshot,
    this.hasConfiguredPayoutAccount = true,
    required this.onSubmitted,
    this.onManagePayoutAccount,
  });

  @override
  State<PayoutRequestBottomSheet> createState() => _PayoutRequestBottomSheetState();
}

class _PayoutRequestBottomSheetState extends State<PayoutRequestBottomSheet> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final note = _noteController.text.trim();
      final success = await widget.onSubmitted(note.isEmpty ? null : note);
      if (success && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.back();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    final methodLabel = (widget.payoutMethod != null && widget.payoutMethod!.trim().isNotEmpty)
        ? widget.payoutMethod!.trim()
        : 'Default Payout Account';
    final snapshotText = (widget.payoutAccountSnapshot != null &&
            widget.payoutAccountSnapshot!.trim().isNotEmpty)
        ? widget.payoutAccountSnapshot!.trim()
        : 'Using payout details configured in your Rider Profile.';

    return PopScope(
      canPop: !_isSubmitting,
      child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinned Drag Handle + Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark.withAlpha(140)
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: isDark ? Colors.white : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Wallet Payout',
                                style: AppTextStyles.headlineSmall(color: textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Admin will disburse your prepaid AfriMoney balance',
                                style: AppTextStyles.bodySmall(color: textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSecondary),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Get.back();
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Withdrawable Balance Callout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0834C2), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WITHDRAWABLE WALLET AMOUNT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Formatters.formatRevenueAmount(
                                  widget.availableBalance,
                                  currency: widget.currency,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 14, color: Colors.white70),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Your entire available wallet balance is included in this payout request.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Destination Account Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Payout Destination',
                              style: AppTextStyles.labelLarge(color: textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.onManagePayoutAccount != null)
                            TextButton(
                              onPressed: _isSubmitting ? null : widget.onManagePayoutAccount,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Edit Details',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryDark.withAlpha(120)
                                    : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                methodLabel.toLowerCase().contains('bank')
                                    ? Icons.account_balance_rounded
                                    : Icons.phone_android_rounded,
                                color: isDark ? Colors.white : AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    methodLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    snapshotText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.hasConfiguredPayoutAccount)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.onlineGreen,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (!widget.hasConfiguredPayoutAccount) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF451A03).withAlpha(140)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFD97706),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No payout account found on file. Please verify your AfriMoney or Bank details in Profile > Payout Information or include them in the note below.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFF92400E),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Optional Seller / Rider Note
                      Text(
                        'Note for Admin (Optional)',
                        style: AppTextStyles.labelLarge(color: textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        enabled: !_isSubmitting,
                        maxLines: 3,
                        minLines: 2,
                        maxLength: 240,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 13.5, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Please send to my AfriMoney wallet 077123456',
                          hintStyle: TextStyle(fontSize: 12.5, color: textSecondary),
                          counterStyle: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Pinned Bottom Action CTA (always visible & tappable even on compact screens/with keyboard)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: CustomButton(
                  text: _isSubmitting ? 'Submitting Request...' : 'Submit Payout Request',
                  icon: _isSubmitting ? null : Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
