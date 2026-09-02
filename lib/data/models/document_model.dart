import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.type,
    required super.title,
    required super.documentNumber,
    required super.expiryDate,
    required super.status,
    super.fileUrl,
  });

  static DocumentStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'verified':
        return DocumentStatus.verified;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? 'Document',
      documentNumber: json['documentNumber'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'documentNumber': documentNumber,
      'expiryDate': expiryDate,
      'status': status.name,
      'fileUrl': fileUrl,
    };
  }
}
