import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/presentation/modules/orders/widgets/cancel_delivery_dialog.dart';

void main() {
  final testOrder = OrderEntity(
    id: 'cuid_order_123',
    orderNumber: 'meeem00000042',
    status: OrderStatus.accepted,
    customerName: 'Fatmata Koroma',
    customerPhone: '+232 76 998877',
    customerAvatar: '',
    pickupName: 'MEEEM Super Store',
    pickupAddress: '25 Siaka Stevens St, Freetown',
    pickupPhone: '+232 76 112233',
    dropoffAddress: '14 Wilkinson Road, Freetown',
    pickupLat: 8.484,
    pickupLng: -13.234,
    dropoffLat: 8.460,
    dropoffLng: -13.250,
    items: const [],
    subtotal: 450000.0,
    riderEarnings: 14.80,
    distanceKm: 2.1,
    estimatedDurationMin: 15,
    createdAt: DateTime.now(),
  );

  group('CancelDeliveryDialog Widget Tests (Part 8 Section 4.3)', () {
    testWidgets('renders all 4 standard reasons from Part 8 Section 4.1 & 4.3', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CancelDeliveryDialog(
              order: testOrder,
              onConfirmed: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Cancel Delivery'), findsOneWidget);
      expect(find.text('#meeem00000042'), findsOneWidget);
      expect(find.text('Vehicle breakdown'), findsOneWidget);
      expect(find.text('Personal emergency'), findsOneWidget);
      expect(find.text('Store was closed'), findsOneWidget);
      expect(find.text('Severe weather / impassable road'), findsOneWidget);
      expect(find.text('Other reason'), findsOneWidget);
    });

    testWidgets('confirming with default selected reason calls onConfirmed with Vehicle breakdown', (WidgetTester tester) async {
      String? submittedReason;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CancelDeliveryDialog(
              order: testOrder,
              onConfirmed: (reason) {
                submittedReason = reason;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('confirm_cancel_button')));
      await tester.pumpAndSettle();

      expect(submittedReason, 'Vehicle breakdown');
    });

    testWidgets('selecting Severe weather reason submits that reason', (WidgetTester tester) async {
      String? submittedReason;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CancelDeliveryDialog(
              order: testOrder,
              onConfirmed: (reason) {
                submittedReason = reason;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('reason_Severe weather / impassable road')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_cancel_button')));
      await tester.pumpAndSettle();

      expect(submittedReason, 'Severe weather / impassable road');
    });

    testWidgets('selecting Other reason enables custom text field and submits custom reason', (WidgetTester tester) async {
      String? submittedReason;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: CancelDeliveryDialog(
              order: testOrder,
              onConfirmed: (reason) {
                submittedReason = reason;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('reason_other')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_reason_field')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('custom_reason_field')), 'Customer requested reschedule');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_cancel_button')));
      await tester.pumpAndSettle();

      expect(submittedReason, 'Customer requested reschedule');
    });
  });
}
