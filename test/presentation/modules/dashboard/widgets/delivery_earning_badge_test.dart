import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/widgets/delivery_earning_badge.dart';

void main() {
  group('DeliveryEarningBadge Widget Tests (Part 3 Section 4.4 #1)', () {
    testWidgets('renders emerald green delivery earning badge with prefix and formatted amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryEarningBadge(amount: 20.0),
          ),
        ),
      );

      expect(find.text('Delivery Earning: \$20.00'), findsOneWidget);
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(DeliveryEarningBadge.emeraldBg));
      final border = decoration.border as Border;
      expect(border.top.color, equals(DeliveryEarningBadge.emeraldBorder));
    });

    testWidgets('renders compact delivery earning badge without prefix when requested',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryEarningBadge(
              amount: 14.80,
              isCompact: true,
              showPrefix: false,
            ),
          ),
        ),
      );

      expect(find.text('\$14.80'), findsOneWidget);
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);
    });
  });
}
