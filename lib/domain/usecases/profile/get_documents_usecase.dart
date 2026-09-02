import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/document_entity.dart';
import '../../repositories/profile_repository.dart';

class GetDocumentsUseCase {
  final ProfileRepository repository;
  GetDocumentsUseCase(this.repository);

  Future<Either<Failure, List<DocumentEntity>>> call() {
    return repository.getDocuments();
  }
}
