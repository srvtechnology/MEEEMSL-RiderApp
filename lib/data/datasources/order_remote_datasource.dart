import '../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getActiveOrders();
  Future<OrderModel?> getIncomingOrder();
  Future<OrderModel> acceptOrder(String orderId);
  Future<bool> declineOrder(String orderId, String reason);
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  });
  Future<List<OrderModel>> getOrderHistory({String? statusFilter});
  Future<OrderModel> getOrderDetails(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  // ignore: unused_field
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  // In-memory mock store conforming to MOBILE_RIDER_APP_API_DOC_PART_1.md constraint
  // (Order APIs are not in Part 1 specification)
  final List<OrderModel> _activeOrders = [
    OrderModel.fromJson({
      'id': 'ord_102948',
      'orderNumber': '#MM-8839',
      'status': 'in_transit',
      'customerName': 'Sarah Jenkins',
      'customerPhone': '+232 76 998877',
      'customerAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'pickupName': 'Mama Beach Grill',
      'pickupAddress': 'Mama Beach, Zone 1',
      'pickupPhone': '+232 76 112233',
      'dropoffAddress': 'No 2 River Beach House #4',
      'pickupLat': 8.484,
      'pickupLng': -13.234,
      'dropoffLat': 8.460,
      'dropoffLng': -13.250,
      'items': [
        {'name': 'Grilled Barracuda & Plantain', 'quantity': 2, 'notes': 'Extra spicy sauce'},
        {'name': 'Ginger Beer (Cold)', 'quantity': 2, 'notes': ''},
      ],
      'subtotal': 48.50,
      'riderEarnings': 14.80,
      'distanceKm': 3.4,
      'estimatedDurationMin': 16,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
      'notes': 'Please call when arriving at the gate.',
      'deliveryOtp': '4829',
    }),
  ];

  final List<OrderModel> _orderHistory = [
    OrderModel.fromJson({
      'id': 'ord_102940',
      'orderNumber': '#MM-8830',
      'status': 'delivered',
      'customerName': 'David Cole',
      'pickupName': 'Tokeh Seafood Shack',
      'pickupAddress': 'Tokeh Village',
      'dropoffAddress': 'Baw Baw Point #2',
      'subtotal': 42.00,
      'riderEarnings': 15.00,
      'createdAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    }),
    OrderModel.fromJson({
      'id': 'ord_102935',
      'orderNumber': '#MM-8821',
      'status': 'delivered',
      'customerName': 'Amara Turay',
      'pickupName': 'Lakka Ocean Grill',
      'pickupAddress': 'Lakka Beach',
      'dropoffAddress': 'Hamilton Village Center',
      'subtotal': 38.50,
      'riderEarnings': 13.50,
      'createdAt': DateTime.now().subtract(const Duration(hours: 7)).toIso8601String(),
    }),
  ];

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    return List.from(_activeOrders);
  }

  @override
  Future<OrderModel?> getIncomingOrder() async {
    return null;
  }

  @override
  Future<OrderModel> acceptOrder(String orderId) async {
    final index = _activeOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(status: OrderStatus.accepted);
      final updated = OrderModel.fromEntity(updatedEntity);
      _activeOrders[index] = updated;
      return updated;
    }
    final newOrder = OrderModel.fromJson({
      'id': orderId,
      'orderNumber': '#MM-8839',
      'status': 'accepted',
      'customerName': 'Sarah Jenkins',
      'customerPhone': '+232 76 998877',
      'pickupName': 'Mama Beach Grill',
      'pickupAddress': 'Mama Beach, Zone 1',
      'dropoffAddress': 'No 2 River Beach House #4',
      'subtotal': 48.50,
      'riderEarnings': 14.80,
      'distanceKm': 3.4,
    });
    _activeOrders.add(newOrder);
    return newOrder;
  }

  @override
  Future<bool> declineOrder(String orderId, String reason) async {
    _activeOrders.removeWhere((o) => o.id == orderId);
    return true;
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  }) async {
    final index = _activeOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(
        status: status,
        proofPhotoUrl: proofPhotoUrl ?? _activeOrders[index].proofPhotoUrl,
      );
      final updated = OrderModel.fromEntity(updatedEntity);
      if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
        _activeOrders.removeAt(index);
        _orderHistory.insert(0, updated);
      } else {
        _activeOrders[index] = updated;
      }
      return updated;
    }
    return OrderModel.fromJson({
      'id': orderId,
      'orderNumber': '#MM-8839',
      'status': status.name,
      'customerName': 'Sarah Jenkins',
      'customerPhone': '+232 76 998877',
      'pickupName': 'Mama Beach Grill',
      'pickupAddress': 'Mama Beach, Zone 1',
      'dropoffAddress': 'No 2 River Beach House #4',
      'subtotal': 48.50,
      'riderEarnings': 14.80,
      'distanceKm': 3.4,
    });
  }

  @override
  Future<List<OrderModel>> getOrderHistory({String? statusFilter}) async {
    if (statusFilter != null && statusFilter.isNotEmpty) {
      return _orderHistory
          .where((o) => o.status.name.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }
    return List.from(_orderHistory);
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    final active = _activeOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => _orderHistory.firstWhere(
        (o) => o.id == orderId,
        orElse: () => OrderModel.fromJson({
          'id': orderId,
          'orderNumber': '#MM-8839',
          'status': 'in_transit',
          'customerName': 'Sarah Jenkins',
          'customerPhone': '+232 76 998877',
          'pickupName': 'Mama Beach Grill',
          'pickupAddress': 'Mama Beach, Zone 1',
          'dropoffAddress': 'No 2 River Beach House #4',
          'subtotal': 48.50,
          'riderEarnings': 14.80,
          'distanceKm': 3.4,
        }),
      ),
    );
    return active;
  }
}
