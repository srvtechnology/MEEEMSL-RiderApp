import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/legal_document_entity.dart';
import 'package:meeem_rider/domain/usecases/legal/get_legal_documents_usecase.dart';
import 'package:meeem_rider/presentation/modules/legal/controllers/legal_controller.dart';
import 'package:meeem_rider/presentation/modules/legal/views/legal_terms_privacy_view.dart';

class MockGetLegalDocumentsUseCase extends Mock implements GetLegalDocumentsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGetLegalDocumentsUseCase mockUseCase;

  const sampleDoc = LegalTermsAndPrivacyEntity(
    documentType: 'all',
    terms: LegalDocumentEntity(
      id: 'terms-id',
      slug: 'terms-slug',
      title: 'MEEEM Terms and Conditions',
      version: '1.0',
      lastUpdated: 'September 2026',
      summary: 'Delivery Partner Agreement Summary',
      highlights: [
        LegalHighlightEntity(
          icon: 'Wallet',
          title: '100% Tips',
          description: 'Keep all tips paid by customers',
        ),
      ],
      sections: [
        LegalSectionEntity(
          id: 'sec-1',
          number: '1',
          title: 'Eligibility Requirements',
          summary: 'Minimum age and verification',
          content: 'Must be 18 years or older with valid ID.',
          bullets: ['Valid driver license', 'Clear background check'],
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
          content: 'Location tracked in background while online.',
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

  Widget createWidgetUnderTest() {
    return const GetMaterialApp(
      home: LegalTermsPrivacyView(),
    );
  }

  group('LegalTermsPrivacyView Widget Tests', () {
    testWidgets('renders loading state initially', (tester) async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async {
            // Delayed response
            await Future.delayed(const Duration(milliseconds: 200));
            return const Right(sampleDoc);
          });

      Get.put(LegalController(getLegalDocumentsUseCase: mockUseCase));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Legal & Compliance'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading legal policies...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders terms document with highlights and sections on success', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      Get.put(LegalController(getLegalDocumentsUseCase: mockUseCase));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check App Bar
      expect(find.text('Legal & Compliance'), findsOneWidget);

      // Check Tabs
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Check Document Title and Badges
      expect(find.text('MEEEM Terms and Conditions'), findsOneWidget);
      expect(find.text('v1.0'), findsOneWidget);
      expect(find.text('Updated: September 2026'), findsOneWidget);

      // Check Highlight
      expect(find.text('100% Tips'), findsOneWidget);
      expect(find.text('Keep all tips paid by customers'), findsOneWidget);

      // Check Section
      expect(find.text('Eligibility Requirements'), findsOneWidget);
      expect(find.text('Minimum age and verification'), findsOneWidget);
      expect(find.text('Must be 18 years or older with valid ID.'), findsOneWidget);
    });

    testWidgets('switching tab to Privacy Policy renders privacy content and background GPS banner', (tester) async {
      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      Get.put(LegalController(getLegalDocumentsUseCase: mockUseCase));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Privacy Policy Tab
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      // Check Privacy document elements
      expect(find.text('MEEEM Privacy Policy'), findsOneWidget);
      expect(find.text('Continuous Background GPS Disclosure'), findsOneWidget);
      expect(find.text('Background Location Tracking'), findsOneWidget);
    });

    testWidgets('search filters sections', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockUseCase(type: 'all'))
          .thenAnswer((_) async => const Right(sampleDoc));

      Get.put(LegalController(getLegalDocumentsUseCase: mockUseCase));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Eligibility Requirements'), findsOneWidget);

      // Enter search query that does not match
      await tester.enterText(find.byType(TextField), 'nonexistent clause');
      await tester.pumpAndSettle();

      expect(find.text('No clauses match "nonexistent clause"'), findsOneWidget);

      // Enter search query that matches
      await tester.enterText(find.byType(TextField), 'driver license');
      await tester.pumpAndSettle();

      expect(find.text('Eligibility Requirements'), findsOneWidget);
    });
  });
}
