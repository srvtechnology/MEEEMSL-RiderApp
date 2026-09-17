import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/domain/entities/legal_document_entity.dart';
import 'package:meeem_rider/domain/usecases/legal/get_legal_documents_usecase.dart';
import 'package:meeem_rider/presentation/modules/legal/controllers/legal_controller.dart';

class MockGetLegalDocumentsUseCase extends Mock implements GetLegalDocumentsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGetLegalDocumentsUseCase mockUseCase;
  late LegalController controller;

  const sampleDoc = LegalTermsAndPrivacyEntity(
    documentType: 'all',
    terms: LegalDocumentEntity(
      id: 'terms-id',
      slug: 'terms-slug',
      title: 'MEEEM Terms and Conditions',
      version: '1.0',
      lastUpdated: 'September 2026',
      summary: 'Delivery Partner Agreement',
      highlights: [
        LegalHighlightEntity(
          icon: 'Wallet',
          title: '100% Tips',
          description: 'Keep all tips',
        ),
      ],
      sections: [
        LegalSectionEntity(
          id: 'sec-1',
          number: '1',
          title: 'Eligibility Requirements',
          summary: 'Minimum age and verification',
          content: 'Must be 18 years or older',
          bullets: ['Valid driver license', 'Clear background check'],
        ),
        LegalSectionEntity(
          id: 'sec-2',
          number: '2',
          title: 'Payout Structure',
          summary: 'Weekly automatic payouts',
          content: 'Earnings are transferred directly',
          bullets: ['Direct deposit', 'Mobile money support'],
        ),
      ],
    ),
    privacy: LegalDocumentEntity(
      id: 'privacy-id',
      slug: 'privacy-slug',
      title: 'MEEEM Privacy Policy',
      version: '1.0',
      lastUpdated: 'September 2026',
      summary: 'Rider privacy disclosures',
      sections: [
        LegalSectionEntity(
          id: 'background-location',
          number: '3',
          title: 'Background Location Tracking',
          summary: 'GPS telemetry while online',
          content: 'Location tracked in background',
          bullets: ['Stops when offline'],
        ),
      ],
    ),
  );

  setUp(() {
    Get.testMode = true;
    mockUseCase = MockGetLegalDocumentsUseCase();
  });

  tearDown(() {
    Get.reset();
  });

  group('LegalController Tests', () {
    test('fetches legal documents successfully and sets initial state', () async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      controller = LegalController(getLegalDocumentsUseCase: mockUseCase);
      controller.onInit();

      expect(controller.isLoading.value, isTrue);

      await Future.delayed(Duration.zero);

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.termsDocument.value, equals(sampleDoc.terms));
      expect(controller.privacyDocument.value, equals(sampleDoc.privacy));
      expect(controller.selectedTabIndex.value, 0);
      expect(controller.currentDocument, equals(sampleDoc.terms));

      // Check auto-expanded sections
      expect(controller.expandedSectionIds.contains('sec-1'), isTrue);
      expect(controller.expandedSectionIds.contains('background-location'), isTrue);
    });

    test('sets error message when usecase returns failure', () async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to load')));

      controller = LegalController(getLegalDocumentsUseCase: mockUseCase);
      controller.onInit();

      await Future.delayed(Duration.zero);

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, 'Failed to load');
      expect(controller.termsDocument.value, isNull);
    });

    test('switches tabs correctly', () async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      controller = LegalController(getLegalDocumentsUseCase: mockUseCase);
      controller.onInit();
      await Future.delayed(Duration.zero);

      expect(controller.selectedTabIndex.value, 0);
      expect(controller.currentDocument, equals(sampleDoc.terms));

      controller.switchTab(1);
      expect(controller.selectedTabIndex.value, 1);
      expect(controller.currentDocument, equals(sampleDoc.privacy));
    });

    test('toggles, expands all, and collapses sections', () async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      controller = LegalController(getLegalDocumentsUseCase: mockUseCase);
      controller.onInit();
      await Future.delayed(Duration.zero);

      // sec-1 is expanded initially
      expect(controller.expandedSectionIds.contains('sec-1'), isTrue);

      controller.toggleSection('sec-1');
      expect(controller.expandedSectionIds.contains('sec-1'), isFalse);

      controller.toggleSection('sec-1');
      expect(controller.expandedSectionIds.contains('sec-1'), isTrue);

      controller.expandAll(sampleDoc.terms);
      expect(controller.expandedSectionIds.contains('sec-1'), isTrue);
      expect(controller.expandedSectionIds.contains('sec-2'), isTrue);

      controller.collapseAll();
      expect(controller.expandedSectionIds.isEmpty, isTrue);
    });

    test('filters sections by search query in title, summary, or bullets', () async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      controller = LegalController(getLegalDocumentsUseCase: mockUseCase);
      controller.onInit();
      await Future.delayed(Duration.zero);

      // Search matching title 'Payout'
      controller.searchController.text = 'Payout';
      expect(controller.searchQuery.value, 'payout');
      var filtered = controller.getFilteredSections(sampleDoc.terms);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'sec-2');

      // Search matching bullet 'background check'
      controller.searchController.text = 'background check';
      filtered = controller.getFilteredSections(sampleDoc.terms);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'sec-1');

      // Empty search returns all
      controller.searchController.clear();
      filtered = controller.getFilteredSections(sampleDoc.terms);
      expect(filtered.length, 2);
    });
  });
}
