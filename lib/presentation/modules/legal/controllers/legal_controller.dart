import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/entities/legal_document_entity.dart';
import '../../../../domain/usecases/legal/get_legal_documents_usecase.dart';

class LegalController extends GetxController {
  final GetLegalDocumentsUseCase getLegalDocumentsUseCase;

  LegalController({required this.getLegalDocumentsUseCase});

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedTabIndex = 0.obs; // 0: Terms, 1: Privacy

  final Rxn<LegalDocumentEntity> termsDocument = Rxn<LegalDocumentEntity>();
  final Rxn<LegalDocumentEntity> privacyDocument = Rxn<LegalDocumentEntity>();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxSet<String> expandedSectionIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Check navigation arguments for initial tab selection
    if (Get.arguments is Map) {
      final tab = Get.arguments['initialTab'] ?? Get.arguments['tab'];
      if (tab == 'privacy') {
        selectedTabIndex.value = 1;
      } else if (tab == 'terms') {
        selectedTabIndex.value = 0;
      }
    }

    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });

    fetchLegalDocuments();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchLegalDocuments() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getLegalDocumentsUseCase(type: 'all');
    result.fold(
      (failure) {
        isLoading.value = false;
        errorMessage.value = failure.message;
      },
      (data) {
        isLoading.value = false;
        termsDocument.value = data.terms;
        privacyDocument.value = data.privacy;

        // By default, expand the first section and background location disclosure
        expandedSectionIds.clear();
        if (data.terms != null && data.terms!.sections.isNotEmpty) {
          expandedSectionIds.add(data.terms!.sections.first.id);
        }
        if (data.privacy != null && data.privacy!.sections.isNotEmpty) {
          expandedSectionIds.add(data.privacy!.sections.first.id);
          // Also auto-expand background-location section if present
          for (final section in data.privacy!.sections) {
            if (section.id == 'background-location' || section.title.toLowerCase().contains('background location')) {
              expandedSectionIds.add(section.id);
            }
          }
        }
      },
    );
  }

  void switchTab(int index) {
    if (selectedTabIndex.value != index) {
      selectedTabIndex.value = index;
    }
  }

  void toggleSection(String sectionId) {
    if (expandedSectionIds.contains(sectionId)) {
      expandedSectionIds.remove(sectionId);
    } else {
      expandedSectionIds.add(sectionId);
    }
  }

  void expandAll(LegalDocumentEntity? doc) {
    if (doc == null) return;
    for (final sec in doc.sections) {
      expandedSectionIds.add(sec.id);
    }
  }

  void collapseAll() {
    expandedSectionIds.clear();
  }

  LegalDocumentEntity? get currentDocument {
    return selectedTabIndex.value == 0 ? termsDocument.value : privacyDocument.value;
  }

  List<LegalSectionEntity> getFilteredSections(LegalDocumentEntity? doc) {
    if (doc == null) return [];
    final query = searchQuery.value;
    if (query.isEmpty) return doc.sections;

    return doc.sections.where((s) {
      final matchesTitle = s.title.toLowerCase().contains(query);
      final matchesSummary = s.summary.toLowerCase().contains(query);
      final matchesContent = s.content.toLowerCase().contains(query);
      final matchesBullets = s.bullets.any((b) => b.toLowerCase().contains(query));
      return matchesTitle || matchesSummary || matchesContent || matchesBullets;
    }).toList();
  }
}
