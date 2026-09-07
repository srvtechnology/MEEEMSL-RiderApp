import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/order_model.dart';
import 'package:meeem_rider/domain/entities/order_entity.dart';

void main() {
  final tOrderModel = OrderModel(
    id: 'ord_123',
    orderNumber: '#MM-1001',
    status: OrderStatus.outForDelivery,
    customerName: 'Alice Smith',
    customerPhone: '+1 555 123 4567',
    customerAvatar: '',
    pickupName: 'Pizza Bistro',
    pickupAddress: '100 Main St',
    pickupPhone: '+1 555 999 8888',
    dropoffAddress: '200 Oak Ave',
    pickupLat: 40.7128,
    pickupLng: -74.0060,
    dropoffLat: 40.7306,
    dropoffLng: -73.9352,
    items: [],
    subtotal: 35.0,
    riderEarnings: 12.5,
    distanceKm: 2.5,
    estimatedDurationMin: 15,
    createdAt: DateTime(2026, 1, 1),
  );

  test('OrderModel should be a subclass of OrderEntity', () {
    expect(tOrderModel, isA<OrderEntity>());
  });

  test('OrderModel fromJson should parse JSON correctly', () {
    final json = {
      'id': 'ord_123',
      'orderNumber': '#MM-1001',
      'status': 'out_for_delivery',
      'customerName': 'Alice Smith',
      'customerPhone': '+1 555 123 4567',
      'pickupName': 'Pizza Bistro',
      'pickupAddress': '100 Main St',
      'dropoffAddress': '200 Oak Ave',
      'subtotal': 35.0,
      'riderEarnings': 12.5,
      'distanceKm': 2.5,
      'estimatedDurationMin': 15,
    };

    final result = OrderModel.fromJson(json);

    expect(result.id, 'ord_123');
    expect(result.orderNumber, '#MM-1001');
    expect(result.status, OrderStatus.outForDelivery);
    expect(result.customerName, 'Alice Smith');
    expect(result.riderEarnings, 12.5);
  });

  test('OrderModel fromJson parses Part 2 nested order structure according to API Doc Part 2', () {
    final part2Json = {
      'id': 'cuid_assignment_id',
      'orderId': 'cuid_order_id',
      'status': 'ACCEPTED',
      'dispatchMode': 'AUTO_CASCADE',
      'distanceKm': 2.1,
      'offeredAt': '2026-08-26T14:00:00.000Z',
      'acceptedAt': '2026-08-26T14:00:25.000Z',
      'deliveryOtp': '582910',
      'order': {
        'id': 'cuid_order_id',
        'orderNumber': 'meeem00000042',
        'totalAmount': 450000,
        'subtotal': 430000,
        'shipping': 20000,
        'paymentMethod': 'COD',
        'shippingFullName': 'Fatmata Koroma',
        'shippingPhone': '+23276123456',
        'shippingAddressLine1': '14 Wilkinson Road',
        'shippingAddressLine2': 'Near Total Station',
        'shippingCity': 'Freetown',
        'seller': {
          'store': {'name': 'MEEEM Super Store'},
          'businessInfo': {
            'businessName': 'MEEEM Super Store Ltd',
            'pocContact': '+23277987654',
            'street': '25 Siaka Stevens St',
            'city': 'Freetown',
            'latitude': 8.484,
            'longitude': -13.234,
          },
        },
        'items': [
          {
            'id': 'cuid_item_1',
            'quantity': 2,
            'price': 450000,
            'productNameSnapshot': 'Samsung Galaxy A54',
            'product': {
              'name': 'Samsung Galaxy A54',
              'images': ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'],
            },
          },
        ],
      },
    };

    final order = OrderModel.fromJson(part2Json);

    expect(order.id, 'cuid_assignment_id');
    expect(order.orderNumber, 'meeem00000042');
    expect(order.status, OrderStatus.accepted);
    expect(order.customerName, 'Fatmata Koroma');
    expect(order.customerPhone, '+23276123456');
    expect(order.dropoffAddress, contains('14 Wilkinson Road'));
    expect(order.dropoffAddress, contains('Freetown'));
    expect(order.pickupName, 'MEEEM Super Store');
    expect(order.pickupAddress, contains('25 Siaka Stevens St'));
    expect(order.pickupPhone, '+23277987654');
    expect(order.deliveryOtp, '582910');
    expect(order.subtotal, 450000.0);
    expect(order.distanceKm, 2.1);
    expect(order.items.length, 1);
    expect(order.items.first.name, 'Samsung Galaxy A54');
    expect(order.items.first.quantity, 2);
  });

  test('OrderStatus toApiStatus produces exact Part 2 status uppercase dictionary', () {
    expect(OrderStatus.pending.toApiStatus, 'OFFERED');
    expect(OrderStatus.accepted.toApiStatus, 'ACCEPTED');
    expect(OrderStatus.atPickup.toApiStatus, 'AT_PICKUP');
    expect(OrderStatus.pickedUp.toApiStatus, 'PICKED_UP');
    expect(OrderStatus.outForDelivery.toApiStatus, 'OUT_FOR_DELIVERY');
    expect(OrderStatus.delivered.toApiStatus, 'DELIVERED');
    expect(OrderStatus.cancelled.toApiStatus, 'CANCELLED_BY_RIDER');
  });
}
