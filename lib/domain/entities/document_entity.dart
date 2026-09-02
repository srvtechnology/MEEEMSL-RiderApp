import 'package:equatable/equatable.dart';

enum DocumentStatus { verified, pending, rejected }

class DocumentEntity extends Equatable {
  final String type;
  final String title;
  final String documentNumber;
  final String expiryDate;
  final DocumentStatus status;
  final String? fileUrl;

  const DocumentEntity({
    required this.type,
    required this.title,
    required this.documentNumber,
    required this.expiryDate,
    required this.status,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [type, title, documentNumber, expiryDate, status, fileUrl];
}
