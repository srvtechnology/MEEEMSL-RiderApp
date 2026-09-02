import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';

abstract class DashboardRemoteDataSource {
  Future<bool> toggleOnline(bool isOnline);
  Future<Map<String, dynamic>> getSummary();
  Future<void> updateLocation(double lat, double lng);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _dioClient;

  DashboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> toggleOnline(bool isOnline) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.toggleOnline,
        data: {'isOnline': isOnline},
      );
      return response.data?['isOnline'] ?? isOnline;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to toggle status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.dashboardSummary);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to get summary',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.updateLocation,
        data: {'lat': lat, 'lng': lng, 'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (_) {}
  }
}
