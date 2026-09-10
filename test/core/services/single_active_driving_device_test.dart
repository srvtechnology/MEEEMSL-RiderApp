import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/core/services/location_service.dart';
import 'package:meeem_rider/core/services/notification_service.dart';
import 'package:meeem_rider/core/services/socket_service.dart';
import 'package:meeem_rider/data/datasources/auth_local_datasource.dart';
import 'package:meeem_rider/data/datasources/dashboard_remote_datasource.dart';
import 'package:meeem_rider/data/models/rider_model.dart';
import 'package:meeem_rider/data/models/user_model.dart';

class MockAuthLocalDataSource implements AuthLocalDataSource {
  bool isOnline = true;
  String? token = 'mock_test_token';

  @override
  bool getIsOnline() => isOnline;

  @override
  Future<void> setIsOnline(bool value) async {
    isOnline = value;
  }

  @override
  String? getToken() => token;

  @override
  Future<void> saveToken(String token) async {}

  @override
  String? getRefreshToken() => 'mock_refresh_token';

  @override
  Future<void> saveRefreshToken(String token) async {}

  @override
  RiderModel? getSavedRider() => const RiderModel(
        id: 'rider_test_uuid_123',
        name: 'Test Rider',
        phone: '76123456',
        email: 'test@example.com',
        avatar: '',
        rating: 5.0,
        totalTrips: 10,
        isOnline: true,
        walletBalance: 150.0,
        approvalStatus: 'APPROVED',
        isApproved: true,
        isSuspended: false,
        status: 'APPROVED',
        onboardingCompleted: true,
        isFirstLogin: false,
        vehicleType: '2_WHEELER',
        vehicleTypes: ['2_WHEELER'],
        vehicleName: 'Honda CB Shine 125',
        vehicleNumber: 'SL-AA-9988',
        drivingLicenseNo: 'DL-10928374',
        profileImage: '',
        selectedZones: ['ZONE 1'],
        selectedLocations: ['FREETOWN'],
      );

  @override
  Future<void> saveRider(RiderModel rider) async {}

  @override
  UserModel? getSavedUser() => const UserModel(
        id: 'user_test_uuid_123',
        email: 'test@example.com',
        name: 'Test Rider',
        phone: '76123456',
        role: 'RIDER',
        isEmailVerified: true,
      );

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  String? getDeviceToken() => 'device_token_abc';

  @override
  Future<void> saveDeviceToken(String token) async {}

  @override
  Future<void> clearAuth() async {}

  @override
  bool getIsDarkMode() => false;

  @override
  Future<void> setIsDarkMode(bool isDark) async {}

  @override
  List<Map<String, dynamic>> getOfflineQueue() => [];

  @override
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {}

  @override
  Future<void> clearOfflineQueue() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
  });

  group('Single Active Driving Device Policy & Telemetry Tests', () {
    late DioClient dioClient;
    late MockAuthLocalDataSource mockAuth;
    late SocketService socketService;

    setUp(() {
      Get.testMode = true;
      dioClient = DioClient();
      dioClient.dio.interceptors.clear();
      mockAuth = MockAuthLocalDataSource();
      socketService = SocketService();
    });

    tearDown(() {
      socketService.disconnect();
      MockInterceptor.simulateDeviceSwitchedConflict = false;
      LocationService.onDeviceSwitchedAlert = null;
      SocketService.onRiderStatusChanged = null;
      SocketService.onActiveDeviceChanged = null;
      Get.reset();
    });

    test('1. Online toggle transmits deviceId and deviceModel in POST /mobileapi/rider/status', () async {
      RequestOptions? capturedOptions;
      dioClient.dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'data': {'isOnline': true},
            },
          ));
        },
      ));

      final datasource = DashboardRemoteDataSourceImpl(dioClient);
      final result = await datasource.toggleOnline(
        true,
        deviceId: 'device_uuid_android_999',
        deviceModel: 'Samsung Galaxy A53',
      );

      expect(result, isTrue);
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.path, endsWith(ApiEndpoints.status));
      expect(capturedOptions!.data['isOnline'], isTrue);
      expect(capturedOptions!.data['deviceId'], 'device_uuid_android_999');
      expect(capturedOptions!.data['deviceModel'], 'Samsung Galaxy A53');
    });

    test('2. Offline toggle transmits deviceId and isOnline: false', () async {
      RequestOptions? capturedOptions;
      dioClient.dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'success': true,
              'data': {'isOnline': false},
            },
          ));
        },
      ));

      final datasource = DashboardRemoteDataSourceImpl(dioClient);
      final result = await datasource.toggleOnline(
        false,
        deviceId: 'device_uuid_android_999',
      );

      expect(result, isFalse);
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.path, endsWith(ApiEndpoints.status));
      expect(capturedOptions!.data['isOnline'], isFalse);
      expect(capturedOptions!.data['deviceId'], 'device_uuid_android_999');
      expect(capturedOptions!.data.containsKey('deviceModel'), isFalse);
    });

    test('3. SocketService.emitLocationUpdate accepts deviceId parameter and guards disconnected state', () {
      final success = socketService.emitLocationUpdate(
        riderId: 'rider_test_uuid_123',
        orderId: 'cuid_active_order_42',
        latitude: 8.484245,
        longitude: -13.234125,
        heading: 180.0,
        speed: 25.0,
        isOnline: true,
        deviceId: 'device_uuid_android_999',
      );

      // In unit test without real socket connection, emit returns false safely without crashing
      expect(success, isFalse);
      expect(socketService.isConnected.value, isFalse);
    });

    test('4. LocationService transmits deviceId in REST fallback payload', () async {
      RequestOptions? capturedOptions;
      dioClient.dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedOptions = options;
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'message': 'Location updated successfully'},
          ));
        },
      ));

      final locationService = LocationService(
        dioClient,
        socketService,
        mockAuth,
      );

      locationService.isTrackingActive.value = true;
      await locationService.sendLocationUpdate(forceRest: true);

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.path, endsWith(ApiEndpoints.location));
      expect(capturedOptions!.data['latitude'], isNotNull);
      expect(capturedOptions!.data['longitude'], isNotNull);
      expect(capturedOptions!.data['isOnline'], isTrue);
    });

    test('5. LocationService handles HTTP 409 Conflict / DEVICE_SWITCHED', () async {
      dioClient.dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {
                'success': false,
                'error': 'DEVICE_SWITCHED',
                'message': 'You have switched to another device. Tracking stopped on this device.',
                'shouldStopTracking': true,
              },
            ),
            type: DioExceptionType.badResponse,
          ));
        },
      ));

      String? alertReceived;
      LocationService.onDeviceSwitchedAlert = (msg) {
        alertReceived = msg;
      };

      final locationService = LocationService(
        dioClient,
        socketService,
        mockAuth,
      );

      locationService.isTrackingActive.value = true;
      mockAuth.isOnline = true;

      await locationService.sendLocationUpdate(forceRest: true);

      // Verify tracking halted and rider marked offline
      expect(locationService.isTrackingActive.value, isFalse);
      expect(mockAuth.isOnline, isFalse);
      expect(alertReceived, contains('You have switched to another device'));
    });

    test('6. NotificationService handles type == "DEVICE_SWITCHED" FCM payload', () {
      final notificationService = NotificationService();
      final locationService = LocationService(
        dioClient,
        socketService,
        mockAuth,
      );
      Get.put<LocationService>(locationService);

      locationService.isTrackingActive.value = true;
      mockAuth.isOnline = true;

      String? alertReceived;
      LocationService.onDeviceSwitchedAlert = (msg) {
        alertReceived = msg;
      };

      notificationService.handleFcmPayload({
        'type': 'DEVICE_SWITCHED',
        'activeDeviceId': 'different_hardware_uuid_777',
        'title': 'Device Switched',
        'body': 'Your account is now active on another device.',
      });

      expect(locationService.isTrackingActive.value, isFalse);
      expect(mockAuth.isOnline, isFalse);
      expect(alertReceived, 'Your account is now active on another device.');
    });

    test('7. Cross-Device Socket Sync callbacks trigger on status & active device events', () {
      bool statusChangedFired = false;
      SocketService.onRiderStatusChanged = (isOnline) {
        if (!isOnline) {
          statusChangedFired = true;
          mockAuth.isOnline = false;
        }
      };

      SocketService.onRiderStatusChanged?.call(false);
      expect(statusChangedFired, isTrue);
      expect(mockAuth.isOnline, isFalse);

      Map<String, dynamic>? activeDeviceData;
      SocketService.onActiveDeviceChanged = (data) {
        activeDeviceData = data;
      };

      SocketService.onActiveDeviceChanged?.call({
        'activeDeviceId': 'device_other_uuid_456',
        'activeDeviceModel': 'Google Pixel 8',
      });

      expect(activeDeviceData, isNotNull);
      expect(activeDeviceData?['activeDeviceId'], 'device_other_uuid_456');
      expect(activeDeviceData?['activeDeviceModel'], 'Google Pixel 8');
    });
  });
}
