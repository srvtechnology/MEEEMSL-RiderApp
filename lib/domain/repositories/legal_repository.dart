import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/legal_document_entity.dart';

abstract class LegalRepository {
  /// Fetches legal documents (Terms & Conditions and/or Privacy Policy).
  /// [type] can be 'all', 'terms', or 'privacy'.
  Future<Either<Failure, LegalTermsAndPrivacyEntity>> getLegalDocuments({String type = 'all'});
}
