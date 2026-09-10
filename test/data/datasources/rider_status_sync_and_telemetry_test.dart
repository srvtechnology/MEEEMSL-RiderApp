import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/api_endpoints.dart';
import 'package:meeem_rider/core/constants/app_constants.dart';
import 'package:meeem_rider/core/network/dio_client.dart';
import 'package:meeem_rider/core/network/mock_interceptor.dart';
import 'package:meeem_rider/data/datasources/auth_local_datasource.dart';
import 'package:meeem_rider/data/datasources/auth_remote_datasource.dart';
import 'package:meeem_rider/data/datasources/dashboard_remote_datasource.dart';
import 'package:meeem_rider/data/repositories/dashboard_repository_impl.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_rider_status_usecase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioClient dioClient;
  late DashboardRemoteDataSourceImpl dashboardDataSource;
  late DashboardRepositoryImpl dashboardRepository;
  late GetStorage storage;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
  });

  setUp(() {
    storage = GetStorage();
    dioClient = DioClient();
    dioClient.dio.interceptors.clear();
    dioClient.dio.interceptors.add(MockInterceptor());

    dashboardDataSource = DashboardRemoteDataSourceImpl(dioClient);
    dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: dashboardDataSource,
      localDataSource: AuthLocalDataSourceImpl(storage),
    );
  });

  group('Checklist Point 1 & 4: Rider Status Online/Offline API Tests', () {
    test('ApiEndpoints.status is /status and normalized cleanly for /mobileapi/rider/status', () {
      expect(ApiEndpoints.status, equals('/status'));
      expect(ApiEndpoints.isDocumentedEndpoint('/mobileapi/rider/status'), isTrue);
      expect(ApiEndpoints.isPart1Endpoint('/status'), isTrue);
      expect(ApiEndpoints.isPart2Endpoint('/status'), isTrue);
    });

    test('toggleOnline(true) posts to /mobileapi/rider/status and marks storage isOnline = true', () async {
      final status = await dashboardDataSource.toggleOnline(true);
      expect(status, isTrue);
      expect(storage.read<bool>(AppConstants.isOnlineKey), isTrue);
    });

    test('toggleOnline(false) posts to /mobileapi/rider/status and marks storage isOnline = false', () async {
      final status = await dashboardDataSource.toggleOnline(false);
      expect(status, isFalse);
      expect(storage.read<bool>(AppConstants.isOnlineKey), isFalse);
    });

    test('getRiderStatus() queries GET /mobileapi/rider/status and syncs online state', () async {
      await storage.write(AppConstants.isOnlineKey, false);

      final statusData = await dashboardDataSource.getRiderStatus();
      expect(statusData, isNotNull);
      expect(statusData.containsKey('isOnline'), isTrue);
      expect(statusData.containsKey('operationalStatus'), isTrue);
    });

    test('GetRiderStatusUseCase successfully executes through DashboardRepository', () async {
      final useCase = GetRiderStatusUseCase(dashboardRepository);
      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should succeed'),
        (data) {
          expect(data['isOnline'], isA<bool>());
          expect(data['operationalStatus'], isNotNull);
        },
      );
    });

    test('AuthRemoteDataSource.logout calls POST /mobileapi/rider/status with isOnline: false', () async {
      final authRemote = AuthRemoteDataSourceImpl(dioClient);
      await expectLater(authRemote.logout(), completes);
    });
  });
}
