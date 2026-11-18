import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/rider_ledger_entity.dart';

/// Hero KPI Card #1: Withdrawable Wallet Balance (`summary.netBalance`)
/// with "Request Payout" CTA button and disabled/pending states.
/// Conforms to Section 8.1(a) & Section 8.3 of the Rider Payment Ledger Guide.
class WithdrawableWalletCard extends StatelessWidget {
  final double balance;
  final String currency;
  final bool hasPendingPayoutRequest;
  final bool isSubmittingPayout;
  final String? payoutMethodLabel;
  final VoidCallback? onRequestPayout;

  const WithdrawableWalletCard({
    super.key,
    required this.balance,
    this.currency = 'NLe',
    this.hasPendingPayoutRequest = false,
    this.isSubmittingPayout = false,
    this.payoutMethodLabel,
    this.onRequestPayout,
  });

  bool get _isButtonEnabled =>
      balance > 0 && !hasPendingPayoutRequest && !isSubmittingPayout && onRequestPayout != null;

  @override
  Widget build(BuildContext context) {
    final formattedBalance = Formatters.formatRevenueAmount(balance, currency: currency);

    String statusHelper;
    if (hasPendingPayoutRequest) {
      statusHelper = 'A payout request is currently pending Admin disbursement.';
    } else if (balance <= 0) {
      statusHelper = 'Complete prepaid (AfriMoney) deliveries to build withdrawable balance.';
    } else {
      statusHelper = 'Prepaid (AfriMoney) delivery fees ready for payout.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0834C2), Color(0xFF1643B8), Color(0xFF0F6B5B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x380834C2),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.withdrawableWallet,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (payoutMethodLabel != null && payoutMethodLabel!.trim().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(32),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          payoutMethodLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statusHelper,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('request_payout_cta_button'),
              onPressed: _isButtonEnabled ? onRequestPayout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white.withAlpha(45),
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isSubmittingPayout
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      hasPendingPayoutRequest
                          ? Icons.hourglass_top_rounded
                          : Icons.payments_rounded,
                      size: 18,
                    ),
              label: Text(
                hasPendingPayoutRequest
                    ? 'Payout Request Pending'
                    : AppStrings.requestPayout,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Amber banner shown when `hasPendingPayoutRequest === true`.
/// Conforms to Section 8.3 of the Rider Payment Ledger Guide.
class PendingPayoutBanner extends StatelessWidget {
  final RiderPayoutRequestEntity? pendingRequest;
  final double fallbackAmount;
  final String currency;
  final VoidCallback? onViewPayouts;

  const PendingPayoutBanner({
    super.key,
    this.pendingRequest,
    required this.fallbackAmount,
    this.currency = 'NLe',
    this.onViewPayouts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = pendingRequest?.requestedAmount ?? fallbackAmount;
    final formattedAmount = Formatters.formatRevenueAmount(amount, currency: currency);
    final requestedDate = pendingRequest != null
        ? Formatters.formatFullDateTime(pendingRequest!.requestedAt)
        : null;
    final method = pendingRequest?.payoutMethod;

    return Container(
      key: const Key('pending_payout_amber_banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF451A03).withAlpha(180) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withAlpha(isDark ? 65 : 35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFFD97706),
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.pendingPayoutBannerTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$formattedAmount${method != null && method.isNotEmpty ? ' via $method' : ''}'
                  '${requestedDate != null ? ' • Requested $requestedDate' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                    height: 1.35,
                  ),
                ),
                if (onViewPayouts != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onViewPayouts,
                    child: Text(
                      'View Payout Request Details →',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable KPI summary card for Total Delivery Earnings, Prepaid AfriMoney,
/// COD Earnings & Cash Collected, and In-Progress Potential.
class RevenueKpiCard extends StatefulWidget {
  final String title;
  final double amount;
  final String currency;
  final String caption;
  final String? secondaryBadgeText;
  final IconData icon;
  final bool isDelivered;
  final bool isCompact;
  final bool showPulseIndicator;
  final Gradient gradient;
  final Color shadowColor;

  const RevenueKpiCard({
    super.key,
    required this.title,
    required this.amount,
    this.currency = 'NLe',
    required this.caption,
    this.secondaryBadgeText,
    required this.icon,
    required this.isDelivered,
    this.isCompact = false,
    this.showPulseIndicator = false,
    required this.gradient,
    required this.shadowColor,
  });

  /// KPI #2: Total Delivery Earnings (Combined AfriMoney + COD delivery fees earned)
  factory RevenueKpiCard.delivered({
    Key? key,
    required double amount,
    int count = 0,
    String currency = 'NLe',
  }) {
    final countText =
        '$count Completed Deliver${count == 1 ? 'y' : 'ies'} (AfriMoney + COD)';
    return RevenueKpiCard(
      key: key,
      title: AppStrings.totalDeliveryEarnings,
      amount: amount,
      currency: currency,
      caption: countText,
      icon: Icons.verified_rounded,
      isDelivered: true,
      gradient: const LinearGradient(
        colors: [Color(0xFF0D7A4A), Color(0xFF16A34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x3316A34A),
    );
  }

  /// KPI #3: Prepaid (AfriMoney) Earnings credited to Rider Wallet for Admin payout
  factory RevenueKpiCard.prepaid({
    Key? key,
    required double amount,
    String currency = 'NLe',
  }) {
    return RevenueKpiCard(
      key: key,
      title: AppStrings.prepaidAfriMoneyEarnings,
      amount: amount,
      currency: currency,
      caption: AppStrings.creditedToWalletForPayout,
      icon: Icons.phone_android_rounded,
      isDelivered: true,
      isCompact: true,
      gradient: const LinearGradient(
        colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x334F46E5),
    );
  }

  /// KPI #4: COD Earnings & Cash Collected (Collected in Cash at Doorstep)
  factory RevenueKpiCard.cod({
    Key? key,
    required double codDeliveryEarnings,
    required double codCashCollectedTotal,
    String currency = 'NLe',
  }) {
    final cashStr = Formatters.formatRevenueAmount(
      codCashCollectedTotal,
      currency: currency,
    );
    return RevenueKpiCard(
      key: key,
      title: AppStrings.codEarningsAndCash,
      amount: codDeliveryEarnings,
      currency: currency,
      secondaryBadgeText: 'Cash Collected: $cashStr',
      caption: AppStrings.collectedInCashAtDoorstep,
      icon: Icons.payments_outlined,
      isDelivered: true,
      isCompact: true,
      gradient: const LinearGradient(
        colors: [Color(0xFFB45309), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x33D97706),
    );
  }

  /// Secondary Status KPI: Active In-Transit Drops Potential
  factory RevenueKpiCard.inProgress({
    Key? key,
    required double amount,
    int count = 0,
    String currency = 'NLe',
  }) {
    final countText = '$count Active In-Transit Drop${count == 1 ? '' : 's'}';
    return RevenueKpiCard(
      key: key,
      title: AppStrings.inProgressPotential,
      amount: amount,
      currency: currency,
      caption: countText,
      icon: Icons.local_shipping_rounded,
      isDelivered: false,
      showPulseIndicator: true,
      gradient: const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0x332563EB),
    );
  }

  @override
  State<RevenueKpiCard> createState() => _RevenueKpiCardState();
}

class _RevenueKpiCardState extends State<RevenueKpiCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.showPulseIndicator) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.isCompact;
    final formattedAmount = Formatters.formatRevenueAmount(
      widget.amount,
      currency: widget.currency,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 14 : 15,
      ),
      decoration: BoxDecoration(
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: EdgeInsets.all(compact ? 6 : 7),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: compact ? 15 : 18,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formattedAmount,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 20 : 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (widget.secondaryBadgeText != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.secondaryBadgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
          SizedBox(height: compact ? 8 : 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showPulseIndicator && _pulseAnimation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation!,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlueAccent.withAlpha(180),
                              blurRadius: 6 * _pulseAnimation!.value,
                              spreadRadius: 2 * _pulseAnimation!.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: compact ? const Color(0xFF1E293B) : const Color(0xFF16A34A),
                      size: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.caption,
                  style: TextStyle(
                    color: Colors.white.withAlpha(235),
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
