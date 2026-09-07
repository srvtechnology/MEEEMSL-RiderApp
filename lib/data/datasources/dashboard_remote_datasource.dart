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
    await _storage.write(AppConstants.isOnlineKey, isOnline);
    if (isOnline) {
      await _storage.write('online_since_timestamp', DateTime.now().toIso8601String());
    } else {
      await _storage.remove('online_since_timestamp');
    }
    return isOnline;
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    final isOnline = _storage.read<bool>(AppConstants.isOnlineKey) ?? true;
    double todayEarnings = 0.0;
    int todayDeliveries = 0;
    int totalDeliveries = 0;
    double weeklyEarnings = 0.0;
    bool hasActiveOrder = false;

    // 1. Check real active orders
    try {
      final activeRes = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'active'},
      );
      if (activeRes.statusCode == 200 && activeRes.data != null) {
        final activeList = activeRes.data['data'];
        if (activeList is List && activeList.isNotEmpty) {
          hasActiveOrder = true;
        }
      }
    } catch (_) {}

    // 2. Fetch real completed orders to calculate real earnings and trip counts
    try {
      final completedRes = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'completed'},
      );
      if (completedRes.statusCode == 200 && completedRes.data != null) {
        final data = completedRes.data['data'];
        if (data is List) {
          totalDeliveries = data.length;
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final weekStart = now.subtract(const Duration(days: 7));

          for (final item in data) {
            if (item is Map<String, dynamic>) {
              final earnings = (item['riderEarnings'] as num?)?.toDouble() ??
                  (item['order']?['deliveryFee'] as num?)?.toDouble() ??
                  0.0;
              final dateStr = item['deliveredAt'] ?? item['createdAt'] ?? item['updatedAt'];
              final date = dateStr != null ? DateTime.tryParse(dateStr.toString()) : null;

              if (date != null) {
                if (date.isAfter(todayStart)) {
                  todayEarnings += earnings;
                  todayDeliveries += 1;
                }
                if (date.isAfter(weekStart)) {
                  weeklyEarnings += earnings;
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    // 3. Compute real online hours from storage tracking
    double onlineHours = 0.0;
    if (isOnline) {
      final onlineSinceStr = _storage.read<String>('online_since_timestamp');
      if (onlineSinceStr != null) {
        final onlineSince = DateTime.tryParse(onlineSinceStr);
        if (onlineSince != null) {
          final diffHours = DateTime.now().difference(onlineSince).inMinutes / 60.0;
          onlineHours = double.parse(diffHours.toStringAsFixed(1));
        }
      } else {
        await _storage.write('online_since_timestamp', DateTime.now().toIso8601String());
      }
    }

    return {
      'todayEarnings': todayEarnings,
      'todayDeliveries': todayDeliveries,
      'totalTrips': totalDeliveries,
      'acceptanceRate': 100.0,
      'rating': 5.0,
      'onlineHours': onlineHours,
      'weeklyEarnings': weeklyEarnings,
      'isOnline': isOnline,
      'hasActiveOrder': hasActiveOrder,
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
