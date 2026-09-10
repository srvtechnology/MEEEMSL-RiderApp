import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/entities/order_item_entity.dart';
import 'package:meeem_rider/presentation/modules/orders/views/order_details_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testOrder = OrderEntity(
    id: '60',
    orderNumber: 'meeem00000060',
    status: OrderStatus.delivered,
    customerName: 'Jeet Basak',
    customerPhone: '+232 76 123456',
    customerAvatar: '',
    pickupName: 'Apex Electronics & Lifestyle Store',
    pickupAddress: '124 Siaka Stevens Street, Freetown',
    pickupPhone: '+232 76 654321',
    dropoffAddress: 'Lumley Beach Road, Tower Hill, Freetown',
    pickupLat: 8.484,
    pickupLng: -13.234,
    dropoffLat: 8.460,
    dropoffLng: -13.250,
    items: const [
      OrderItemEntity(
        name: 'La Roche-Posay Anthelios Ultra Light Invisible Fluid SPF50+ 50ml Sunscreen Lotion',
        quantity: 2,
      ),
      OrderItemEntity(
        name: 'USB-C Fast Charging Cable 2m Braided High-Speed Data Sync Cord',
        quantity: 1,
      ),
    ],
    subtotal: 175.0,
    riderEarnings: 150.0,
    distanceKm: 3.5,
    estimatedDurationMin: 15,
    createdAt: DateTime.now(),
  );

  group('OrderDetailsView Widget Tests', () {
    testWidgets('renders properly without any overflow on narrow screen width (320px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      FlutterErrorDetails? errorDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errorDetails = details;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsView(order: testOrder),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;
      expect(errorDetails, isNull);

      // Verify Fare Summary elements
      expect(find.text('Trip Payout'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);

      // Verify Route Summary elements
      expect(find.text('Apex Electronics & Lifestyle Store'), findsOneWidget);
      expect(find.text('Jeet Basak'), findsOneWidget);

      // Verify Items List elements
      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
      expect(
        find.text('La Roche-Posay Anthelios Ultra Light Invisible Fluid SPF50+ 50ml Sunscreen Lotion'),
        findsOneWidget,
      );
      expect(find.text('1x'), findsOneWidget);
      expect(
        find.text('USB-C Fast Charging Cable 2m Braided High-Speed Data Sync Cord'),
        findsOneWidget,
      );
    });

    testWidgets('renders high payout amount without overflowing', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      FlutterErrorDetails? errorDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errorDetails = details;
      };

      final largeEarningsOrder = testOrder.copyWith(riderEarnings: 2500000.00);

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailsView(order: largeEarningsOrder),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = oldHandler;
      expect(errorDetails, isNull);
      expect(find.text('Trip Payout'), findsOneWidget);
    });
  });
}
