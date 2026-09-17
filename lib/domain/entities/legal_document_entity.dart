import 'package:equatable/equatable.dart';

/// Represents a prominent highlight item inside a legal document
class LegalHighlightEntity extends Equatable {
  final String icon;
  final String title;
  final String description;

  const LegalHighlightEntity({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [icon, title, description];
}

/// Represents an individual numbered clause or section of a legal document
class LegalSectionEntity extends Equatable {
  final String id;
  final String number;
  final String title;
  final String summary;
  final String content;
  final List<String> bullets;

  const LegalSectionEntity({
    required this.id,
    required this.number,
    required this.title,
    required this.summary,
    required this.content,
    this.bullets = const [],
  });

  @override
  List<Object?> get props => [id, number, title, summary, content, bullets];
}

/// Represents an entire legal document (Terms & Conditions or Privacy Policy)
class LegalDocumentEntity extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String version;
  final String lastUpdated;
  final String summary;
  final List<LegalHighlightEntity> highlights;
  final List<LegalSectionEntity> sections;
  final String content;
  final String rawText;

  const LegalDocumentEntity({
    required this.id,
    required this.slug,
    required this.title,
    required this.version,
    required this.lastUpdated,
    this.summary = '',
    this.highlights = const [],
    this.sections = const [],
    this.content = '',
    this.rawText = '',
  });

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        version,
        lastUpdated,
        summary,
        highlights,
        sections,
        content,
        rawText,
      ];
}

/// Represents the combined legal documents response containing terms and/or privacy policy
class LegalTermsAndPrivacyEntity extends Equatable {
  final String documentType;
  final LegalDocumentEntity? terms;
  final LegalDocumentEntity? privacy;

  const LegalTermsAndPrivacyEntity({
    required this.documentType,
    this.terms,
    this.privacy,
  });

  @override
  List<Object?> get props => [documentType, terms, privacy];
}
