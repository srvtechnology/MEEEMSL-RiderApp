import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';

abstract class DashboardRemoteDataSource {
  Future<bool> toggleOnline(bool isOnline);
  Future<Map<String, dynamic>> getSummary();
  Future<void> updateLocation(double lat, double lng);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _dioClient;
  final GetStorage _storage = GetStorage();

  DashboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> toggleOnline(bool isOnline) async {
    // Note: Online toggle API is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // Store online status locally without making network calls to server.
    await _storage.write(AppConstants.isOnlineKey, isOnline);
    return isOnline;
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    // Note: Dashboard summary API is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // Return local dashboard summary without making network calls to server.
    final isOnline = _storage.read<bool>(AppConstants.isOnlineKey) ?? true;
    return {
      'todayEarnings': 148.50,
      'todayDeliveries': 9,
      'acceptanceRate': 96.5,
      'rating': 4.92,
      'onlineHours': 5.8,
      'weeklyEarnings': 892.20,
      'isOnline': isOnline,
      'hasActiveOrder': true,
    };
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    // Part 2: 1.2 Fallback Background Telemetry (REST API)
    final isOnline = _storage.read<bool>(AppConstants.isOnlineKey) ?? true;
    try {
      await _dioClient.dio.post(
        ApiEndpoints.location,
        data: {
          'latitude': lat,
          'longitude': lng,
          'heading': 0.0,
          'speed': 0.0,
          'isOnline': isOnline,
        },
      );
    } catch (_) {
      // Ignored for telemetry resiliency
    }
  }
}
