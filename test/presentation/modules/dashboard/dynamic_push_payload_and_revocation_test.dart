import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:meeem_rider/domain/usecases/dashboard/get_dashboard_summary_usecase.dart';
import 'package:meeem_rider/domain/usecases/dashboard/toggle_online_status_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/accept_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/decline_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_active_orders_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/get_incoming_order_usecase.dart';
import 'package:meeem_rider/domain/usecases/orders/update_order_status_usecase.dart';
import 'package:meeem_rider/presentation/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:meeem_rider/presentation/modules/dashboard/widgets/incoming_offer_card.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';

class MockToggleOnlineStatusUseCase extends Mock implements ToggleOnlineStatusUseCase {}
class MockGetDashboardSummaryUseCase extends Mock implements GetDashboardSummaryUseCase {}
class MockGetActiveOrdersUseCase extends Mock implements GetActiveOrdersUseCase {}
class MockGetIncomingOrderUseCase extends Mock implements GetIncomingOrderUseCase {}
class MockAcceptOrderUseCase extends Mock implements AcceptOrderUseCase {}
class MockDeclineOrderUseCase extends Mock implements DeclineOrderUseCase {}
class MockUpdateOrderStatusUseCase extends Mock implements UpdateOrderStatusUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DashboardController controller;
  late MockToggleOnlineStatusUseCase mockToggleOnline;
  late MockGetDashboardSummaryUseCase mockGetSummary;
  late MockGetActiveOrdersUseCase mockGetActiveOrders;
  late MockGetIncomingOrderUseCase mockGetIncomingOrder;
  late MockAcceptOrderUseCase mockAcceptOrder;
  late MockDeclineOrderUseCase mockDeclineOrder;
  late MockUpdateOrderStatusUseCase mockUpdateStatus;

  setUp(() {
    Get.testMode = true;
    mockToggleOnline = MockToggleOnlineStatusUseCase();
    mockGetSummary = MockGetDashboardSummaryUseCase();
    mockGetActiveOrders = MockGetActiveOrdersUseCase();
    mockGetIncomingOrder = MockGetIncomingOrderUseCase();
    mockAcceptOrder = MockAcceptOrderUseCase();
    mockDeclineOrder = MockDeclineOrderUseCase();
    mockUpdateStatus = MockUpdateOrderStatusUseCase();

    when(() => mockGetSummary()).thenAnswer(
      (_) async => const Right({
        'todayEarnings': 148.50,
        'todayDeliveries': 9,
        'totalTrips': 1420,
        'acceptanceRate': 96.5,
        'rating': 4.92,
        'onlineHours': 5.8,
      }),
    );
    when(() => mockGetActiveOrders()).thenAnswer((_) async => const Right([]));
    when(() => mockToggleOnline(any())).thenAnswer((_) async => const Right(true));

    controller = DashboardController(
      toggleOnlineStatusUseCase: mockToggleOnline,
      getDashboardSummaryUseCase: mockGetSummary,
      getActiveOrdersUseCase: mockGetActiveOrders,
      getIncomingOrderUseCase: mockGetIncomingOrder,
      acceptOrderUseCase: mockAcceptOrder,
      declineOrderUseCase: mockDeclineOrder,
      updateOrderStatusUseCase: mockUpdateStatus,
    );
    Get.put<DashboardController>(controller);
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('FCM Dynamic Payload & Revocation Tests', () {
    test('handleIncomingOfferPush parses dynamic deliveryFee and store details (no mock fallback)', () {
      controller.isOnline.value = true;

      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'assignmentId': 'asgn_123',
        'timeout': '60',
        'deliveryFee': '150.00',
        'deliveryEarning': '150.00',
        'earning': '150.00',
        'amount': '150.00',
        'shopName': 'Lumley Grocery Mart',
        'shopAddress': '25 Lumley Road, Freetown',
        'customerName': 'Amadu Sesay',
        'customerAddress': '4 Wilkinson Road',
        'customerPhone': '+23276123456',
        'distanceKm': '3.5',
      });

      final offer = controller.incomingOrder.value;
      expect(offer, isNotNull);
      expect(offer!.id, 'cmtv4o81a0002ibrgfc87dn0r');
      expect(offer.orderNumber, 'meeem00000060');
      expect(offer.riderEarnings, 150.00); // Dynamic earning 150.00, NOT 18.50
      expect(offer.pickupName, 'Lumley Grocery Mart'); // Dynamic shop name, NOT Electronics Hub
      expect(offer.pickupAddress, '25 Lumley Road, Freetown');
      expect(offer.customerName, 'Amadu Sesay'); // Dynamic customer name, NOT Fatmata Koroma
      expect(offer.dropoffAddress, '4 Wilkinson Road');
      expect(offer.distanceKm, 3.5);
      expect(controller.countdownSeconds.value, 60);
    });

    test('handleIncomingOfferPush parses aliases deliveryEarning and earning', () {
      controller.isOnline.value = true;

      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'deliveryEarning': '150.00',
        'shopName': 'Star Pharmacy',
        'customerName': 'Kadiatu Kamara',
      });

      final offer = controller.incomingOrder.value;
      expect(offer, isNotNull);
      expect(offer!.riderEarnings, 150.00);
      expect(offer.pickupName, 'Star Pharmacy');
      expect(offer.customerName, 'Kadiatu Kamara');
    });

    test('handleAssignmentRevokedPush immediately dismisses incoming offer countdown card', () {
      controller.isOnline.value = true;

      // First, trigger an incoming offer
      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'deliveryFee': '150.00',
        'shopName': 'Lumley Grocery Mart',
        'customerName': 'Amadu Sesay',
      });

      expect(controller.incomingOrder.value, isNotNull);

      // Now simulate receiving ASSIGNMENT_REVOKED
      controller.handleAssignmentRevokedPush({
        'type': 'ASSIGNMENT_REVOKED',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
      });

      // The incoming offer must immediately be cleared
      expect(controller.incomingOrder.value, isNull);
    });

    testWidgets('IncomingOfferCard displays NLe 150.00 and real shop name', (WidgetTester tester) async {
      controller.isOnline.value = true;

      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'deliveryFee': '150.00',
        'shopName': 'Freetown Fresh Market',
        'customerName': 'Mariama Jalloh',
        'customerAddress': '8 Sanders Street',
      });

      final offer = controller.incomingOrder.value!;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: IncomingOfferCard(order: offer),
          ),
        ),
      );

      // Header Tag
      expect(find.text('NEW WATERFALL OFFER'), findsOneWidget);
      // Real Store Name
      expect(find.text('Freetown Fresh Market'), findsOneWidget);
      // Real Customer Name
      expect(find.text('Mariama Jalloh'), findsOneWidget);
      // Earning Badge must show 150.00, NOT 18.50
      expect(find.textContaining('150.00'), findsOneWidget);
      expect(find.textContaining('18.50'), findsNothing);

      controller.cancelCountdownTimer();
    });

    test('acceptIncomingOrder calls acceptOrderUseCase with assignmentId', () async {
      controller.isOnline.value = true;
      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'assignmentId': 'asgn_test_xyz789',
        'deliveryFee': '150.00',
        'shopName': 'Freetown Fresh Market',
        'customerName': 'Mariama Jalloh',
      });

      final accepted = OrderEntity(
        id: 'asgn_test_xyz789',
        orderNumber: 'meeem00000060',
        status: OrderStatus.accepted,
        customerName: 'Mariama Jalloh',
        customerPhone: '',
        customerAvatar: '',
        pickupName: 'Freetown Fresh Market',
        pickupAddress: '',
        pickupPhone: '',
        dropoffAddress: '',
        pickupLat: 8.484,
        pickupLng: -13.234,
        dropoffLat: 8.460,
        dropoffLng: -13.250,
        items: const [],
        subtotal: 0.0,
        riderEarnings: 150.00,
        distanceKm: 2.1,
        estimatedDurationMin: 15,
        createdAt: DateTime.now(),
      );

      when(() => mockAcceptOrder('asgn_test_xyz789')).thenAnswer((_) async => Right(accepted));

      await controller.acceptIncomingOrder();

      verify(() => mockAcceptOrder('asgn_test_xyz789')).called(1);
      expect(controller.incomingOrder.value, isNull);
    });

    test('declineIncomingOrder calls declineOrderUseCase with assignmentId', () async {
      controller.isOnline.value = true;
      controller.handleIncomingOfferPush({
        'type': 'NEW_OFFER',
        'orderId': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'assignmentId': 'asgn_test_xyz789',
        'deliveryFee': '150.00',
        'shopName': 'Freetown Fresh Market',
        'customerName': 'Mariama Jalloh',
      });

      when(() => mockDeclineOrder('asgn_test_xyz789', any())).thenAnswer((_) async => const Right(true));

      await controller.declineIncomingOrder('Rider busy');

      verify(() => mockDeclineOrder('asgn_test_xyz789', 'Rider busy')).called(1);
      expect(controller.incomingOrder.value, isNull);
    });
  });
}
