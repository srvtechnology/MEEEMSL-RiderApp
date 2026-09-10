import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../domain/entities/order_entity.dart';

/// Modal dialog conforming to
/// MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8.md Section 4.3:
/// Rider Emergency Trip Cancellation (CANCELLED_BY_RIDER).
class CancelDeliveryDialog extends StatefulWidget {
  final OrderEntity order;
  final ValueChanged<String> onConfirmed;

  const CancelDeliveryDialog({
    super.key,
    required this.order,
    required this.onConfirmed,
  });

  @override
  State<CancelDeliveryDialog> createState() => _CancelDeliveryDialogState();
}

class _CancelDeliveryDialogState extends State<CancelDeliveryDialog> {
  // 4 Standard reasons strictly specified in Part 8 Section 4.1 & 4.3
  static const List<String> standardReasons = [
    'Vehicle breakdown',
    'Personal emergency',
    'Store was closed',
    'Severe weather / impassable road',
  ];

  late String selectedReason;
  final customReasonController = TextEditingController();
  bool isCustom = false;

  @override
  void initState() {
    super.initState();
    selectedReason = standardReasons.first;
  }

  @override
  void dispose() {
    customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cancel Delivery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorDark,
                          ),
                        ),
                        Text(
                          widget.order.orderNumber.startsWith('#')
                              ? widget.order.orderNumber
                              : '#${widget.order.orderNumber}',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Information banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFC2410C), size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This trip will be cancelled immediately and re-dispatched to the next closest available rider.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF9A3412),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Select Cancellation Reason:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Standard reasons selection
              ...standardReasons.map((reason) {
                final isSelected = !isCustom && selectedReason == reason;
                return InkWell(
                  key: Key('reason_$reason'),
                  onTap: () {
                    setState(() {
                      isCustom = false;
                      selectedReason = reason;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? AppColors.error
                              : Colors.grey.shade400,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.textPrimaryLight
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Other / Custom Reason Option
              InkWell(
                key: const Key('reason_other'),
                onTap: () {
                  setState(() {
                    isCustom = true;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isCustom
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            isCustom ? AppColors.error : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Other reason',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              if (isCustom) ...[
                const SizedBox(height: 8),
                TextField(
                  key: const Key('custom_reason_field'),
                  controller: customReasonController,
                  decoration: InputDecoration(
                    hintText: 'Enter cancellation reason...',
                    hintStyle: AppTextStyles.bodySmall(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Keep Trip'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      key: const Key('confirm_cancel_button'),
                      text: 'Confirm Cancel',
                      customColor: AppColors.error,
                      height: 44,
                      onPressed: () {
                        final reasonToSubmit = isCustom
                            ? (customReasonController.text.trim().isNotEmpty
                                ? customReasonController.text.trim()
                                : 'Other reason')
                            : selectedReason;
                        Get.back();
                        widget.onConfirmed(reasonToSubmit);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
