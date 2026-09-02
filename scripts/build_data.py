import os

files = {}

# Models
files['lib/data/models/vehicle_model.dart'] = '''import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.type,
    required super.model,
    required super.licensePlate,
    required super.color,
    required super.year,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      type: json['type'] as String? ?? 'Motorcycle',
      model: json['model'] as String? ?? 'Vehicle',
      licensePlate: json['licensePlate'] as String? ?? 'N/A',
      color: json['color'] as String? ?? 'Black',
      year: json['year']?.toString() ?? '2024',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'year': year,
    };
  }

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      type: entity.type,
      model: entity.model,
      licensePlate: entity.licensePlate,
      color: entity.color,
      year: entity.year,
    );
  }
}
'''

files['lib/data/models/rider_model.dart'] = '''import '../../domain/entities/rider_entity.dart';
import 'vehicle_model.dart';

class RiderModel extends RiderEntity {
  const RiderModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.avatar,
    required super.rating,
    required super.totalTrips,
    required super.isOnline,
    required super.walletBalance,
    required super.approvalStatus,
    super.vehicle,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      approvalStatus: json['approvalStatus'] as String? ?? 'approved',
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'rating': rating,
      'totalTrips': totalTrips,
      'isOnline': isOnline,
      'walletBalance': walletBalance,
      'approvalStatus': approvalStatus,
      'vehicle': vehicle != null ? VehicleModel.fromEntity(vehicle!).toJson() : null,
    };
  }

  factory RiderModel.fromEntity(RiderEntity entity) {
    return RiderModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      avatar: entity.avatar,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
      isOnline: entity.isOnline,
      walletBalance: entity.walletBalance,
      approvalStatus: entity.approvalStatus,
      vehicle: entity.vehicle,
    );
  }
}
'''

files['lib/data/models/order_item_model.dart'] = '''import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.name,
    required super.quantity,
    super.notes = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      name: entity.name,
      quantity: entity.quantity,
      notes: entity.notes,
    );
  }
}
'''

files['lib/data/models/order_model.dart'] = '''import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.customerName,
    required super.customerPhone,
    required super.customerAvatar,
    required super.pickupName,
    required super.pickupAddress,
    required super.pickupPhone,
    required super.dropoffAddress,
    required super.pickupLat,
    required super.pickupLng,
    required super.dropoffLat,
    required super.dropoffLng,
    required super.items,
    required super.subtotal,
    required super.riderEarnings,
    required super.distanceKm,
    required super.estimatedDurationMin,
    required super.createdAt,
    super.notes = '',
    super.deliveryOtp = '',
    super.proofPhotoUrl,
  });

  static OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'arrived_at_pickup':
        return OrderStatus.arrivedAtPickup;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'in_transit':
        return OrderStatus.inTransit;
      case 'arrived_at_dropoff':
        return OrderStatus.arrivedAtDropoff;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.arrivedAtPickup:
        return 'arrived_at_pickup';
      case OrderStatus.pickedUp:
        return 'picked_up';
      case OrderStatus.inTransit:
        return 'in_transit';
      case OrderStatus.arrivedAtDropoff:
        return 'arrived_at_dropoff';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.pending:
        return 'pending';
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      customerName: json['customerName'] as String? ?? 'Customer',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerAvatar: json['customerAvatar'] as String? ?? '',
      pickupName: json['pickupName'] as String? ?? 'Restaurant / Store',
      pickupAddress: json['pickupAddress'] as String? ?? '',
      pickupPhone: json['pickupPhone'] as String? ?? '',
      dropoffAddress: json['dropoffAddress'] as String? ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble() ?? 40.7128,
      pickupLng: (json['pickupLng'] as num?)?.toDouble() ?? -74.0060,
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble() ?? 40.7306,
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble() ?? -73.9352,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      riderEarnings: (json['riderEarnings'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMin: (json['estimatedDurationMin'] as num?)?.toInt() ?? 15,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String? ?? '',
      deliveryOtp: json['deliveryOtp'] as String? ?? '',
      proofPhotoUrl: json['proofPhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'status': _statusToString(status),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAvatar': customerAvatar,
      'pickupName': pickupName,
      'pickupAddress': pickupAddress,
      'pickupPhone': pickupPhone,
      'dropoffAddress': dropoffAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'items': items
          .map((e) => OrderItemModel.fromEntity(e).toJson())
          .toList(),
      'subtotal': subtotal,
      'riderEarnings': riderEarnings,
      'distanceKm': distanceKm,
      'estimatedDurationMin': estimatedDurationMin,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'deliveryOtp': deliveryOtp,
      'proofPhotoUrl': proofPhotoUrl,
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      status: entity.status,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      customerAvatar: entity.customerAvatar,
      pickupName: entity.pickupName,
      pickupAddress: entity.pickupAddress,
      pickupPhone: entity.pickupPhone,
      dropoffAddress: entity.dropoffAddress,
      pickupLat: entity.pickupLat,
      pickupLng: entity.pickupLng,
      dropoffLat: entity.dropoffLat,
      dropoffLng: entity.dropoffLng,
      items: entity.items,
      subtotal: entity.subtotal,
      riderEarnings: entity.riderEarnings,
      distanceKm: entity.distanceKm,
      estimatedDurationMin: entity.estimatedDurationMin,
      createdAt: entity.createdAt,
      notes: entity.notes,
      deliveryOtp: entity.deliveryOtp,
      proofPhotoUrl: entity.proofPhotoUrl,
    );
  }
}
'''

files['lib/data/models/transaction_model.dart'] = '''import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.orderNumber,
    required super.amount,
    required super.tip,
    required super.date,
    required super.type,
    required super.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: json['type'] as String? ?? 'trip_earnings',
      status: json['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'amount': amount,
      'tip': tip,
      'date': date.toIso8601String(),
      'type': type,
      'status': status,
    };
  }
}
'''

files['lib/data/models/earnings_model.dart'] = '''import '../../domain/entities/earnings_entity.dart';
import 'transaction_model.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.todayEarnings,
    required super.weeklyEarnings,
    required super.monthlyEarnings,
    required super.availablePayout,
    required super.completedTrips,
    required super.basePay,
    required super.tips,
    required super.surgeBonuses,
    required super.dailyData,
    required super.recentTransactions,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyData'] as List<dynamic>?)
            ?.map((e) => DailyChartData(
                  day: e['day'] as String? ?? '',
                  amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList() ??
        [];

    final txList = (json['recentTransactions'] as List<dynamic>?)
            ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return EarningsModel(
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (json['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      availablePayout: (json['availablePayout'] as num?)?.toDouble() ?? 0.0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      basePay: (json['basePay'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      surgeBonuses: (json['surgeBonuses'] as num?)?.toDouble() ?? 0.0,
      dailyData: dailyList,
      recentTransactions: txList,
    );
  }
}
'''

files['lib/data/models/document_model.dart'] = '''import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.type,
    required super.title,
    required super.documentNumber,
    required super.expiryDate,
    required super.status,
    super.fileUrl,
  });

  static DocumentStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'verified':
        return DocumentStatus.verified;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? 'Document',
      documentNumber: json['documentNumber'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      fileUrl: json['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'documentNumber': documentNumber,
      'expiryDate': expiryDate,
      'status': status.name,
      'fileUrl': fileUrl,
    };
  }
}
'''

# Local & Remote Data Sources
files['lib/data/datasources/auth_local_datasource.dart'] = '''import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/rider_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  String? getToken();
  Future<void> saveRefreshToken(String refreshToken);
  String? getRefreshToken();
  Future<void> saveRider(RiderModel rider);
  RiderModel? getSavedRider();
  Future<void> clearAuth();
  bool getIsOnline();
  Future<void> setIsOnline(bool isOnline);
  bool getIsDarkMode();
  Future<void> setIsDarkMode(bool isDark);
  Future<void> queueOfflineAction(Map<String, dynamic> action);
  List<Map<String, dynamic>> getOfflineQueue();
  Future<void> clearOfflineQueue();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(AppConstants.tokenKey, token);
  }

  @override
  String? getToken() {
    return _storage.read<String>(AppConstants.tokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  @override
  String? getRefreshToken() {
    return _storage.read<String>(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveRider(RiderModel rider) async {
    await _storage.write(AppConstants.riderProfileKey, jsonEncode(rider.toJson()));
  }

  @override
  RiderModel? getSavedRider() {
    final raw = _storage.read<String>(AppConstants.riderProfileKey);
    if (raw == null) return null;
    try {
      return RiderModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    await _storage.remove(AppConstants.tokenKey);
    await _storage.remove(AppConstants.refreshTokenKey);
    await _storage.remove(AppConstants.riderProfileKey);
  }

  @override
  bool getIsOnline() {
    return _storage.read<bool>(AppConstants.isOnlineKey) ?? false;
  }

  @override
  Future<void> setIsOnline(bool isOnline) async {
    await _storage.write(AppConstants.isOnlineKey, isOnline);
  }

  @override
  bool getIsDarkMode() {
    return _storage.read<bool>(AppConstants.isDarkModeKey) ?? false;
  }

  @override
  Future<void> setIsDarkMode(bool isDark) async {
    await _storage.write(AppConstants.isDarkModeKey, isDark);
  }

  @override
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    final list = getOfflineQueue();
    list.add(action);
    await _storage.write(AppConstants.offlineQueueKey, jsonEncode(list));
  }

  @override
  List<Map<String, dynamic>> getOfflineQueue() {
    final raw = _storage.read<String>(AppConstants.offlineQueueKey);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> clearOfflineQueue() async {
    await _storage.remove(AppConstants.offlineQueueKey);
  }
}
'''

files['lib/data/datasources/auth_remote_datasource.dart'] = '''import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/rider_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<RiderModel> register(Map<String, dynamic> riderData);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> login(String phone) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {'phone': phone},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to send verification code',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        final rider = RiderModel.fromJson(data['rider'] as Map<String, dynamic>);
        return {
          'token': token,
          'refreshToken': refreshToken,
          'rider': rider,
        };
      }
      throw const ServerException(message: 'Invalid response from server');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to verify OTP',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<RiderModel> register(Map<String, dynamic> riderData) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: riderData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return RiderModel.fromJson(response.data['rider'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Registration failed');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return response.data['token'] as String;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Session expired',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }
}
'''

files['lib/data/datasources/order_remote_datasource.dart'] = '''import 'package:dio/dio.dart';
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
'''

files['lib/data/datasources/dashboard_remote_datasource.dart'] = '''import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';

abstract class DashboardRemoteDataSource {
  Future<bool> toggleOnline(bool isOnline);
  Future<Map<String, dynamic>> getSummary();
  Future<void> updateLocation(double lat, double lng);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient _dioClient;

  DashboardRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> toggleOnline(bool isOnline) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.toggleOnline,
        data: {'isOnline': isOnline},
      );
      return response.data?['isOnline'] ?? isOnline;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to toggle status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.dashboardSummary);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to get summary',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.updateLocation,
        data: {'lat': lat, 'lng': lng, 'timestamp': DateTime.now().toIso8601String()},
      );
    } catch (_) {}
  }
}
'''

files['lib/data/datasources/earnings_remote_datasource.dart'] = '''import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/earnings_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getEarnings(String period);
  Future<bool> requestPayout(double amount, String paymentMethod);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final DioClient _dioClient;

  EarningsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<EarningsModel> getEarnings(String period) async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.earningsBreakdown,
        queryParameters: {'period': period},
      );
      if (response.statusCode == 200 && response.data != null) {
        return EarningsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to load earnings');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load earnings',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> requestPayout(double amount, String paymentMethod) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.requestPayout,
        data: {'amount': amount, 'paymentMethod': paymentMethod},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to process payout',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
'''

files['lib/data/datasources/profile_remote_datasource.dart'] = '''import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/rider_model.dart';
import '../models/document_model.dart';

abstract class ProfileRemoteDataSource {
  Future<RiderModel> getProfile();
  Future<RiderModel> updateProfile(RiderModel rider);
  Future<List<DocumentModel>> getDocuments();
  Future<DocumentModel> uploadDocument(String docType, String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RiderModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.riderProfile);
      return RiderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      // Mock fallback
      return const RiderModel(
        id: 'rider_9082',
        name: 'Alex Johnson',
        phone: '+1 555 234 5678',
        email: 'alex.rider@meeem.com',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        rating: 4.92,
        totalTrips: 1420,
        isOnline: true,
        walletBalance: 184.50,
        approvalStatus: 'approved',
      );
    }
  }

  @override
  Future<RiderModel> updateProfile(RiderModel rider) async {
    try {
      final response = await _dioClient.dio.put(
        ApiEndpoints.updateProfile,
        data: rider.toJson(),
      );
      return RiderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to update profile',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.getDocuments);
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw const ServerException(message: 'Failed to load documents');
    }
  }

  @override
  Future<DocumentModel> uploadDocument(String docType, String filePath) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.uploadDocument,
        data: {'docType': docType, 'filePath': filePath},
      );
      return DocumentModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return DocumentModel(
        type: docType,
        title: 'Uploaded Document',
        documentNumber: 'DOC-NEW-2026',
        expiryDate: '2028-12-31',
        status: DocumentStatus.pending,
      );
    }
  }
}
'''

# Repository Implementations
files['lib/data/repositories/auth_repository_impl.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rider_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/rider_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> login(String phone) async {
    try {
      final result = await remoteDataSource.login(phone);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp) async {
    try {
      final data = await remoteDataSource.verifyOtp(phone, otp);
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final rider = data['rider'] as RiderModel;

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveRider(rider);
      await localDataSource.setIsOnline(rider.isOnline);

      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData) async {
    try {
      final rider = await remoteDataSource.register(riderData);
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity?>> getSavedRider() async {
    try {
      final rider = localDataSource.getSavedRider();
      return Right(rider);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuth();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearAuth();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final currentRefresh = localDataSource.getRefreshToken();
      if (currentRefresh == null) {
        return const Left(AuthFailure(message: 'No refresh token stored'));
      }
      final newToken = await remoteDataSource.refreshToken(currentRefresh);
      await localDataSource.saveToken(newToken);
      return Right(newToken);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
'''

files['lib/data/repositories/order_repository_impl.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getActiveOrders() async {
    try {
      final orders = await remoteDataSource.getActiveOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity?>> getIncomingOrder() async {
    try {
      final order = await remoteDataSource.getIncomingOrder();
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> acceptOrder(String orderId) async {
    try {
      final order = await remoteDataSource.acceptOrder(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> declineOrder(String orderId, String reason) async {
    try {
      final result = await remoteDataSource.declineOrder(orderId, reason);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  }) async {
    try {
      final order = await remoteDataSource.updateOrderStatus(
        orderId,
        status,
        proofPhotoUrl: proofPhotoUrl,
        customerOtp: customerOtp,
      );
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory({String? statusFilter}) async {
    try {
      final history = await remoteDataSource.getOrderHistory(statusFilter: statusFilter);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderDetails(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
'''

files['lib/data/repositories/dashboard_repository_impl.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> toggleOnlineStatus(bool isOnline) async {
    try {
      final status = await remoteDataSource.toggleOnline(isOnline);
      await localDataSource.setIsOnline(status);
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary() async {
    try {
      final summary = await remoteDataSource.getSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLiveLocation(double lat, double lng) async {
    try {
      await remoteDataSource.updateLocation(lat, lng);
      return const Right(null);
    } catch (_) {
      return const Right(null);
    }
  }
}
'''

files['lib/data/repositories/earnings_repository_impl.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/earnings_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EarningsEntity>> getEarningsBreakdown(String period) async {
    try {
      final earnings = await remoteDataSource.getEarnings(period);
      return Right(earnings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPayout(double amount, String paymentMethod) async {
    try {
      final result = await remoteDataSource.requestPayout(amount, paymentMethod);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
'''

files['lib/data/repositories/profile_repository_impl.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rider_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/rider_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, RiderEntity>> getProfile() async {
    try {
      final rider = await remoteDataSource.getProfile();
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> updateProfile(RiderEntity rider) async {
    try {
      final updated = await remoteDataSource.updateProfile(RiderModel.fromEntity(rider));
      await localDataSource.saveRider(updated);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments() async {
    try {
      final docs = await remoteDataSource.getDocuments();
      return Right(docs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(String docType, String filePath) async {
    try {
      final doc = await remoteDataSource.uploadDocument(docType, filePath);
      return Right(doc);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

