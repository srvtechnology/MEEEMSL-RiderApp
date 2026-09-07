import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/presentation/modules/orders/widgets/milestone_stepper.dart';

void main() {
  group('MilestoneStepper Widget Tests (Part 3 Section 4.4 #2)', () {
    testWidgets('renders all 5 steps properly for accepted status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilestoneStepper(status: OrderStatus.accepted),
          ),
        ),
      );

      expect(find.text('DELIVERY MILESTONES (5 STEPS)'), findsOneWidget);
      expect(find.text('Step 1 of 5'), findsOneWidget);
      expect(find.text('Accept Offer'), findsOneWidget);
      expect(find.text('Arrive at Store'), findsOneWidget);
      expect(find.text('Collect Package'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Verify OTP & Complete'), findsOneWidget);
    });

    testWidgets('shows completed icon for finished steps and updates status text for outForDelivery',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilestoneStepper(status: OrderStatus.outForDelivery),
          ),
        ),
      );

      expect(find.text('Step 4 of 5'), findsOneWidget);
      // First 3 steps are completed (checks)
      expect(find.byIcon(Icons.check), findsNWidgets(3));
      // Step 4 is current (shows number 4)
      expect(find.text('4'), findsOneWidget);
      // Step 5 is upcoming (shows number 5)
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows all 5 check icons when status is delivered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MilestoneStepper(status: OrderStatus.delivered),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNWidgets(5));
      expect(find.text('Step 5 of 5 (Delivered)'), findsOneWidget);
    });
  });
}
