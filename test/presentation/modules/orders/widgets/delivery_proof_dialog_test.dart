import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:meeem_rider/core/widgets/custom_text_field.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';
import 'package:meeem_rider/domain/entities/order_item_entity.dart';
import 'package:meeem_rider/presentation/modules/orders/widgets/delivery_proof_dialog.dart';

void main() {
  group('DeliveryProofDialog Widget Tests (Part 3 Section 4.3 & 4.4 #3)', () {
    final sampleOrder = OrderEntity(
      id: 'ord_123',
      orderNumber: 'meeem00000042',
      status: OrderStatus.outForDelivery,
      customerName: 'Fatmata Koroma',
      customerPhone: '+232 76 998877',
      customerAvatar: '',
      pickupName: 'MEEEM Super Store',
      pickupAddress: '25 Siaka Stevens St',
      pickupPhone: '+232 76 112233',
      dropoffAddress: '14 Wilkinson Road',
      pickupLat: 8.484,
      pickupLng: -13.234,
      dropoffLat: 8.472,
      dropoffLng: -13.255,
      items: const [
        OrderItemEntity(name: 'Fresh Milk', quantity: 2),
      ],
      subtotal: 100.0,
      riderEarnings: 20.0,
      distanceKm: 3.5,
      estimatedDurationMin: 18,
      createdAt: DateTime.now(),
      notes: '',
      deliveryOtp: '582910',
    );

    testWidgets('renders 6-digit auto-focus OTP input and camera options', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: DeliveryProofDialog(
              order: sampleOrder,
              onConfirmed: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Proof of Delivery'), findsOneWidget);
      expect(find.text('#meeem00000042'), findsOneWidget);
      expect(find.text('Customer 6-Digit Delivery OTP'), findsOneWidget);
      expect(find.text('Take Photo (Camera)'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Verify OTP & Complete Delivery'), findsOneWidget);

      final customTextField = tester.widget<CustomTextField>(find.byType(CustomTextField));
      expect(customTextField.autofocus, isTrue);
      expect(customTextField.maxLength, equals(6));
      expect(customTextField.keyboardType, equals(TextInputType.number));
    });

    testWidgets('calls onConfirmed with valid 6-digit OTP', (WidgetTester tester) async {
      String? receivedOtp;
      String? receivedPhoto;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: DeliveryProofDialog(
              order: sampleOrder,
              onConfirmed: (photo, otp) {
                receivedPhoto = photo;
                receivedOtp = otp;
              },
            ),
          ),
        ),
      );

      // Enter valid 6-digit OTP
      await tester.enterText(find.byType(TextField), '582910');
      await tester.pump();

      // Tap Complete Delivery
      await tester.tap(find.text('Verify OTP & Complete Delivery'));
      await tester.pumpAndSettle();

      expect(receivedOtp, equals('582910'));
      expect(receivedPhoto, isNotNull);
    });
  });
}
