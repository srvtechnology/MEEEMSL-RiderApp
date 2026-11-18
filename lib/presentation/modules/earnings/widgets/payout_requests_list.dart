import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/rider_ledger_entity.dart';

/// Displays the rider's payout account snapshot and historical payout requests
/// (`GET /mobileapi/rider/payout-requests`).
/// Conforms to Section 6 & Section 8.2 of the Rider Payment Ledger Guide.
class PayoutRequestsList extends StatelessWidget {
  final RiderPayoutStatusEntity? payoutStatus;
  final String? fallbackPayoutMethod;
  final String? fallbackAccountSnapshot;
  final String currency;
  final bool isLoading;
  final String? errorMessage;
  final bool canRequestPayout;
  final VoidCallback onRequestPayout;
  final VoidCallback onRetry;
  final VoidCallback? onManagePayoutAccount;

  const PayoutRequestsList({
    super.key,
    required this.payoutStatus,
    this.fallbackPayoutMethod,
    this.fallbackAccountSnapshot,
    this.currency = 'NLe',
    required this.isLoading,
    this.errorMessage,
    required this.canRequestPayout,
    required this.onRequestPayout,
    required this.onRetry,
    this.onManagePayoutAccount,
  });

  List<RiderPayoutRequestEntity> _mergedRequests() {
    final history = payoutStatus?.history ?? const <RiderPayoutRequestEntity>[];
    final pending = payoutStatus?.pendingRequest;
    if (pending == null) return history;
    final existsInHistory = history.any((item) => item.id == pending.id);
    if (existsInHistory) return history;
    return [pending, ...history];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    if (isLoading && payoutStatus == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null && payoutStatus == null) {
      return _buildErrorCard(context, textPrimary, textSecondary, borderColor);
    }

    final method = payoutStatus?.payoutMethod ?? fallbackPayoutMethod;
    final snapshot = payoutStatus?.payoutAccountSnapshot ?? fallbackAccountSnapshot;
    final requests = _mergedRequests();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Payout Account Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDark.withAlpha(140)
                      : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  (method ?? '').toLowerCase().contains('bank')
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method != null && method.isNotEmpty
                                ? 'Payout Account • $method'
                                : 'Payout Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onManagePayoutAccount != null)
                          TextButton(
                            onPressed: onManagePayoutAccount,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      snapshot != null && snapshot.trim().isNotEmpty
                          ? snapshot.trim()
                          : 'No bank or mobile money account configured yet.',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Payout Request History',
                style: AppTextStyles.titleMedium(color: textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${requests.length} ${requests.length == 1 ? 'request' : 'requests'}',
              style: AppTextStyles.bodySmall(color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3. History List or Empty State
        if (requests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(Icons.payments_outlined, size: 42, color: textSecondary),
                const SizedBox(height: 10),
                Text(
                  'No Payout Requests Yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'When you request a payout of your AfriMoney wallet balance, its status and disbursement receipt will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: textSecondary),
                ),
                if (canRequestPayout) ...[
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: onRequestPayout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 42),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Request Payout Now'),
                  ),
                ],
              ],
            ),
          )
        else
          Column(
            children: requests
                .map((req) => _buildRequestCard(context, req, isDark, textPrimary, textSecondary, borderColor))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RiderPayoutRequestEntity req,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    late final Color statusBg;
    late final Color statusBorder;
    late final Color statusFg;
    late final IconData statusIcon;
    late final String statusLabel;

    if (req.isDisbursed) {
      statusBg = isDark ? const Color(0xFF064E3B).withAlpha(150) : const Color(0xFFECFDF5);
      statusBorder = const Color(0xFF10B981).withAlpha(140);
      statusFg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'DISBURSED';
    } else if (req.isRejected) {
      statusBg = isDark ? const Color(0xFF450A0A).withAlpha(150) : const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFEF4444).withAlpha(140);
      statusFg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'REJECTED';
    } else {
      statusBg = isDark ? const Color(0xFF451A03).withAlpha(150) : const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFF59E0B).withAlpha(140);
      statusFg = isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309);
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = 'PENDING';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: req.isPending ? const Color(0xFFF59E0B) : borderColor,
          width: req.isPending ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Requested Amount + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatRevenueAmount(
                        req.requestedAmount,
                        currency: currency,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    if (req.payoutMethod != null && req.payoutMethod!.isNotEmpty)
                      Text(
                        'via ${req.payoutMethod}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13.5, color: statusFg),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusFg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Payout Reference (copyable)
          if (req.payoutReference != null && req.payoutReference!.trim().isNotEmpty) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: req.payoutReference!.trim()));
                if (Get.overlayContext != null) {
                  Get.snackbar(
                    'Reference Copied',
                    req.payoutReference!.trim(),
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withAlpha(110)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(100)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 15,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ref: ${req.payoutReference!.trim()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF065F46),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Timestamps
          _buildInfoRow(
            Icons.schedule_rounded,
            'Requested',
            Formatters.formatFullDateTime(req.requestedAt),
            textPrimary,
            textSecondary,
          ),
          if (req.disbursedAt != null) ...[
            const SizedBox(height: 5),
            _buildInfoRow(
              Icons.check_circle_outline_rounded,
              'Disbursed',
              Formatters.formatFullDateTime(req.disbursedAt!),
              textPrimary,
              textSecondary,
            ),
          ],

          // Account Snapshot
          if (req.payoutAccountSnapshot != null &&
              req.payoutAccountSnapshot!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.account_balance_wallet_outlined,
              'Account',
              req.payoutAccountSnapshot!.trim(),
              textPrimary,
              textSecondary,
            ),
          ],

          // Rider Note & Admin Note
          if (req.sellerNote != null && req.sellerNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.notes_rounded,
              'Your Note',
              req.sellerNote!.trim(),
              textPrimary,
              textSecondary,
            ),
          ],
          if (req.adminNote != null && req.adminNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.admin_panel_settings_outlined,
              'Admin Note',
              req.adminNote!.trim(),
              textPrimary,
              textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 13.5, color: textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Could Not Load Payouts',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 40)),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
