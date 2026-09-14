import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/entities/order_item_entity.dart';
import 'package:meeem_rider/presentation/modules/orders/widgets/pickup_proof_dialog.dart';

void main() {
  group('PickupProofDialog Widget Tests', () {
    final sampleOrder = OrderEntity(
      id: 'ord_123',
      orderNumber: 'meeem00000068',
      status: OrderStatus.atPickup,
      customerName: 'Pranabesh Sarkar',
      customerPhone: '+232 76 998877',
      customerAvatar: '',
      pickupName: 'Apex Electronics Store',
      pickupAddress: '124 Siaka Stevens Street',
      pickupPhone: '+232 76 112233',
      dropoffAddress: 'Cooch Behar',
      pickupLat: 8.484,
      pickupLng: -13.234,
      dropoffLat: 8.472,
      dropoffLng: -13.255,
      items: const [
        OrderItemEntity(name: 'Sony Headphones', quantity: 1),
      ],
      subtotal: 150.0,
      riderEarnings: 150.0,
      distanceKm: 2.5,
      estimatedDurationMin: 15,
      createdAt: DateTime.now(),
      notes: '',
      deliveryOtp: '687327',
    );

    setUp(() {
      Get.reset();
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('renders dialog elements, title, order number, and min 2 photos requirement', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: PickupProofDialog(
              order: sampleOrder,
              onConfirmed: (_) async => true,
            ),
          ),
        ),
      );

      expect(find.text('Package Pickup Proof'), findsOneWidget);
      expect(find.text('#meeem00000068'), findsOneWidget);
      expect(find.text('Captured Photos (0/5)'), findsOneWidget);
      expect(find.text('Min 2 required'), findsOneWidget);
      expect(find.text('Minimum 2 photos required to confirm pickup'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Confirm Pickup & Upload Photos'), findsOneWidget);
    });

    testWidgets('clicking confirm with less than 2 photos triggers validation snackbar and does not call onConfirmed', (WidgetTester tester) async {
      bool onConfirmedCalled = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: PickupProofDialog(
              order: sampleOrder,
              onConfirmed: (_) async {
                onConfirmedCalled = true;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Confirm Pickup & Upload Photos'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(onConfirmedCalled, isFalse);
      expect(find.text('Minimum 2 Photos Required'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('close icon dismisses dialog via Navigator.pop', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => PickupProofDialog(
                      order: sampleOrder,
                      onConfirmed: (_) async => true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Package Pickup Proof'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Package Pickup Proof'), findsNothing);
    });
  });
}
