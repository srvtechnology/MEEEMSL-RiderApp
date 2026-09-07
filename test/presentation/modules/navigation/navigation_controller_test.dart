import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/core/utils/formatters.dart';
import 'package:meeem_rider/presentation/modules/navigation/controllers/navigation_controller.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersController extends GetxController with Mock implements OrdersController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Formatters formatDistance Tests', () {
    test('formatDistance returns meters without literal dollar escaping for km < 1.0', () {
      expect(Formatters.formatDistance(0.25), '250 m');
      expect(Formatters.formatDistance(0.05), '50 m');
    });

    test('formatDistance returns kilometers without literal dollar escaping for km >= 1.0', () {
      expect(Formatters.formatDistance(2.4), '2.4 km');
      expect(Formatters.formatDistance(10.0), '10.0 km');
    });
  });

  group('NavigationController Google Maps Tests', () {
    late NavigationController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(NavigationController());
    });

    tearDown(() {
      Get.reset();
    });

    test('initializes with default coordinates, markers and polylines', () {
      expect(controller.initialCameraPosition.target.latitude, isNotNull);
      expect(controller.initialCameraPosition.target.longitude, isNotNull);
      expect(controller.markers.length, equals(2));
      expect(controller.polylines.length, equals(1));
      expect(controller.remainingDistance.value, greaterThan(0));
      expect(controller.remainingMinutes.value, greaterThan(0));
    });

    test('recenterRider enables following mode and targets rider', () {
      controller.isFollowingRider.value = false;
      controller.recenterRider();
      expect(controller.isFollowingRider.value, isTrue);
    });

    test('onCameraMoveStarted disables following mode', () {
      controller.isFollowingRider.value = true;
      controller.onCameraMoveStarted();
      expect(controller.isFollowingRider.value, isFalse);
    });
  });
}
