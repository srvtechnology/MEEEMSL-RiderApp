import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../domain/entities/order_entity.dart';
import '../controllers/dashboard_controller.dart';

/// Modal dialog conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md Section 6.1:
/// Emergency Cancellation & Auto-Reassignment
class EmergencyReassignDialog extends StatefulWidget {
  final OrderEntity order;

  const EmergencyReassignDialog({super.key, required this.order});

  @override
  State<EmergencyReassignDialog> createState() =>
      _EmergencyReassignDialogState();
}

class _EmergencyReassignDialogState extends State<EmergencyReassignDialog> {
  final List<String> reasons = [
    'Vehicle breakdown',
    'Personal emergency',
    'Store was closed',
    'Severe weather / impassable road',
    'Motorbike tire puncture',
    'Order package damaged at store',
  ];

  late String selectedReason;
  final customReasonController = TextEditingController();
  bool isCustom = false;

  @override
  void initState() {
    super.initState();
    selectedReason = reasons.first;
  }

  @override
  void dispose() {
    customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        'Emergency Reassign',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorDark,
                        ),
                      ),
                      Text(
                        'Order #${widget.order.orderNumber}',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                  Expanded(
                    child: Text(
                      'This order will be automatically re-dispatched via waterfall to the next nearest candidate.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF9A3412),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Emergency Reason:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...reasons.map((reason) {
              final isSelected = !isCustom && selectedReason == reason;
              return InkWell(
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
                        color:
                            isSelected ? AppColors.error : Colors.grey.shade400,
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
            const SizedBox(height: 20),
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
                    child: const Text('Back to Order'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Confirm Cancel',
                    customColor: AppColors.error,
                    height: 44,
                    onPressed: () {
                      final reasonToSubmit = isCustom
                          ? customReasonController.text.trim()
                          : selectedReason;
                      Get.back();
                      controller.emergencyCancelActiveOrder(reasonToSubmit);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
