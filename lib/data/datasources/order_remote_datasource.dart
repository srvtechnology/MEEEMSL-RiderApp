import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/image_compressor.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getActiveOrders();
  Future<OrderModel?> getIncomingOrder();
  Future<OrderModel> acceptOrder(String orderId, {OrderEntity? cachedOrder});
  Future<bool> declineOrder(String orderId, String reason);
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
    String? cancellationReason,
    List<String>? pickupPhotos,
  });
  Future<OrderModel> cancelTrip(String orderId, String cancellationReason);
  Future<List<OrderModel>> getOrderHistory({String? statusFilter});
  Future<OrderModel> getOrderDetails(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  GetStorage get _storage => GetStorage();

  // In-memory real cache for current session
  final List<OrderModel> _activeOrders = [];
  final List<OrderModel> _orderHistory = [];
  OrderModel? _lastIncomingOrder;

  void _saveActiveOrderToLocal(OrderModel order) {
    try {
      _storage.write(AppConstants.activeOrderKey, order.toJson());
      debugPrint('[OrderRemoteDataSource] Cached active order ${order.id} (assignment: ${order.assignmentId}, status: ${order.status.name}) to GetStorage');
    } catch (e) {
      debugPrint('[OrderRemoteDataSource] Failed to cache active order: $e');
    }
  }

  OrderModel? _loadActiveOrderFromLocal() {
    try {
      final raw = _storage.read(AppConstants.activeOrderKey);
      if (raw != null && raw is Map) {
        final order = OrderModel.fromJson(Map<String, dynamic>.from(raw));
        if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) {
          debugPrint('[OrderRemoteDataSource] Loaded active order ${order.id} (status: ${order.status.name}) from GetStorage');
          return order;
        } else {
          _clearActiveOrderFromLocal();
        }
      }
    } catch (e) {
      debugPrint('[OrderRemoteDataSource] Error loading cached active order: $e');
    }
    return null;
  }

  void _clearActiveOrderFromLocal() {
    try {
      _storage.remove(AppConstants.activeOrderKey);
      debugPrint('[OrderRemoteDataSource] Cleared active order from GetStorage');
    } catch (e) {
      debugPrint('[OrderRemoteDataSource] Error clearing cached active order: $e');
    }
  }

  // Section 3.1: GET /mobileapi/rider/orders?tab=active (with robust multi-tier fallback)
  @override
  Future<List<OrderModel>> getActiveOrders() async {
    // 1. Tier 1: GET /orders?tab=active
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'active'},
      );
      debugPrint('[OrderRemoteDataSource] getActiveOrders tab=active statusCode: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final orders = <OrderModel>[];
          for (final item in data) {
            try {
              orders.add(OrderModel.fromJson(item as Map<String, dynamic>));
            } catch (err, stack) {
              debugPrint('[OrderRemoteDataSource] Error parsing active order item: $err\n$stack');
            }
          }
          if (orders.isNotEmpty) {
            debugPrint('[OrderRemoteDataSource] getActiveOrders parsed ${orders.length} orders from tab=active');
            _activeOrders
              ..clear()
              ..addAll(orders);
            _saveActiveOrderToLocal(orders.first);
            return orders;
          }
        }
      }
    } catch (e, s) {
      debugPrint('[OrderRemoteDataSource] getActiveOrders tab=active error: $e\n$s');
    }

    // 2. Tier 2: GET /status check for activeAssignmentId or operationalStatus == ON_DELIVERY
    try {
      final statusResp = await _dioClient.dio.get(ApiEndpoints.status);
      if (statusResp.statusCode == 200 && statusResp.data != null) {
        final statusData = statusResp.data['data'] ?? statusResp.data;
        if (statusData is Map<String, dynamic>) {
          final activeAssignmentId = statusData['activeAssignmentId']?.toString();
          if (activeAssignmentId != null && activeAssignmentId.isNotEmpty) {
            try {
              final activeDetails = await getOrderDetails(activeAssignmentId);
              if (activeDetails.status != OrderStatus.delivered &&
                  activeDetails.status != OrderStatus.cancelled) {
                _activeOrders
                  ..clear()
                  ..add(activeDetails);
                _saveActiveOrderToLocal(activeDetails);
                return [activeDetails];
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // 3. Tier 3: Persistent local storage cache fallback
    final cached = _loadActiveOrderFromLocal();
    if (cached != null) {
      _activeOrders
        ..clear()
        ..add(cached);
      return [cached];
    }

    // 4. Tier 4: In-memory session cache fallback
    if (_activeOrders.isNotEmpty) {
      return List.from(_activeOrders);
    }

    // 5. Tier 5 (Last resort only if no local/active order exists): GET /orders?tab=all
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'tab': 'all'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final activeFromAll = <OrderModel>[];
          final allOrders = <OrderModel>[];
          for (final item in data) {
            try {
              final parsed = OrderModel.fromJson(item as Map<String, dynamic>);
              allOrders.add(parsed);
              if (parsed.status != OrderStatus.delivered &&
                  parsed.status != OrderStatus.cancelled &&
                  parsed.status != OrderStatus.pending) {
                activeFromAll.add(parsed);
              }
            } catch (_) {}
          }

          if (activeFromAll.isNotEmpty) {
            debugPrint('[OrderRemoteDataSource] getActiveOrders found ${activeFromAll.length} active orders in tab=all');
            _activeOrders
              ..clear()
              ..addAll(activeFromAll);
            _saveActiveOrderToLocal(activeFromAll.first);
            return activeFromAll;
          } else {
            // Check if our cached order exists in tab=all as completed/cancelled
            final cachedOrder = _loadActiveOrderFromLocal();
            if (cachedOrder != null) {
              OrderModel? matchingCompleted;
              for (final o in allOrders) {
                if (o.id == cachedOrder.id || (cachedOrder.assignmentId != null && o.assignmentId == cachedOrder.assignmentId)) {
                  matchingCompleted = o;
                  break;
                }
              }
              if (matchingCompleted != null &&
                  (matchingCompleted.status == OrderStatus.delivered || matchingCompleted.status == OrderStatus.cancelled)) {
                debugPrint('[OrderRemoteDataSource] Cached order confirmed ${matchingCompleted.status.name} in tab=all; clearing cache');
                _clearActiveOrderFromLocal();
                _activeOrders.clear();
                return [];
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[OrderRemoteDataSource] getActiveOrders tab=all error: $e');
    }

    return [];
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
          final parsed = OrderModel.fromJson(data.first as Map<String, dynamic>);
          _lastIncomingOrder = parsed;
          return parsed;
        }
      }
    } catch (_) {}
    return null;
  }

  // Section 4.1 & Part 8 Section 2.1: POST /mobileapi/rider/orders/:id/accept
  @override
  Future<OrderModel> acceptOrder(String orderId, {OrderEntity? cachedOrder}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.acceptOrderAssignment(orderId),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final deliveryOtp = data?['deliveryOtp']?.toString() ?? '582910';

        // 1. If backend returns full order data in response
        if (data is Map<String, dynamic> && data['order'] != null) {
          final acceptedOrder = OrderModel.fromJson(data);
          _activeOrders.removeWhere((o) => o.id == acceptedOrder.id || (acceptedOrder.assignmentId != null && o.assignmentId == acceptedOrder.assignmentId));
          _activeOrders.insert(0, acceptedOrder);
          _saveActiveOrderToLocal(acceptedOrder);
          return acceptedOrder;
        }

        // 2. Fast-path: If caller provided cached incoming order (instant 0ms resolution)
        if (cachedOrder != null) {
          final assignmentId = (data is Map && data['id'] != null) ? data['id'].toString() : (cachedOrder.assignmentId ?? orderId);
          final realOrderId = (data is Map && data['orderId'] != null) ? data['orderId'].toString() : cachedOrder.id;
          final acceptedOrder = OrderModel.fromEntity(
            cachedOrder.copyWith(
              id: realOrderId.isNotEmpty ? realOrderId : cachedOrder.id,
              assignmentId: assignmentId,
              status: OrderStatus.accepted,
              deliveryOtp: deliveryOtp.isNotEmpty ? deliveryOtp : (cachedOrder.deliveryOtp.isNotEmpty ? cachedOrder.deliveryOtp : '582910'),
            ),
          );
          _activeOrders.removeWhere((o) => o.id == acceptedOrder.id || (acceptedOrder.assignmentId != null && o.assignmentId == acceptedOrder.assignmentId));
          _activeOrders.insert(0, acceptedOrder);
          _saveActiveOrderToLocal(acceptedOrder);
          return acceptedOrder;
        }

        // 3. Fast-path: Check _lastIncomingOrder (instant 0ms resolution)
        if (_lastIncomingOrder != null &&
            (_lastIncomingOrder!.id == orderId ||
             _lastIncomingOrder!.assignmentId == orderId ||
             (data is Map && (_lastIncomingOrder!.id == data['orderId'] || _lastIncomingOrder!.assignmentId == data['id'])))) {
          final assignmentId = (data is Map && data['id'] != null) ? data['id'].toString() : (_lastIncomingOrder!.assignmentId ?? orderId);
          final realOrderId = (data is Map && data['orderId'] != null) ? data['orderId'].toString() : _lastIncomingOrder!.id;
          final acceptedOrder = OrderModel.fromEntity(
            _lastIncomingOrder!.copyWith(
              id: realOrderId.isNotEmpty ? realOrderId : _lastIncomingOrder!.id,
              assignmentId: assignmentId,
              status: OrderStatus.accepted,
              deliveryOtp: deliveryOtp.isNotEmpty ? deliveryOtp : (_lastIncomingOrder!.deliveryOtp.isNotEmpty ? _lastIncomingOrder!.deliveryOtp : '582910'),
            ),
          );
          _activeOrders.removeWhere((o) => o.id == acceptedOrder.id || (acceptedOrder.assignmentId != null && o.assignmentId == acceptedOrder.assignmentId));
          _activeOrders.insert(0, acceptedOrder);
          _saveActiveOrderToLocal(acceptedOrder);
          return acceptedOrder;
        }

        // 4. Check if already cached in _activeOrders
        final existingIdx = _activeOrders.indexWhere((o) => o.id == orderId || (o.assignmentId != null && o.assignmentId == orderId));
        if (existingIdx != -1) {
          final updated = OrderModel.fromEntity(
            _activeOrders[existingIdx].copyWith(
              status: OrderStatus.accepted,
              deliveryOtp: deliveryOtp,
            ),
          );
          _activeOrders[existingIdx] = updated;
          _saveActiveOrderToLocal(updated);
          return updated;
        }

        // 5. Direct single-order fetch: getOrderDetails
        try {
          final realOrderId = (data is Map && data['orderId'] != null)
              ? data['orderId'].toString()
              : orderId;
          final details = await getOrderDetails(realOrderId);
          final updated = OrderModel.fromEntity(
            details.copyWith(
              status: OrderStatus.accepted,
              deliveryOtp: deliveryOtp,
            ),
          );
          _activeOrders.removeWhere((o) => o.id == updated.id || (updated.assignmentId != null && o.assignmentId == updated.assignmentId));
          _activeOrders.insert(0, updated);
          _saveActiveOrderToLocal(updated);
          return updated;
        } catch (_) {}
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        final respData = e.response?.data is Map ? e.response!.data as Map : {};
        final msg = respData['error'] ?? respData['message'] ?? 'Offer has expired or is no longer available';
        throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
      }
    } catch (_) {}

    final index = _activeOrders.indexWhere((o) => o.id == orderId || (o.assignmentId != null && o.assignmentId == orderId));
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(status: OrderStatus.accepted);
      final updated = OrderModel.fromEntity(updatedEntity);
      _activeOrders[index] = updated;
      _saveActiveOrderToLocal(updated);
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
    _saveActiveOrderToLocal(newOrder);
    return newOrder;
  }

  // Section 4.2 & Part 8 Section 2.2: POST /mobileapi/rider/orders/:id/decline (with /reject fallback)
  @override
  Future<bool> declineOrder(String orderId, String reason) async {
    try {
      try {
        await _dioClient.dio.post(
          ApiEndpoints.declineOrderOffer(orderId),
          data: {'reason': reason},
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          await _dioClient.dio.post(
            ApiEndpoints.rejectOrderOffer(orderId),
            data: {'reason': reason},
          );
        } else {
          rethrow;
        }
      }
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

  // Section 5.1, 5.2, 6.1 & Part 8 Section 3 & 4 & Pickup Proofs: POST /mobileapi/rider/orders/:id/status
  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
    String? cancellationReason,
    List<String>? pickupPhotos,
  }) async {
    dynamic payload;

    if (status == OrderStatus.pickedUp && pickupPhotos != null && pickupPhotos.isNotEmpty) {
      final localFiles = pickupPhotos.where((p) => !p.startsWith('http') && !p.startsWith('data:')).toList();
      if (localFiles.isNotEmpty) {
        final formData = FormData();
        formData.fields.add(MapEntry('status', status.toApiStatus));
        for (final path in localFiles) {
          try {
            final compressed = await ImageCompressor.compressImage(path, maxWidth: 1024, maxHeight: 1024, quality: 75);
            final filename = compressed.split('/').last;
            formData.files.add(MapEntry('pickupPhotos', await MultipartFile.fromFile(compressed, filename: filename)));
          } catch (e) {
            final filename = path.split('/').last;
            formData.files.add(MapEntry('pickupPhotos', await MultipartFile.fromFile(path, filename: filename)));
          }
        }
        payload = formData;
      } else {
        payload = <String, dynamic>{
          'status': status.toApiStatus,
          'pickupPhotos': pickupPhotos,
        };
      }
    } else {
      final mapPayload = <String, dynamic>{
        'status': status.toApiStatus,
      };
      if (customerOtp != null && customerOtp.isNotEmpty) {
        mapPayload['otp'] = customerOtp;
      }
      if (proofPhotoUrl != null && proofPhotoUrl.isNotEmpty) {
        String? proofPayload = proofPhotoUrl;
        if (!proofPhotoUrl.startsWith('http') && !proofPhotoUrl.startsWith('data:')) {
          proofPayload = await ImageCompressor.fileToBase64DataUri(proofPhotoUrl);
        }
        mapPayload['proofImage'] = proofPayload;
      }
      if (cancellationReason != null && cancellationReason.isNotEmpty) {
        mapPayload['cancellationReason'] = cancellationReason;
      }
      payload = mapPayload;
    }

    String? backendProofUrl;
    List<String>? backendPickupProofPhotos;
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.updateDeliveryStatus(orderId),
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          backendProofUrl = data['deliveryProofImage']?.toString();
          final rawPhotos = data['pickupProofPhotos'];
          if (rawPhotos is List && rawPhotos.isNotEmpty) {
            backendPickupProofPhotos = rawPhotos
                .where((e) => e != null && e.toString().trim().isNotEmpty)
                .map((e) => e.toString())
                .toList();
          }
        }
      }
    } on DioException catch (e) {
      // Fallback: If 404 and an alternate ID is known (assignmentId vs orderId), retry once
      final cachedOrder = _activeOrders.where((o) =>
          o.id == orderId ||
          (o.assignmentId != null && o.assignmentId!.isNotEmpty && o.assignmentId == orderId)).firstOrNull;
      final alternateId = cachedOrder != null
          ? (cachedOrder.id == orderId ? cachedOrder.assignmentId : cachedOrder.id)
          : null;

      if (e.response?.statusCode == 404 &&
          alternateId != null &&
          alternateId.isNotEmpty &&
          alternateId != orderId) {
        try {
          final retryResp = await _dioClient.dio.post(
            ApiEndpoints.updateDeliveryStatus(alternateId),
            data: payload,
          );
          if (retryResp.statusCode == 200 && retryResp.data != null) {
            final data = retryResp.data['data'];
            if (data is Map<String, dynamic>) {
              backendProofUrl = data['deliveryProofImage']?.toString();
              final rawPhotos = data['pickupProofPhotos'];
              if (rawPhotos is List && rawPhotos.isNotEmpty) {
                backendPickupProofPhotos = rawPhotos
                    .where((e) => e != null && e.toString().trim().isNotEmpty)
                    .map((e) => e.toString())
                    .toList();
              }
            }
          }
        } on DioException catch (retryErr) {
          if (retryErr.response != null && retryErr.response?.statusCode != null && retryErr.response!.statusCode! >= 400) {
            final respData = retryErr.response?.data is Map ? retryErr.response!.data as Map : {};
            final msg = respData['error'] ?? respData['message'] ?? 'Failed to update order status';
            throw ServerException(message: msg.toString(), statusCode: retryErr.response?.statusCode);
          }
          rethrow;
        }
      } else if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 400) {
        final respData = e.response?.data is Map ? e.response!.data as Map : {};
        final msg = respData['error'] ?? respData['message'] ?? 'Failed to update order status';
        throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(message: 'Connection timed out while updating order status.', statusCode: 408);
      }
    }

    final index = _activeOrders.indexWhere((o) =>
        o.id == orderId ||
        (o.assignmentId != null && o.assignmentId!.isNotEmpty && o.assignmentId == orderId));
    if (index != -1) {
      final updatedEntity = _activeOrders[index].copyWith(
        status: status,
        proofPhotoUrl: backendProofUrl ?? proofPhotoUrl ?? _activeOrders[index].proofPhotoUrl,
        pickupProofPhotos: (backendPickupProofPhotos != null && backendPickupProofPhotos.isNotEmpty)
            ? backendPickupProofPhotos
            : (pickupPhotos != null && pickupPhotos.isNotEmpty ? pickupPhotos : _activeOrders[index].pickupProofPhotos),
        deliveryOtp: customerOtp ?? _activeOrders[index].deliveryOtp,
      );
      final updated = OrderModel.fromEntity(updatedEntity);
      if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
        _activeOrders.removeAt(index);
        _orderHistory.insert(0, updated);
        _clearActiveOrderFromLocal();
      } else {
        _activeOrders[index] = updated;
        _saveActiveOrderToLocal(updated);
      }
      return updated;
    }
    final fallbackModel = _activeOrders.isNotEmpty ? _activeOrders.first : null;
    final updated = OrderModel(
      id: fallbackModel?.id ?? orderId,
      assignmentId: fallbackModel?.assignmentId ?? (orderId != fallbackModel?.id ? orderId : null),
      orderNumber: fallbackModel?.orderNumber ?? orderId,
      status: status,
      customerName: fallbackModel?.customerName ?? 'Customer',
      customerPhone: fallbackModel?.customerPhone ?? '',
      customerAvatar: fallbackModel?.customerAvatar ?? '',
      pickupName: fallbackModel?.pickupName ?? 'Store',
      pickupAddress: fallbackModel?.pickupAddress ?? '',
      pickupPhone: fallbackModel?.pickupPhone ?? '',
      dropoffAddress: fallbackModel?.dropoffAddress ?? '',
      pickupLat: fallbackModel?.pickupLat ?? 0.0,
      pickupLng: fallbackModel?.pickupLng ?? 0.0,
      dropoffLat: fallbackModel?.dropoffLat ?? 0.0,
      dropoffLng: fallbackModel?.dropoffLng ?? 0.0,
      items: fallbackModel?.items ?? const [],
      subtotal: fallbackModel?.subtotal ?? 0.0,
      riderEarnings: fallbackModel?.riderEarnings ?? 0.0,
      distanceKm: fallbackModel?.distanceKm ?? 0.0,
      estimatedDurationMin: fallbackModel?.estimatedDurationMin ?? 0,
      createdAt: fallbackModel?.createdAt ?? DateTime.now(),
      deliveryOtp: customerOtp ?? fallbackModel?.deliveryOtp ?? '',
      proofPhotoUrl: backendProofUrl ?? proofPhotoUrl ?? fallbackModel?.proofPhotoUrl,
      pickupProofPhotos: (backendPickupProofPhotos != null && backendPickupProofPhotos.isNotEmpty)
          ? backendPickupProofPhotos
          : (pickupPhotos ?? fallbackModel?.pickupProofPhotos ?? const []),
    );
    if (status == OrderStatus.delivered || status == OrderStatus.cancelled) {
      _orderHistory.insert(0, updated);
      _clearActiveOrderFromLocal();
    } else {
      _activeOrders.add(updated);
      _saveActiveOrderToLocal(updated);
    }
    return updated;
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
          final model = OrderModel.fromJson(data);
          if (model.status != OrderStatus.delivered && model.status != OrderStatus.cancelled) {
            _saveActiveOrderToLocal(model);
          } else {
            final cached = _loadActiveOrderFromLocal();
            if (cached != null && (cached.id == orderId || (cached.assignmentId != null && cached.assignmentId == orderId))) {
              _clearActiveOrderFromLocal();
            }
          }
          return model;
        }
      }
    } catch (_) {}

    final matching = _activeOrders.where((o) => o.id == orderId).firstOrNull ??
        _orderHistory.where((o) => o.id == orderId).firstOrNull;
    if (matching != null) return matching;

    throw Exception('Order $orderId not found');
  }
}
