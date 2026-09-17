import '../../domain/entities/legal_document_entity.dart';

class LegalHighlightModel extends LegalHighlightEntity {
  const LegalHighlightModel({
    required super.icon,
    required super.title,
    required super.description,
  });

  factory LegalHighlightModel.fromJson(Map<String, dynamic> json) {
    return LegalHighlightModel(
      icon: json['icon']?.toString() ?? 'Info',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
    };
  }
}

class LegalSectionModel extends LegalSectionEntity {
  const LegalSectionModel({
    required super.id,
    required super.number,
    required super.title,
    required super.summary,
    required super.content,
    super.bullets = const [],
  });

  factory LegalSectionModel.fromJson(Map<String, dynamic> json) {
    final rawBullets = json['bullets'];
    List<String> bulletsList = [];
    if (rawBullets is List) {
      bulletsList = rawBullets.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }

    return LegalSectionModel(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      bullets: bulletsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'summary': summary,
      'content': content,
      'bullets': bullets,
    };
  }
}

class LegalDocumentModel extends LegalDocumentEntity {
  const LegalDocumentModel({
    required super.id,
    required super.slug,
    required super.title,
    required super.version,
    required super.lastUpdated,
    super.summary = '',
    super.highlights = const [],
    super.sections = const [],
    super.content = '',
    super.rawText = '',
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    final rawHighlights = json['highlights'];
    List<LegalHighlightModel> highlightsList = [];
    if (rawHighlights is List) {
      for (final item in rawHighlights) {
        if (item is Map<String, dynamic>) {
          highlightsList.add(LegalHighlightModel.fromJson(item));
        }
      }
    }

    final rawSections = json['sections'];
    List<LegalSectionModel> sectionsList = [];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          sectionsList.add(LegalSectionModel.fromJson(item));
        }
      }
    }

    return LegalDocumentModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      version: json['version']?.toString() ?? '1.0',
      lastUpdated: json['lastUpdated']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      highlights: highlightsList,
      sections: sectionsList,
      content: json['content']?.toString() ?? '',
      rawText: json['rawText']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'version': version,
      'lastUpdated': lastUpdated,
      'summary': summary,
      'highlights': highlights.map((h) {
        if (h is LegalHighlightModel) return h.toJson();
        return {'icon': h.icon, 'title': h.title, 'description': h.description};
      }).toList(),
      'sections': sections.map((s) {
        if (s is LegalSectionModel) return s.toJson();
        return {
          'id': s.id,
          'number': s.number,
          'title': s.title,
          'summary': s.summary,
          'content': s.content,
          'bullets': s.bullets,
        };
      }).toList(),
      'content': content,
      'rawText': rawText,
    };
  }
}

class LegalTermsAndPrivacyModel extends LegalTermsAndPrivacyEntity {
  const LegalTermsAndPrivacyModel({
    required super.documentType,
    super.terms,
    super.privacy,
  });

  factory LegalTermsAndPrivacyModel.fromJson(Map<String, dynamic> json) {
    final docType = json['documentType']?.toString() ?? 'all';
    final data = json['data'];

    LegalDocumentModel? terms;
    LegalDocumentModel? privacy;

    if (data is Map<String, dynamic>) {
      if (data['terms'] is Map<String, dynamic>) {
        terms = LegalDocumentModel.fromJson(data['terms'] as Map<String, dynamic>);
      }
      if (data['privacy'] is Map<String, dynamic>) {
        privacy = LegalDocumentModel.fromJson(data['privacy'] as Map<String, dynamic>);
      }

      // Handle single-document payload responses
      if (terms == null && (docType == 'terms' || data['slug'] == 'rider-terms' || data['id'] == 'rider-terms-and-conditions')) {
        terms = LegalDocumentModel.fromJson(data);
      }
      if (privacy == null && (docType == 'privacy' || data['slug'] == 'rider-privacy' || data['id'] == 'rider-privacy-policy')) {
        privacy = LegalDocumentModel.fromJson(data);
      }
    }

    return LegalTermsAndPrivacyModel(
      documentType: docType,
      terms: terms,
      privacy: privacy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'data': {
        if (terms != null) 'terms': (terms as LegalDocumentModel).toJson(),
        if (privacy != null) 'privacy': (privacy as LegalDocumentModel).toJson(),
      },
    };
  }
}
