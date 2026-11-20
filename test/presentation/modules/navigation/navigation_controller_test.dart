import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/core/utils/formatters.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/presentation/modules/navigation/controllers/navigation_controller.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersController extends GetxController with Mock implements OrdersController {
  @override
  final selectedOrder = Rxn<OrderEntity>();
}

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
      Get.put<OrdersController>(MockOrdersController());
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

    test('toggleCameraMode toggles 3d navigation perspective', () {
      expect(controller.is3dNavigationMode.value, isTrue);
      controller.toggleCameraMode();
      expect(controller.is3dNavigationMode.value, isFalse);
      controller.toggleCameraMode();
      expect(controller.is3dNavigationMode.value, isTrue);
    });

    test('toggleTraffic toggles real-time traffic overlay', () {
      expect(controller.isTrafficEnabled.value, isTrue);
      controller.toggleTraffic();
      expect(controller.isTrafficEnabled.value, isFalse);
    });

    test('toggleMute toggles voice instruction state', () {
      expect(controller.isMuted.value, isFalse);
      controller.toggleMute();
      expect(controller.isMuted.value, isTrue);
    });

    test('resolves Patiram address coordinates dynamically', () {
      final order = OrderEntity(
        id: 'test_patiram',
        orderNumber: 'meeem00000101',
        status: OrderStatus.pickedUp,
        customerName: 'rupesh',
        customerPhone: '+919876543210',
        customerAvatar: '',
        pickupName: 'Store',
        pickupAddress: 'Market, Patiram',
        pickupPhone: '+919876543210',
        dropoffAddress: 'PC24+3JH, Patiram',
        pickupLat: 0.0,
        pickupLng: 0.0,
        dropoffLat: 0.0,
        dropoffLng: 0.0,
        items: const [],
        subtotal: 100.0,
        riderEarnings: 50.0,
        distanceKm: 2.3,
        estimatedDurationMin: 10,
        createdAt: DateTime.now(),
      );
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().selectedOrder.value = order;
      }
      expect(controller.targetLat, closeTo(25.3340, 0.01));
      expect(controller.targetLng, closeTo(88.7600, 0.01));
    });

    test('switches polyline target from warehouse pickup to customer dropoff after pickup', () {
      final orderAccepted = OrderEntity(
        id: 'order_flow_1',
        orderNumber: 'meeem00000101',
        status: OrderStatus.accepted,
        customerName: 'Customer Rupesh',
        customerPhone: '+919876543210',
        customerAvatar: '',
        pickupName: 'Central Warehouse',
        pickupAddress: 'Warehouse Area, Patiram',
        pickupPhone: '+919876543210',
        dropoffAddress: 'PC24+3JH, Patiram',
        pickupLat: 25.3350,
        pickupLng: 88.7610,
        dropoffLat: 25.3400,
        dropoffLng: 88.7650,
        items: const [],
        subtotal: 100.0,
        riderEarnings: 50.0,
        distanceKm: 2.3,
        estimatedDurationMin: 10,
        createdAt: DateTime.now(),
      );

      // 1. Order Accepted: Heading to Warehouse
      Get.find<OrdersController>().selectedOrder.value = orderAccepted;
      controller.updateMapRoute();

      expect(controller.isHeadingToPickup, isTrue);
      expect(controller.targetTitle, equals('Central Warehouse'));
      expect(controller.destinationLatLng.latitude, closeTo(25.3350, 0.001));
      expect(controller.polylines.length, equals(1));
      expect(controller.polylines.first.points.last.latitude, closeTo(25.3350, 0.001));

      // 2. Order Picked Up: Heading to Customer
      final orderPickedUp = orderAccepted.copyWith(status: OrderStatus.pickedUp);
      Get.find<OrdersController>().selectedOrder.value = orderPickedUp;
      controller.updateMapRoute();

      expect(controller.isHeadingToPickup, isFalse);
      expect(controller.targetTitle, equals('Customer Rupesh'));
      expect(controller.destinationLatLng.latitude, closeTo(25.3400, 0.001));
      expect(controller.polylines.length, equals(1));
      expect(controller.polylines.first.points.last.latitude, closeTo(25.3400, 0.001));
    });

    test('strictly uses backend coordinates for store pickup regardless of distance', () {
      final orderWithBackendCoords = OrderEntity(
        id: 'order_backend_exact',
        orderNumber: 'meeem00000103',
        status: OrderStatus.accepted,
        customerName: 'John Doe',
        customerPhone: '+23276123456',
        customerAvatar: '',
        pickupName: 'Apex Electronics',
        pickupAddress: '124 Siaka Stevens Street, Freetown',
        pickupPhone: '+23277987654',
        dropoffAddress: '14 Lumley Beach Road, Freetown',
        pickupLat: 8.4842,
        pickupLng: -13.2341,
        dropoffLat: 8.4600,
        dropoffLng: -13.2500,
        items: const [],
        subtotal: 100.0,
        riderEarnings: 50.0,
        distanceKm: 2.3,
        estimatedDurationMin: 10,
        createdAt: DateTime.now(),
      );

      Get.find<OrdersController>().selectedOrder.value = orderWithBackendCoords;
      controller.updateMapRoute();

      expect(controller.isHeadingToPickup, isTrue);
      expect(controller.targetLat, closeTo(8.4842, 0.0001));
      expect(controller.targetLng, closeTo(-13.2341, 0.0001));
      expect(controller.destinationLatLng.latitude, closeTo(8.4842, 0.0001));
      expect(controller.destinationLatLng.longitude, closeTo(-13.2341, 0.0001));
    });

    test('geocodes Sierra Leone Siaka Stevens Street address when backend coords are null', () {
      final orderWithAddressOnly = OrderEntity(
        id: 'order_sl_address',
        orderNumber: 'meeem00000103',
        status: OrderStatus.accepted,
        customerName: 'John Doe',
        customerPhone: '+23276123456',
        customerAvatar: '',
        pickupName: 'Apex Electronics',
        pickupAddress: '124 Siaka Stevens Street, Freetown',
        pickupPhone: '+23277987654',
        dropoffAddress: '14 Lumley Beach Road, Freetown',
        pickupLat: 0.0,
        pickupLng: 0.0,
        dropoffLat: 0.0,
        dropoffLng: 0.0,
        items: const [],
        subtotal: 100.0,
        riderEarnings: 50.0,
        distanceKm: 2.3,
        estimatedDurationMin: 10,
        createdAt: DateTime.now(),
      );

      Get.find<OrdersController>().selectedOrder.value = orderWithAddressOnly;
      controller.updateMapRoute();

      expect(controller.isHeadingToPickup, isTrue);
      expect(controller.targetLat, closeTo(8.4842, 0.0001));
      expect(controller.targetLng, closeTo(-13.2341, 0.0001));
    });
  });
}
