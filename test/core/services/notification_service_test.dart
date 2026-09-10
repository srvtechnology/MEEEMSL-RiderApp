import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Order Notification Tests', () {
    late NotificationService notificationService;

    setUp(() {
      Get.testMode = true;
      notificationService = NotificationService();
    });

    tearDown(() {
      NotificationService.onNewOffer = null;
      NotificationService.onDirectAssignment = null;
      Get.reset();
    });

    testWidgets('showOrderDispatchAlert defaults to 1 minute duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  notificationService.showOrderDispatchAlert(
                    title: '📦 New Delivery Assignment Offer!',
                    message: 'Pickup offer received. Tap to accept within 60s!',
                    onTap: () {},
                  );
                },
                child: const Text('Trigger Notification'),
              );
            }),
          ),
        ),
      );

      // Tap to trigger order alert
      await tester.tap(find.text('Trigger Notification'));
      await tester.pump(); // Start snackbar animation
      await tester.pump(const Duration(milliseconds: 500)); // Visible animation complete

      // Expect snackbar to be present
      expect(find.text('📦 New Delivery Assignment Offer!'), findsOneWidget);
      expect(find.text('Pickup offer received. Tap to accept within 60s!'), findsOneWidget);
      expect(find.text('View Order'), findsOneWidget);

      // Verify that after 10 seconds, it is still visible (previously would have vanished after 5s)
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('📦 New Delivery Assignment Offer!'), findsOneWidget);

      // Verify that after 30 seconds, it is still visible
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('📦 New Delivery Assignment Offer!'), findsOneWidget);

      // Verify that after 55 seconds (total 60s from trigger), it is still visible
      await tester.pump(const Duration(seconds: 25));
      expect(find.text('📦 New Delivery Assignment Offer!'), findsOneWidget);

      // Advance past 60s + fade out animation
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('📦 New Delivery Assignment Offer!'), findsNothing);
    });

    test('handleFcmPayload with NEW_OFFER triggers callback', () {
      bool callbackFired = false;
      Map<String, dynamic>? receivedData;

      NotificationService.onNewOffer = (data, {title, body}) {
        callbackFired = true;
        receivedData = data;
      };

      notificationService.handleFcmPayload({
        'type': 'NEW_OFFER',
        'orderId': 'order_123',
        'orderNumber': 'meeem00000042',
        'timeout': '60',
      });

      expect(callbackFired, isTrue);
      expect(receivedData?['orderId'], 'order_123');
    });

    test('handleFcmPayload with MANUAL_ASSIGN triggers direct assignment callback', () {
      bool directAssignmentFired = false;
      Map<String, dynamic>? receivedData;

      NotificationService.onDirectAssignment = (data) {
        directAssignmentFired = true;
        receivedData = data;
      };

      notificationService.handleFcmPayload({
        'type': 'MANUAL_ASSIGN',
        'orderId': 'order_999',
        'orderNumber': 'meeem00000099',
      });

      expect(directAssignmentFired, isTrue);
      expect(receivedData?['orderId'], 'order_999');
    });

    testWidgets('Tapping View Order button executes onTap and dismisses notification',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  notificationService.showOrderDispatchAlert(
                    title: 'New Order',
                    message: 'New Order Available',
                    onTap: () {
                      tapped = true;
                    },
                  );
                },
                child: const Text('Show Alert'),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.text('Show Alert'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('View Order'), findsOneWidget);
      await tester.tap(find.text('View Order'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(find.text('New Order'), findsNothing);
    });
  });
}
