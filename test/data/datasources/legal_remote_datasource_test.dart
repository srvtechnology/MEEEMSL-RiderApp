import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/data/datasources/legal_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioClient dioClient;
  late LegalRemoteDataSourceImpl dataSource;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('legal_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    await GetStorage.init();
  });

  setUp(() {
    dioClient = DioClient();
    dioClient.dio.interceptors.clear();
    dioClient.dio.interceptors.add(MockInterceptor());
    dataSource = LegalRemoteDataSourceImpl(dioClient);
  });

  group('LegalRemoteDataSource Tests', () {
    test('ApiEndpoints.isDocumentedEndpoint accepts /terms', () {
      expect(ApiEndpoints.isDocumentedEndpoint(ApiEndpoints.terms), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint('/terms'), isTrue);
      expect(ApiEndpoints.isDocumentedEndpoint('/mobileapi/rider/terms'), isTrue);
    });

    test('getLegalDocuments fetches both terms and privacy when type=all', () async {
      final result = await dataSource.getLegalDocuments(type: 'all');

      expect(result.documentType, equals('all'));
      expect(result.terms, isNotNull);
      expect(result.privacy, isNotNull);

      expect(result.terms!.title, contains('Terms and Conditions'));
      expect(result.terms!.highlights, isNotEmpty);
      expect(result.terms!.sections, isNotEmpty);

      expect(result.privacy!.title, contains('Privacy Policy'));
      expect(result.privacy!.highlights, isNotEmpty);
      expect(result.privacy!.sections, isNotEmpty);
    });

    test('getLegalDocuments fetches only terms when type=terms', () async {
      final result = await dataSource.getLegalDocuments(type: 'terms');

      expect(result.documentType, equals('terms'));
      expect(result.terms, isNotNull);
      expect(result.privacy, isNull);
    });

    test('getLegalDocuments fetches only privacy when type=privacy', () async {
      final result = await dataSource.getLegalDocuments(type: 'privacy');

      expect(result.documentType, equals('privacy'));
      expect(result.privacy, isNotNull);
      expect(result.terms, isNull);
    });
  });
}
