import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/legal_document_entity.dart';
import '../../repositories/legal_repository.dart';

class GetLegalDocumentsUseCase {
  final LegalRepository _repository;

  GetLegalDocumentsUseCase(this._repository);

  Future<Either<Failure, LegalTermsAndPrivacyEntity>> call({String type = 'all'}) {
    return _repository.getLegalDocuments(type: type);
  }
}
