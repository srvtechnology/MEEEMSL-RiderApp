import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/core/constants/app_constants.dart';
import 'package:meeem_rider/data/models/order_model.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_rider_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_order_details_usecase.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/presentation/modules/orders/controllers/orders_controller.dart';

class MockToggleOnlineStatusUseCase extends Mock implements ToggleOnlineStatusUseCase {}
class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}
class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockGetIncomingOrderUseCase extends Mock implements GetIncomingOrderUseCase {}
class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}
class MockDeclineOrderUseCase extends Mock implements DeclineOrderUseCase {}
class MockGetRiderStatusUseCase extends Mock implements GetRiderStatusUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockToggleOnlineStatusUseCase mockToggleOnline;
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockGetIncomingOrderUseCase mockGetIncomingOrder;
  late MockAcceptOrderUseCase mockAcceptOrder;
  late MockDeclineOrderUseCase mockDeclineOrder;
  late MockGetRiderStatusUseCase mockGetRiderStatus;
  late MockGetOrderDetailsUseCase mockGetOrderDetails;
  late GetStorage storage;

  final sampleOrderModel = OrderModel(
    id: 'ord_active_123',
    assignmentId: 'assign_active_123',
    orderNumber: 'meeem00000042',
    status: OrderStatus.atPickup,
    customerName: 'John Doe',
    customerPhone: '+232 76 000000',
    customerAvatar: '',
    pickupName: 'Central Grocery',
    pickupAddress: '15 Main St',
    pickupPhone: '+232 76 111111',
    dropoffAddress: '42 Beach Rd',
    pickupLat: 8.484,
    pickupLng: -13.234,
    dropoffLat: 8.460,
    dropoffLng: -13.250,
    items: const [],
    subtotal: 100.0,
    riderEarnings: 25.0,
    distanceKm: 3.5,
    estimatedDurationMin: 20,
    createdAt: DateTime.now(),
    deliveryOtp: '123456',
  );

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    await GetStorage.init();
    storage = GetStorage();
  });

  setUp(() {
    Get.reset();
    Get.put<GetStorage>(storage);
    storage.erase();

    mockToggleOnline = MockToggleOnlineStatusUseCase();
    mockGetSummary = MockGetDashboardSummaryUseCase();
    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockGetIncomingOrder = MockGetIncomingOrderUseCase();
    mockAcceptOrder = MockAcceptOrderUseCase();
    mockDeclineOrder = MockDeclineOrderUseCase();
    mockGetRiderStatus = MockGetRiderStatusUseCase();
    mockGetOrderDetails = MockGetOrderDetailsUseCase();

    when(() => mockGetSummary()).thenAnswer(
      (_) async => const Right({
        'todayEarnings': 100.0,
        'todayDeliveries': 2,
        'totalTrips': 10,
        'totalEarnings': 500.0,
        'completedDeliveriesCount': 10,
        'acceptanceRate': 95.0,
        'rating': 4.9,
        'onlineHours': 3.5,
      }),
    );

    when(() => mockGetRiderStatus()).thenAnswer(
      (_) async => const Right({
        'isOnline': true,
        'operationalStatus': 'AVAILABLE',
      }),
    );

    when(() => mockGetActiveOrders()).thenAnswer(
      (_) async => const Right(<OrderEntity>[]),
    );
  });

  tearDown(() {
    storage.erase();
    Get.reset();
  });

  test('DashboardController restores cached active order synchronously on onInit to prevent radar flash', () async {
    // Pre-populate GetStorage with an active order
    storage.write(AppConstants.activeOrderKey, sampleOrderModel.toJson());

    final controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getRiderStatusUseCase: mockGetRiderStatus,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
    );

    Get.put<DashboardController>(controller);

    // Active order should be restored on frame 0
    expect(controller.activeOrder.value, isNotNull);
    expect(controller.activeOrder.value?.id, equals('ord_active_123'));
    expect(controller.activeOrder.value?.status, equals(OrderStatus.atPickup));
  });

  test('DashboardController does NOT wipe active order when pull-to-refresh returns empty list', () async {
    storage.write(AppConstants.activeOrderKey, sampleOrderModel.toJson());

    final controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getRiderStatusUseCase: mockGetRiderStatus,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
    );
    Get.put<DashboardController>(controller);

    // Initial state restored
    expect(controller.activeOrder.value?.id, equals('ord_active_123'));

    // Trigger pull-to-refresh
    await controller.loadDashboardData();

    // Active order should NOT be wiped to null
    expect(controller.activeOrder.value, isNotNull);
    expect(controller.activeOrder.value?.id, equals('ord_active_123'));
    expect(controller.activeOrder.value?.status, equals(OrderStatus.atPickup));
  });

  test('DashboardController preserves monotonic progression if backend replica lags', () async {
    // Controller is at outForDelivery
    final advancedOrder = sampleOrderModel.copyWith(status: OrderStatus.outForDelivery);
    storage.write(AppConstants.activeOrderKey, OrderModel.fromEntity(advancedOrder).toJson());

    // Backend temporarily returns earlier status (accepted) due to read-replica lag
    final staleOrder = sampleOrderModel.copyWith(status: OrderStatus.accepted);
    when(() => mockGetActiveOrders()).thenAnswer((_) async => Right([staleOrder]));

    final controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getRiderStatusUseCase: mockGetRiderStatus,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
    );
    Get.put<DashboardController>(controller);

    await controller.loadDashboardData();

    // Status must remain outForDelivery, NOT regressed to accepted
    expect(controller.activeOrder.value?.status, equals(OrderStatus.outForDelivery));
  });

  test('DashboardController clears cache and activeOrder when order reaches DELIVERED', () async {
    storage.write(AppConstants.activeOrderKey, sampleOrderModel.toJson());

    final controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getRiderStatusUseCase: mockGetRiderStatus,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
    );
    Get.put<DashboardController>(controller);

    expect(controller.activeOrder.value, isNotNull);

    // Mark delivered
    controller.activeOrder.value = null;

    // Local storage key must be removed
    expect(storage.read(AppConstants.activeOrderKey), isNull);
  });
}
