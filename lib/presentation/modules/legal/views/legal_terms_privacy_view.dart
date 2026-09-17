import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../domain/entities/legal_document_entity.dart';
import '../controllers/legal_controller.dart';

class LegalTermsPrivacyView extends GetView<LegalController> {
  const LegalTermsPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal & Compliance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchLegalDocuments(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSegmentedTabSelector(context, isDark),
          _buildSearchBar(context, isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading legal policies...', style: TextStyle(color: AppColors.textSecondaryLight)),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return EmptyStateView(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Documents',
                  description: controller.errorMessage.value,
                  buttonText: 'Try Again',
                  onButtonPressed: () => controller.fetchLegalDocuments(),
                );
              }

              final doc = controller.currentDocument;
              if (doc == null) {
                return EmptyStateView(
                  icon: Icons.description_outlined,
                  title: 'No Document Found',
                  description: 'The requested legal document is not currently available.',
                  buttonText: 'Reload',
                  onButtonPressed: () => controller.fetchLegalDocuments(),
                );
              }

              final filteredSections = controller.getFilteredSections(doc);

              return RefreshIndicator(
                onRefresh: () => controller.fetchLegalDocuments(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildDocumentHeaderCard(doc, isDark),
                    const SizedBox(height: 16),

                    // Highlights Section
                    if (doc.highlights.isNotEmpty && controller.searchQuery.value.isEmpty) ...[
                      _buildHighlightsSection(doc.highlights, isDark),
                      const SizedBox(height: 20),
                    ],

                    // Background Location Disclosure Banner (for Privacy Policy)
                    if (controller.selectedTabIndex.value == 1 && controller.searchQuery.value.isEmpty) ...[
                      _buildBackgroundLocationBanner(isDark),
                      const SizedBox(height: 20),
                    ],

                    // Sections Header & Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DOCUMENT SECTIONS (${filteredSections.length})',
                          style: AppTextStyles.labelSmall(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
                        ),
                        Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => controller.expandAll(doc),
                              child: const Text('Expand All', style: TextStyle(fontSize: 12)),
                            ),
                            const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => controller.collapseAll(),
                              child: const Text('Collapse', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Filtered Sections List
                    if (filteredSections.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No clauses match "${controller.searchQuery.value}"',
                            style: AppTextStyles.bodyMedium(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredSections.map((section) => _buildSectionCard(section, isDark)),

                    const SizedBox(height: 24),
                    _buildFooterCard(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Obx(() {
        final currentTab = controller.selectedTabIndex.value;
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchTab(0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: currentTab == 0
                        ? (isDark ? AppColors.primary : AppColors.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: currentTab == 0
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: currentTab == 0
                            ? Colors.white
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchTab(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: currentTab == 1
                        ? (isDark ? AppColors.primary : AppColors.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: currentTab == 1
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: currentTab == 1
                            ? Colors.white
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search legal clauses (e.g. GPS, tips, payouts)...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () => controller.searchController.clear(),
              );
            }
            return const SizedBox.shrink();
          }),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeaderCard(LegalDocumentEntity doc, bool isDark) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: AppTextStyles.titleMedium(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'v${doc.version}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Updated: ${doc.lastUpdated}',
                          style: AppTextStyles.bodySmall(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doc.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              doc.summary,
              style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ).copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<LegalHighlightEntity> highlights, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KEY HIGHLIGHTS',
          style: AppTextStyles.labelSmall(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: highlights.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final h = highlights[index];
            return CustomCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getIconForHighlight(h.icon), size: 20, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Text(
                    h.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackgroundLocationBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(150),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continuous Background GPS Disclosure',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MEEEM collects high-precision location data in the background while your status is ONLINE to match nearby deliveries and calculate route pay. Location tracking immediately ceases when you toggle OFFLINE.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimaryContainer.withAlpha(210),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(LegalSectionEntity section, bool isDark) {
    return Obx(() {
      final isExpanded = controller.expandedSectionIds.contains(section.id);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => controller.toggleSection(section.id),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isExpanded ? AppColors.primary : AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          section.number,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isExpanded ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: AppTextStyles.titleSmall(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (section.summary.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                section.summary,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),

              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (section.content.isNotEmpty)
                        Text(
                          section.content,
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ).copyWith(height: 1.45),
                        ),
                      if (section.bullets.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...section.bullets.map((bullet) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      bullet,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFooterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Legal & Compliance Inquiries',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'For questions regarding these terms, your courier agreement, or data protection rights under the laws of Sierra Leone, contact legal compliance at privacy@meeemsl.com or support@meeemsl.com.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForHighlight(String icon) {
    switch (icon.toLowerCase()) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'clock':
        return Icons.access_time_rounded;
      case 'shieldcheck':
      case 'shield':
        return Icons.verified_user_rounded;
      case 'smartphone':
      case 'phone':
        return Icons.smartphone_rounded;
      case 'mappin':
      case 'location':
      case 'map':
        return Icons.location_on_rounded;
      case 'lock':
        return Icons.lock_outline_rounded;
      case 'phonecall':
        return Icons.phone_in_talk_rounded;
      case 'usercheck':
      case 'user':
        return Icons.how_to_reg_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
}
