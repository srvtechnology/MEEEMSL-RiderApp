import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/pending_approval_controller.dart';

class PendingApprovalView extends GetView<PendingApprovalController> {
  const PendingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Application Status'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.checkApprovalStatus(silent: false),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Obx(() {
            final rider = controller.riderProfile.value;
            final user = controller.userProfile.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Status Card
                _buildHeroStatusCard(context, rider, isDark),

                const SizedBox(height: 16),

                // 2. Admin Feedback (if present)
                if (rider?.adminFeedback != null && rider!.adminFeedback!.isNotEmpty) ...[
                  _buildAdminFeedbackCard(rider.adminFeedback!, isDark),
                  const SizedBox(height: 16),
                ],

                // 3. Document Verification Checklist Card
                _buildVerificationChecklistCard(context, rider, isDark),

                const SizedBox(height: 16),

                // 4. Submitted Application Summary Card
                _buildApplicationSummaryCard(context, rider, user, isDark),

                const SizedBox(height: 24),

                // 5. Action Buttons
                CustomButton(
                  text: controller.isChecking.value ? 'Checking Status...' : 'Check Approval Status',
                  icon: Icons.refresh_rounded,
                  isLoading: controller.isChecking.value,
                  onPressed: () => controller.checkApprovalStatus(silent: false),
                ),

                if (controller.lastChecked.value != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last checked: ${_formatTime(controller.lastChecked.value!)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                CustomButton(
                  text: 'Need Help? Contact Support',
                  type: ButtonType.outline,
                  icon: Icons.support_agent_rounded,
                  onPressed: () => controller.contactSupport(),
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton.icon(
                    onPressed: () => controller.logout(),
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeroStatusCard(BuildContext context, dynamic rider, bool isDark) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Animated / Glowing Icon Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warningLight.withAlpha(160),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withAlpha(40),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 40,
              color: AppColors.warningDark,
            ),
          ),
          const SizedBox(height: 16),
          const StatusBadge(
            text: 'PENDING APPROVAL',
            type: BadgeType.warning,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 12),
          Text(
            'Application Under Review',
            style: AppTextStyles.headlineSmall().copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for submitting your onboarding details. Your application and KYC documents are currently being verified by our operations team.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Reviews usually take 24 to 48 hours',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFeedbackCard(String feedback, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.feedback_outlined, color: Color(0xFFB45309), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Review Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78350F),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationChecklistCard(BuildContext context, dynamic rider, bool isDark) {
    final hasDl = (rider?.drivingLicenseDoc != null && (rider.drivingLicenseDoc as String).isNotEmpty) ||
        (rider?.drivingLicenseNo != null && (rider.drivingLicenseNo as String).isNotEmpty);
    final hasNid = rider?.nationalIdDoc != null && (rider.nationalIdDoc as String).isNotEmpty;
    final hasIns = rider?.vehicleInsuranceDoc != null && (rider.vehicleInsuranceDoc as String).isNotEmpty;

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Document Verification',
                style: AppTextStyles.titleMedium().copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCheckItem(
            title: "Driver's License",
            status: hasDl ? 'Submitted' : 'Pending',
            isDone: hasDl,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildCheckItem(
            title: 'National Identity Document',
            status: hasNid ? 'Submitted' : 'Pending',
            isDone: hasNid,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildCheckItem(
            title: 'Vehicle Insurance Policy',
            status: hasIns ? 'Submitted' : 'Pending',
            isDone: hasIns,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildCheckItem(
            title: 'Administrative Review',
            status: 'In Progress',
            isDone: false,
            isDark: isDark,
            isPending: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required String status,
    required bool isDone,
    required bool isDark,
    bool isPending = false,
  }) {
    return Row(
      children: [
        Icon(
          isDone
              ? Icons.check_circle_rounded
              : (isPending ? Icons.pending_rounded : Icons.radio_button_unchecked_rounded),
          size: 20,
          color: isDone
              ? AppColors.success
              : (isPending ? AppColors.warning : (isDark ? Colors.white38 : Colors.black26)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDone
                ? AppColors.success
                : (isPending
                    ? AppColors.warningDark
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationSummaryCard(
    BuildContext context,
    dynamic rider,
    dynamic user,
    bool isDark,
  ) {
    final name = (rider?.name != null && (rider.name as String).isNotEmpty)
        ? rider.name
        : (user?.name ?? 'Rider');
    final phone = (rider?.phone != null && (rider.phone as String).isNotEmpty)
        ? rider.phone
        : (user?.phone ?? '-');
    final vehicle = rider?.vehicleName ?? rider?.vehicleType ?? '2_WHEELER';
    final plate = rider?.vehicleNumber ?? '-';
    final dlNo = rider?.drivingLicenseNo ?? '-';

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Application Summary',
                style: AppTextStyles.titleMedium().copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Applicant Name', name, isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Phone Number', phone, isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Vehicle', vehicle, isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Plate / Reg Number', plate, isDark),
          const SizedBox(height: 10),
          _buildInfoRow("Driver's License No", dlNo, isDark),
          if (rider?.selectedZones != null && (rider.selectedZones as List).isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow('Operating Zones', (rider.selectedZones as List).join(', '), isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
