import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

/// ApiInterceptor attaches Bearer auth tokens to outgoing requests
/// and formats Dio errors cleanly.
class ApiInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read<String>(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Standardized error handling & logging
    return super.onError(err, handler);
  }
}
