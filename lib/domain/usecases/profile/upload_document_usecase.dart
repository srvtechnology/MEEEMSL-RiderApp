import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/document_entity.dart';
import '../../repositories/profile_repository.dart';

class UploadDocumentUseCase {
  final ProfileRepository repository;
  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call(String docType, String filePath) {
    return repository.uploadDocument(docType, filePath);
  }
}
