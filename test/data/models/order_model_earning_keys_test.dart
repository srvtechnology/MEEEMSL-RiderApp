import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/order_model.dart';

void main() {
  group('OrderModel Dynamic Earning Keys Tests', () {
    test('deserializes deliveryFee string correctly (e.g. 150.00)', () {
      final json = {
        'id': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'status': 'PENDING',
        'deliveryFee': '150.00',
        'shopName': 'Super Market Central',
        'customerName': 'Mohamed Conteh',
        'customerAddress': '15 Lumley Beach Road',
        'distanceKm': '3.2',
      };

      final order = OrderModel.fromJson(json);

      expect(order.riderEarnings, 150.00);
      expect(order.pickupName, 'Super Market Central');
      expect(order.customerName, 'Mohamed Conteh');
      expect(order.dropoffAddress, '15 Lumley Beach Road');
      expect(order.distanceKm, 3.2);
    });

    test('deserializes deliveryEarning alias correctly', () {
      final json = {
        'id': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'deliveryEarning': 75.50,
      };

      final order = OrderModel.fromJson(json);
      expect(order.riderEarnings, 75.50);
    });

    test('deserializes earning alias correctly', () {
      final json = {
        'id': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'earning': '85.20',
      };

      final order = OrderModel.fromJson(json);
      expect(order.riderEarnings, 85.20);
    });

    test('deserializes earningForThisDelivery alias correctly', () {
      final json = {
        'id': 'cmtv4o81a0002ibrgfc87dn0r',
        'orderNumber': 'meeem00000060',
        'earningForThisDelivery': 120.00,
      };

      final order = OrderModel.fromJson(json);
      expect(order.riderEarnings, 120.00);
    });

    test('deserializes nested order deliveryFee / deliveryEarning correctly', () {
      final json = {
        'id': 'cmtv4o81a0002ibrgfc87dn0r',
        'order': {
          'id': 'cmtv4o81a0002ibrgfc87dn0r',
          'orderNumber': 'meeem00000060',
          'deliveryFee': '150.00',
          'shippingFullName': 'Fatmata Koroma',
        },
      };

      final order = OrderModel.fromJson(json);
      expect(order.riderEarnings, 150.00);
      expect(order.customerName, 'Fatmata Koroma');
    });

    test('does not fall back to old mock 14.80 when earnings are 0 or empty', () {
      final json = {
        'id': 'ord_zero_01',
        'orderNumber': 'meeem00000001',
      };

      final order = OrderModel.fromJson(json);
      expect(order.riderEarnings, 0.0);
    });
  });
}
