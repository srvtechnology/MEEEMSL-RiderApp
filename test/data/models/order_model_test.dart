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
}
