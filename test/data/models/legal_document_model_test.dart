import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/legal_document_model.dart';

void main() {
  group('LegalDocumentModel Tests', () {
    final sampleJson = {
      'success': true,
      'documentType': 'all',
      'data': {
        'terms': {
          'id': 'rider-terms-and-conditions',
          'slug': 'rider-terms',
          'title': 'Delivery Partner & Rider Terms and Conditions',
          'version': '1.0',
          'lastUpdated': 'September 2026',
          'summary': 'Comprehensive delivery partner agreement...',
          'highlights': [
            {
              'icon': 'Wallet',
              'title': '100% Tips Pass-Through',
              'description': 'Keep 100% of tips paid by customers.',
            },
            {
              'icon': 'Clock',
              'title': 'Flexible Working Hours',
              'description': 'Operate on your own schedule.',
            }
          ],
          'sections': [
            {
              'id': 'eligibility',
              'number': '1',
              'title': 'Eligibility, Verification & Onboarding Requirements',
              'summary': 'Minimum legal standards and verification...',
              'content': 'To register, operate, and maintain an active profile...',
              'bullets': [
                'Be at least 18 years of age at the date of registration.',
                'Possess a valid national identification document...',
              ],
            }
          ],
          'content': '<div class="legal-document">...</div>',
          'rawText': 'DELIVERY PARTNER & RIDER TERMS AND CONDITIONS...',
        },
        'privacy': {
          'id': 'rider-privacy-policy',
          'slug': 'rider-privacy',
          'title': 'Delivery Partner & Rider Privacy Policy',
          'version': '1.0',
          'lastUpdated': 'September 2026',
          'summary': 'Comprehensive privacy disclosures detailing continuous background GPS...',
          'highlights': [
            {
              'icon': 'MapPin',
              'title': 'Background GPS Tracking',
              'description': 'Continuous location collection while Online.',
            }
          ],
          'sections': [
            {
              'id': 'background-location',
              'number': '3',
              'title': 'Background Location Tracking Disclosure',
              'summary': 'Critical disclosure on continuous background location services.',
              'content': 'MEEEM Rider App collects real-time, high-precision location data...',
              'bullets': [
                'Location is collected continuously while the Rider App is running in the background...',
                'Used to assign nearby orders and calculate precise route ETA...',
                'Tracking immediately stops when marked \'OFFLINE\'.',
              ],
            }
          ],
          'content': '<div class="legal-document">...</div>',
          'rawText': 'DELIVERY PARTNER & RIDER PRIVACY POLICY...',
        }
      }
    };

    test('should parse full legal documents response (type=all)', () {
      final model = LegalTermsAndPrivacyModel.fromJson(sampleJson);

      expect(model.documentType, 'all');
      expect(model.terms, isNotNull);
      expect(model.privacy, isNotNull);

      // Verify terms document
      final terms = model.terms!;
      expect(terms.id, 'rider-terms-and-conditions');
      expect(terms.slug, 'rider-terms');
      expect(terms.title, 'Delivery Partner & Rider Terms and Conditions');
      expect(terms.version, '1.0');
      expect(terms.lastUpdated, 'September 2026');
      expect(terms.highlights.length, 2);
      expect(terms.highlights.first.icon, 'Wallet');
      expect(terms.highlights.first.title, '100% Tips Pass-Through');
      expect(terms.sections.length, 1);
      expect(terms.sections.first.id, 'eligibility');
      expect(terms.sections.first.number, '1');
      expect(terms.sections.first.bullets.length, 2);

      // Verify privacy document
      final privacy = model.privacy!;
      expect(privacy.id, 'rider-privacy-policy');
      expect(privacy.slug, 'rider-privacy');
      expect(privacy.highlights.length, 1);
      expect(privacy.highlights.first.icon, 'MapPin');
      expect(privacy.sections.length, 1);
      expect(privacy.sections.first.id, 'background-location');
      expect(privacy.sections.first.bullets.length, 3);
    });

    test('should convert to and from JSON correctly', () {
      final model = LegalTermsAndPrivacyModel.fromJson(sampleJson);
      final jsonOutput = model.toJson();

      expect(jsonOutput['documentType'], 'all');
      expect(jsonOutput['data'], isA<Map<String, dynamic>>());

      final roundTrip = LegalTermsAndPrivacyModel.fromJson(jsonOutput);
      expect(roundTrip.documentType, model.documentType);
      expect(roundTrip.terms?.title, model.terms?.title);
      expect(roundTrip.privacy?.title, model.privacy?.title);
      expect(roundTrip.terms?.highlights.first.title, model.terms?.highlights.first.title);
    });

    test('should handle single terms document payload (type=terms)', () {
      final singleTermsJson = {
        'success': true,
        'documentType': 'terms',
        'data': {
          'id': 'rider-terms-and-conditions',
          'slug': 'rider-terms',
          'title': 'Rider Terms',
          'version': '1.0',
          'lastUpdated': 'September 2026',
          'sections': [],
        }
      };

      final model = LegalTermsAndPrivacyModel.fromJson(singleTermsJson);
      expect(model.documentType, 'terms');
      expect(model.terms, isNotNull);
      expect(model.terms?.title, 'Rider Terms');
      expect(model.privacy, isNull);
    });

    test('should safely handle missing or null fields', () {
      final incompleteJson = {
        'documentType': 'all',
        'data': {
          'terms': {
            'id': 'terms_1',
            'title': null,
            'sections': null,
          }
        }
      };

      final model = LegalTermsAndPrivacyModel.fromJson(incompleteJson);
      expect(model.terms, isNotNull);
      expect(model.terms!.title, '');
      expect(model.terms!.version, '1.0');
      expect(model.terms!.highlights, isEmpty);
      expect(model.terms!.sections, isEmpty);
    });
  });
}
