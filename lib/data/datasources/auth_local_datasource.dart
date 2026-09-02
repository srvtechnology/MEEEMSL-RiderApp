import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/rider_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveRefreshToken(String refreshToken);
  String? getRefreshToken();
  Future<void> saveRider(RiderModel rider);
  RiderModel? getSavedRider();
  Future<void> clearAuth();
  bool getIsOnline();
  Future<void> setIsOnline(bool isOnline);
  bool getIsDarkMode();
  Future<void> setIsDarkMode(bool isDark);
  Future<void> queueOfflineAction(Map<String, dynamic> action);
  List<Map<String, dynamic>> getOfflineQueue();
  Future<void> clearOfflineQueue();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(AppConstants.tokenKey, token);
  }

  @override
  String? getToken() {
    return _storage.read<String>(AppConstants.tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  @override
  String? getRefreshToken() {
    return _storage.read<String>(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveRider(RiderModel rider) async {
    await _storage.write(AppConstants.riderProfileKey, jsonEncode(rider.toJson()));
  }

  @override
  RiderModel? getSavedRider() {
    final raw = _storage.read<String>(AppConstants.riderProfileKey);
    if (raw == null) return null;
    try {
      return RiderModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    await _storage.remove(AppConstants.tokenKey);
    await _storage.remove(AppConstants.refreshTokenKey);
    await _storage.remove(AppConstants.riderProfileKey);
  }

  @override
  bool getIsOnline() {
    return _storage.read<bool>(AppConstants.isOnlineKey) ?? false;
  }

  @override
  Future<void> setIsOnline(bool isOnline) async {
    await _storage.write(AppConstants.isOnlineKey, isOnline);
  }

  @override
  bool getIsDarkMode() {
    return _storage.read<bool>(AppConstants.isDarkModeKey) ?? false;
  }

  @override
  Future<void> setIsDarkMode(bool isDark) async {
    await _storage.write(AppConstants.isDarkModeKey, isDark);
  }

  @override
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    final list = getOfflineQueue();
    list.add(action);
    await _storage.write(AppConstants.offlineQueueKey, jsonEncode(list));
  }

  @override
  List<Map<String, dynamic>> getOfflineQueue() {
    final raw = _storage.read<String>(AppConstants.offlineQueueKey);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> clearOfflineQueue() async {
    await _storage.remove(AppConstants.offlineQueueKey);
  }
}
