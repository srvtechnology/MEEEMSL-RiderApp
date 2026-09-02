import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/earnings_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(String period);
  Future<bool> requestPayout(double amount, String paymentMethod);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final DioClient _dioClient;

  EarningsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<EarningsModel> getEarnings(String period) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.earningsBreakdown,
        queryParameters: {'period': period},
      );
      if (response.statusCode == 200 && response.data != null) {
        return EarningsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to load earnings');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load earnings',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> requestPayout(double amount, String paymentMethod) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.requestPayout,
        data: {'amount': amount, 'paymentMethod': paymentMethod},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to process payout',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
