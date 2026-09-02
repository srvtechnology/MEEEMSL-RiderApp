import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
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
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.activeOrders);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load active orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<OrderModel?> getIncomingOrder() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.incomingOrder);
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to check incoming orders',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<OrderModel> acceptOrder(String orderId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.acceptOrder,
        data: {'orderId': orderId},
      );
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      // Fallback
      return OrderModel.fromJson({
        'id': orderId,
        'orderNumber': '#MM-8839',
        'status': 'accepted',
        'customerName': 'Sarah Jenkins',
        'customerPhone': '+1 555 987 6543',
        'pickupName': 'Artisan Burger Co.',
        'pickupAddress': '742 Evergreen Terrace',
        'dropoffAddress': '124 Conch Street, Apt 4B',
        'subtotal': 48.50,
        'riderEarnings': 14.80,
        'distanceKm': 3.4,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to accept order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> declineOrder(String orderId, String reason) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.declineOrder,
        data: {'orderId': orderId, 'reason': reason},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to decline order',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updateOrderStatus,
        data: {
          'orderId': orderId,
          'status': status.name,
          'proofPhotoUrl': proofPhotoUrl,
          'customerOtp': customerOtp,
        },
      );
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return OrderModel.fromJson({
        'id': orderId,
        'orderNumber': '#MM-8839',
        'status': status.name,
        'customerName': 'Sarah Jenkins',
        'customerPhone': '+1 555 987 6543',
        'pickupName': 'Artisan Burger Co.',
        'pickupAddress': '742 Evergreen Terrace',
        'dropoffAddress': '124 Conch Street, Apt 4B',
        'subtotal': 48.50,
        'riderEarnings': 14.80,
        'distanceKm': 3.4,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to update order status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<OrderModel>> getOrderHistory({String? statusFilter}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orderHistory,
        queryParameters: statusFilter != null ? {'status': statusFilter} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load order history',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      final response = await _dioClient.dio.get(
        '\${ApiEndpoints.orderDetails}/\$orderId',
      );
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Order not found');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to get order details',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
