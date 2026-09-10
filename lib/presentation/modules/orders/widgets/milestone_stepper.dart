import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../domain/entities/order_entity.dart';

/// 5-Step Delivery Milestone Stepper Component
/// Conforms to MOBILE_RIDER_APP_API_DOC_PART_3.md Section 4.4 #2:
/// `[1. Accept Offer] -> [2. Arrive at Store] -> [3. Collect Package] -> [4. Out for Delivery] -> [5. Verify OTP & Complete]`
class MilestoneStepper extends StatelessWidget {
  final OrderStatus status;
  final bool showLabels;
  final bool isInteractive;

  const MilestoneStepper({
    super.key,
    required this.status,
    this.showLabels = true,
    this.isInteractive = false,
  });

  static const List<String> stepTitles = [
    'Accept Offer',
    'Arrive at Store',
    'Collect Package',
    'Out for Delivery',
    'Verify OTP & Complete',
  ];

  int get currentStepIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.atPickup:
        return 1;
      case OrderStatus.pickedUp:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStepIndex;
    final isDelivered = status == OrderStatus.delivered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'DELIVERY MILESTONES (5 STEPS)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(color: AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDelivered ? AppColors.successLight : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status.stepNumberText.isNotEmpty ? status.stepNumberText : 'Step ${activeIndex + 1} of 5',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDelivered ? AppColors.successDark : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stepper Visual Row
        Row(
          children: List.generate(stepTitles.length, (index) {
            // A step is completed if current index is greater than this step, or if delivered
            final isCompleted = isDelivered || index < activeIndex;
            final isCurrent = !isDelivered && index == activeIndex;

            return Expanded(
              child: Row(
                children: [
                  // Step Indicator Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : (isCurrent ? AppColors.primary : const Color(0xFFE2E8F0)),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(90),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 15, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isCurrent ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ),

                  // Connector Line
                  if (index < stepTitles.length - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index < activeIndex || isDelivered
                              ? AppColors.success
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // Step Label Row (when showLabels is true)
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(stepTitles.length, (index) {
              final isCompleted = isDelivered || index < activeIndex;
              final isCurrent = !isDelivered && index == activeIndex;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                    stepTitles[index],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                      color: isCurrent
                          ? AppColors.primary
                          : (isCompleted ? AppColors.successDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
