import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

/// DeviceInfoService manages device hardware identification,
/// OS platform reporting, device model, and user agent strings
/// required for session authentication and push token registration.
class DeviceInfoService {
  final GetStorage _storage;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  String? _cachedDeviceId;
  String? _cachedDeviceModel;
  String? _cachedPlatform;
  String? _cachedUserAgent;

  DeviceInfoService(this._storage);

  /// Returns a persistent unique device hardware ID (UUID / hardware ID).
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    // Check local storage first
    String? storedId = _storage.read<String>(AppConstants.registeredDeviceIdKey);
    if (storedId != null && storedId.isNotEmpty) {
      _cachedDeviceId = storedId;
      return storedId;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        storedId = androidInfo.id.isNotEmpty ? androidInfo.id : const Uuid().v4();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        storedId = iosInfo.identifierForVendor ?? const Uuid().v4();
      } else {
        storedId = const Uuid().v4();
      }
    } catch (_) {
      storedId = const Uuid().v4();
    }

    _cachedDeviceId = storedId;
    await _storage.write(AppConstants.registeredDeviceIdKey, storedId);
    return storedId;
  }

  /// Platform identifier ("android" | "ios" | "web").
  String getPlatform() {
    if (_cachedPlatform != null) return _cachedPlatform!;
    if (Platform.isAndroid) {
      _cachedPlatform = 'android';
    } else if (Platform.isIOS) {
      _cachedPlatform = 'ios';
    } else {
      _cachedPlatform = 'android';
    }
    return _cachedPlatform!;
  }

  /// Device hardware model string (e.g., "Samsung Galaxy S22" or "iPhone 15 Pro").
  Future<String> getDeviceModel() async {
    if (_cachedDeviceModel != null) return _cachedDeviceModel!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final brand = androidInfo.brand;
        final model = androidInfo.model;
        _cachedDeviceModel = '${brand[0].toUpperCase()}${brand.substring(1)} $model';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        _cachedDeviceModel = iosInfo.utsname.machine;
      } else {
        _cachedDeviceModel = 'Generic Device';
      }
    } catch (_) {
      _cachedDeviceModel = 'Generic Device';
    }

    return _cachedDeviceModel!;
  }

  /// User-Agent string (e.g., "MEEEM-Rider-Android/1.0.0 (Samsung Galaxy S22)").
  Future<String> getUserAgent() async {
    if (_cachedUserAgent != null) return _cachedUserAgent!;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final model = await getDeviceModel();
      final os = Platform.isAndroid ? 'Android' : 'iOS';
      _cachedUserAgent = 'MEEEM-Rider-$os/$version ($model)';
    } catch (_) {
      final os = Platform.isAndroid ? 'Android' : 'iOS';
      _cachedUserAgent = 'MEEEM-Rider-$os/1.0.0';
    }

    return _cachedUserAgent!;
  }
}
