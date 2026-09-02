import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';
import 'mock_interceptor.dart';

/// DioClient configures and exposes the central Dio HTTP client.
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // If mock mode is enabled, intercept with realistic simulated backend
    if (AppConstants.useMockApi) {
      dio.interceptors.add(MockInterceptor());
    } else {
      dio.interceptors.add(ApiInterceptor(dio));
    }

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
}
