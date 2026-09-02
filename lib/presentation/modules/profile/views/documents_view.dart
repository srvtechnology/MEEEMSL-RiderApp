import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../domain/entities/document_entity.dart';
import '../controllers/profile_controller.dart';

class DocumentsView extends GetView<ProfileController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.documents),
      ),
      body: Obx(() {
        final docs = controller.documents;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Verification & Compliance', style: AppTextStyles.headlineSmall()),
            const SizedBox(height: 4),
            Text(
              'Keep your legal documents up-to-date to ensure uninterrupted access to delivery dispatch.',
              style: AppTextStyles.bodyMedium(),
            ),
            const SizedBox(height: 20),

            if (docs.isEmpty && controller.isLoading.value)
              const Center(child: CircularProgressIndicator())
            else
              ...docs.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: doc.status == DocumentStatus.verified
                                  ? AppColors.successLight
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              doc.status == DocumentStatus.verified
                                  ? Icons.verified_user
                                  : Icons.description_outlined,
                              color: doc.status == DocumentStatus.verified
                                  ? AppColors.successDark
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.title, style: AppTextStyles.titleMedium()),
                                const SizedBox(height: 2),
                                Text(
                                  'Number: ${doc.documentNumber} • Exp: ${doc.expiryDate}',
                                  style: AppTextStyles.bodySmall(),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(
                                text: doc.status.name.toUpperCase(),
                                type: doc.status == DocumentStatus.verified
                                    ? BadgeType.success
                                    : (doc.status == DocumentStatus.pending ? BadgeType.warning : BadgeType.error),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () => controller.uploadDoc(doc.type),
                                child: const Text('Update', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        );
      }),
    );
  }
}
