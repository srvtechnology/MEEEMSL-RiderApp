import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/legal_document_entity.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/legal_remote_datasource.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalRemoteDataSource remoteDataSource;

  LegalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LegalTermsAndPrivacyEntity>> getLegalDocuments({String type = 'all'}) async {
    try {
      final result = await remoteDataSource.getLegalDocuments(type: type);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
