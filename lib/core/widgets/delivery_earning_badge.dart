import 'package:flutter/material.dart';
import '../utils/formatters.dart';

/// Emerald Green badge displaying allocated delivery earnings on order cards
/// Conforms to MOBILE_RIDER_APP_API_DOC_PART_3.md Section 4.4 #1 & Section 7:
/// "Display: `Delivery Earning: NLe XX.XX` in emerald green on every delivery card."
class DeliveryEarningBadge extends StatelessWidget {
  final double amount;
  final bool isCompact;
  final bool showPrefix;

  const DeliveryEarningBadge({
    super.key,
    required this.amount,
    this.isCompact = false,
    this.showPrefix = true,
  });

  // Emerald Green Palette conforming to Part 3 specifications
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldBorder = Color(0xFFA7F3D0);
  static const Color emeraldText = Color(0xFF065F46);
  static const Color emeraldIcon = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final formatted = Formatters.formatCurrency(amount);
    final text = showPrefix ? 'Delivery Earning: $formatted' : formatted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: emeraldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: emeraldBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.payments_rounded,
            size: 14,
            color: emeraldIcon,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isCompact ? 11.5 : 12.5,
                fontWeight: FontWeight.w800,
                color: emeraldText,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
