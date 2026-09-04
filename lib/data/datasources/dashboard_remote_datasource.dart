import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';

abstract class DashboardRemoteDataSource {
  Future<bool> toggleOnline(bool isOnline);
  Future<Map<String, dynamic>> getSummary();
  Future<void> updateLocation(double lat, double lng);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  // ignore: unused_field
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
    // Note: Location update API is not in MOBILE_RIDER_APP_API_DOC_PART_1.md.
    // No-op locally.
  }
}
