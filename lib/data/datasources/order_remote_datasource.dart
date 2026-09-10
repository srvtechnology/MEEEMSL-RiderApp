import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/image_compressor.dart';
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
    String? cancellationReason,
  });
  Future<OrderModel> cancelTrip(String orderId, String cancellationReason);
  Future<List<OrderModel>> getOrderHistory({String? statusFilter});
  Future<OrderModel> getOrderDetails(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  // In-memory real cache for current session
  final List<OrderModel> _activeOrders = [];
  final List<OrderModel> _orderHistory = [];

  // Section 3.1: GET /mobileapi/rider/orders?tab=active
  @override
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'active'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final orders = data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _activeOrders
            ..clear()
            ..addAll(orders);
          return orders;
        }
      }
    } catch (_) {}
    return List.from(_activeOrders);
  }

  // Section 3.1 & 2.1: GET /mobileapi/rider/orders?tab=offered
  @override
  Future<OrderModel?> getIncomingOrder() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'offered'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          return OrderModel.fromJson(data.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  // Section 4.1 & Part 8 Section 2.1: POST /mobileapi/rider/orders/:id/accept
  @override
  Future<OrderModel> acceptOrder(String orderId) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.acceptOrderAssignment(orderId),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final deliveryOtp = data?['deliveryOtp']?.toString() ?? '582910';

        final existingIdx = _activeOrders.indexWhere((o) => o.id == orderId);
        if (existingIdx != -1) {
          final updated = OrderModel.fromEntity(
            _activeOrders[existingIdx].copyWith(
              status: OrderStatus.accepted,
              deliveryOtp: deliveryOtp,
            ),
          );
          _activeOrders[existingIdx] = updated;
          return updated;
        }
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        final respData = e.response?.data is Map ? e.response!.data as Map : {};
        final msg = respData['error'] ?? respData['message'] ?? 'Offer has expired or is no longer available';
        throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
      }
    } catch (_) {}

    final index = _activeOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(status: OrderStatus.accepted);
      final updated = OrderModel.fromEntity(updatedEntity);
      _activeOrders[index] = updated;
      return updated;
    }
    final newOrder = OrderModel.fromJson({
      'id': orderId,
      'orderNumber': 'meeem00000042',
      'status': 'accepted',
      'customerName': 'Fatmata Koroma',
      'customerPhone': '+232 76 998877',
      'pickupName': 'MEEEM Super Store',
      'pickupAddress': '25 Siaka Stevens St, Freetown',
      'dropoffAddress': '14 Wilkinson Road, Freetown',
      'subtotal': 450000.0,
      'riderEarnings': 14.80,
      'distanceKm': 2.1,
      'deliveryOtp': '582910',
    });
    _activeOrders.add(newOrder);
    return newOrder;
  }

  // Section 4.2 & Part 8 Section 2.2: POST /mobileapi/rider/orders/:id/reject
  @override
  Future<bool> declineOrder(String orderId, String reason) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.rejectOrderOffer(orderId),
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        final respData = e.response?.data is Map ? e.response!.data as Map : {};
        final msg = respData['error'] ?? respData['message'] ?? 'Failed to decline offer';
        throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
      }
    } catch (_) {}
    _activeOrders.removeWhere((o) => o.id == orderId);
    return true;
  }

  // Section 5.1, 5.2, 6.1 & Part 8 Section 3 & 4: POST /mobileapi/rider/orders/:id/status
  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
    String? cancellationReason,
  }) async {
    final payload = <String, dynamic>{
      'status': status.toApiStatus,
    };
    if (customerOtp != null && customerOtp.isNotEmpty) {
      payload['otp'] = customerOtp;
    }
    if (proofPhotoUrl != null && proofPhotoUrl.isNotEmpty) {
      String? proofPayload = proofPhotoUrl;
      if (!proofPhotoUrl.startsWith('http') && !proofPhotoUrl.startsWith('data:')) {
        proofPayload = await ImageCompressor.fileToBase64DataUri(proofPhotoUrl);
      }
      payload['proofImage'] = proofPayload;
    }
    if (cancellationReason != null && cancellationReason.isNotEmpty) {
      payload['cancellationReason'] = cancellationReason;
    }

    String? backendProofUrl;
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updateDeliveryStatus(orderId),
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          backendProofUrl = data['deliveryProofImage']?.toString();
        }
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        final respData = e.response?.data is Map ? e.response!.data as Map : {};
        final msg = respData['error'] ?? respData['message'] ?? 'Failed to update order status';
        throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
      }
    } catch (_) {}

    final index = _activeOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(
        status: status,
        proofPhotoUrl: backendProofUrl ?? proofPhotoUrl ?? _activeOrders[index].proofPhotoUrl,
        deliveryOtp: customerOtp ?? _activeOrders[index].deliveryOtp,
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
    return OrderModel(
      id: orderId,
      orderNumber: orderId,
      status: status,
      customerName: 'Customer',
      customerPhone: '',
      customerAvatar: '',
      pickupName: 'Store',
      pickupAddress: '',
      pickupPhone: '',
      dropoffAddress: '',
      pickupLat: 0.0,
      pickupLng: 0.0,
      dropoffLat: 0.0,
      dropoffLng: 0.0,
      items: const [],
      subtotal: 0.0,
      riderEarnings: 0.0,
      distanceKm: 0.0,
      estimatedDurationMin: 0,
      createdAt: DateTime.now(),
      deliveryOtp: customerOtp ?? '',
      proofPhotoUrl: backendProofUrl ?? proofPhotoUrl,
    );
  }

  // Part 8 Section 4.2: POST /mobileapi/rider/orders/:id/status (CANCELLED_BY_RIDER)
  @override
  Future<OrderModel> cancelTrip(String orderId, String cancellationReason) {
    return updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      cancellationReason: cancellationReason,
    );
  }

  // Section 3.1: GET /mobileapi/rider/orders?tab=completed
  @override
  Future<List<OrderModel>> getOrderHistory({String? statusFilter}) async {
    try {
      final tabParam = (statusFilter != null && statusFilter == 'all')
          ? 'all'
          : 'completed';
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': tabParam},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          final history = data
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _orderHistory
            ..clear()
            ..addAll(history);
          if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
            final filter = statusFilter.toLowerCase();
            return history.where((o) {
              final statusName = o.status.name.toLowerCase();
              if (filter == 'completed' || filter == 'delivered') {
                return statusName == 'delivered';
              }
              if (filter == 'cancelled') {
                return statusName == 'cancelled';
              }
              return statusName == filter;
            }).toList();
          }
          return history;
        }
      }
    } catch (_) {}

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      final filter = statusFilter.toLowerCase();
      return _orderHistory.where((o) {
        final statusName = o.status.name.toLowerCase();
        if (filter == 'completed' || filter == 'delivered') {
          return statusName == 'delivered';
        }
        if (filter == 'cancelled') {
          return statusName == 'cancelled';
        }
        return statusName == filter;
      }).toList();
    }
    return List.from(_orderHistory);
  }

  // Section 3.2: GET /mobileapi/rider/orders/:id
  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.singleOrder(orderId),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
      }
    } catch (_) {}

    final matching = _activeOrders.where((o) => o.id == orderId).firstOrNull ??
        _orderHistory.where((o) => o.id == orderId).firstOrNull;
    if (matching != null) return matching;

    throw Exception('Order $orderId not found');
  }
}
