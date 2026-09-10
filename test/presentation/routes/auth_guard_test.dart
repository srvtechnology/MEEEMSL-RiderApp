import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meeem_rider/core/constants/app_constants.dart';
import 'package:meeem_rider/presentation/routes/app_routes.dart';
import 'package:meeem_rider/presentation/routes/auth_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthGuard guard;
  late GetStorage storage;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
  });

  setUp(() async {
    guard = AuthGuard();
    storage = GetStorage();
    await storage.erase();
  });

  tearDown(() async {
    await storage.erase();
  });

  test('AuthGuard redirects to AppRoutes.login when token is missing', () {
    final route = guard.redirect('/main');
    expect(route, isNotNull);
    expect(route?.name, AppRoutes.login);
  });

  test('AuthGuard redirects to AppRoutes.pendingApproval when rider isApproved is false', () async {
    await storage.write(AppConstants.tokenKey, 'mock_valid_token');
    final riderData = {
      'id': 'rider_1',
      'name': 'Test Rider',
      'email': 'rider@test.com',
      'phone': '123456',
      'isApproved': false,
      'status': 'PENDING',
      'onboardingCompleted': true,
      'isFirstLogin': false,
    };
    await storage.write(AppConstants.riderProfileKey, jsonEncode(riderData));

    final route = guard.redirect('/main');
    expect(route, isNotNull);
    expect(route?.name, AppRoutes.pendingApproval);
  });

  test('AuthGuard allows navigation (returns null) when rider isApproved is true', () async {
    await storage.write(AppConstants.tokenKey, 'mock_valid_token');
    final riderData = {
      'id': 'rider_1',
      'name': 'Test Rider',
      'email': 'rider@test.com',
      'phone': '123456',
      'isApproved': true,
      'status': 'APPROVED',
      'onboardingCompleted': true,
      'isFirstLogin': false,
    };
    await storage.write(AppConstants.riderProfileKey, jsonEncode(riderData));

    final route = guard.redirect('/main');
    expect(route, isNull);
  });
}
