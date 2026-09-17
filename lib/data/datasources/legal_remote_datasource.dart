import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/legal_document_model.dart';

abstract class LegalRemoteDataSource {
  Future<LegalTermsAndPrivacyModel> getLegalDocuments({String type = 'all'});
}

class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final DioClient _dioClient;

  LegalRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LegalTermsAndPrivacyModel> getLegalDocuments({String type = 'all'}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.terms,
        queryParameters: {
          'type': type,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> body;
        if (response.data is Map<String, dynamic>) {
          body = response.data as Map<String, dynamic>;
        } else {
          throw const ServerException(message: 'Invalid response format from legal endpoint');
        }
        return LegalTermsAndPrivacyModel.fromJson(body);
      } else {
        throw ServerException(
          message: response.data?['message']?.toString() ?? 'Failed to load legal terms & privacy policy',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Network error fetching legal terms';
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
