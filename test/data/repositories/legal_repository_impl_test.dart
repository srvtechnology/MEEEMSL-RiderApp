import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/error/exceptions.dart';
import 'package:meeem_rider/core/error/failures.dart';
import 'package:meeem_rider/data/datasources/legal_remote_datasource.dart';
import 'package:meeem_rider/data/models/legal_document_model.dart';
import 'package:meeem_rider/data/repositories/legal_repository_impl.dart';

class MockLegalRemoteDataSource extends Mock implements LegalRemoteDataSource {}

void main() {
  late MockLegalRemoteDataSource mockDataSource;
  late LegalRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockLegalRemoteDataSource();
    repository = LegalRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('LegalRepositoryImpl Tests', () {
    const tModel = LegalTermsAndPrivacyModel(
      documentType: 'all',
      terms: LegalDocumentModel(
        id: 'terms-1',
        slug: 'rider-terms',
        title: 'Terms',
        version: '1.0',
        lastUpdated: 'Sept 2026',
      ),
    );

    test('should return Right(data) when remote datasource succeeds', () async {
      when(() => mockDataSource.getLegalDocuments(type: any(named: 'type')))
          .thenAnswer((_) async => tModel);

      final result = await repository.getLegalDocuments(type: 'all');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got $failure'),
        (data) {
          expect(data.documentType, 'all');
          expect(data.terms?.title, 'Terms');
        },
      );
      verify(() => mockDataSource.getLegalDocuments(type: 'all')).called(1);
    });

    test('should return Left(ServerFailure) when remote datasource throws ServerException', () async {
      when(() => mockDataSource.getLegalDocuments(type: any(named: 'type')))
          .thenThrow(const ServerException(message: 'Server Error 500', statusCode: 500));

      final result = await repository.getLegalDocuments(type: 'all');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Server Error 500');
          expect(failure.statusCode, 500);
        },
        (_) => fail('Expected left, got right'),
      );
    });
  });
}
