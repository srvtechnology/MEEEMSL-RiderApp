import os

files = {}

# Entities
files['lib/domain/entities/vehicle_entity.dart'] = '''import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String type;
  final String model;
  final String licensePlate;
  final String color;
  final String year;

  const VehicleEntity({
    required this.type,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
  });

  @override
  List<Object?> get props => [type, model, licensePlate, color, year];
}
'''

files['lib/domain/entities/rider_entity.dart'] = '''import 'package:equatable/equatable.dart';
import 'vehicle_entity.dart';

class RiderEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatar;
  final double rating;
  final int totalTrips;
  final bool isOnline;
  final double walletBalance;
  final String approvalStatus; // pending, approved, rejected
  final VehicleEntity? vehicle;

  const RiderEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatar,
    required this.rating,
    required this.totalTrips,
    required this.isOnline,
    required this.walletBalance,
    required this.approvalStatus,
    this.vehicle,
  });

  RiderEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    double? rating,
    int? totalTrips,
    bool? isOnline,
    double? walletBalance,
    String? approvalStatus,
    VehicleEntity? vehicle,
  }) {
    return RiderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      isOnline: isOnline ?? this.isOnline,
      walletBalance: walletBalance ?? this.walletBalance,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      vehicle: vehicle ?? this.vehicle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatar,
        rating,
        totalTrips,
        isOnline,
        walletBalance,
        approvalStatus,
        vehicle,
      ];
}
'''

files['lib/domain/entities/order_item_entity.dart'] = '''import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String name;
  final int quantity;
  final String notes;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    this.notes = '',
  });

  @override
  List<Object?> get props => [name, quantity, notes];
}
'''

files['lib/domain/entities/order_entity.dart'] = '''import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

enum OrderStatus {
  pending,
  accepted,
  arrivedAtPickup,
  pickedUp,
  inTransit,
  arrivedAtDropoff,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Heading to Pickup';
      case OrderStatus.arrivedAtPickup:
        return 'Arrived at Store';
      case OrderStatus.pickedUp:
        return 'Order Picked Up';
      case OrderStatus.inTransit:
        return 'On the Way';
      case OrderStatus.arrivedAtDropoff:
        return 'Arrived at Customer';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get nextStepActionTitle {
    switch (this) {
      case OrderStatus.accepted:
        return 'Swipe when Arrived at Store';
      case OrderStatus.arrivedAtPickup:
        return 'Swipe to Confirm Pickup';
      case OrderStatus.pickedUp:
        return 'Swipe to Start Delivery';
      case OrderStatus.inTransit:
        return 'Swipe when Arrived at Customer';
      case OrderStatus.arrivedAtDropoff:
        return 'Swipe to Complete Delivery';
      default:
        return 'Confirm Step';
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String customerAvatar;
  final String pickupName;
  final String pickupAddress;
  final String pickupPhone;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double riderEarnings;
  final double distanceKm;
  final int estimatedDurationMin;
  final DateTime createdAt;
  final String notes;
  final String deliveryOtp;
  final String? proofPhotoUrl;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerAvatar,
    required this.pickupName,
    required this.pickupAddress,
    required this.pickupPhone,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.items,
    required this.subtotal,
    required this.riderEarnings,
    required this.distanceKm,
    required this.estimatedDurationMin,
    required this.createdAt,
    this.notes = '',
    this.deliveryOtp = '',
    this.proofPhotoUrl,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    String? customerAvatar,
    String? pickupName,
    String? pickupAddress,
    String? pickupPhone,
    String? dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? riderEarnings,
    double? distanceKm,
    int? estimatedDurationMin,
    DateTime? createdAt,
    String? notes,
    String? deliveryOtp,
    String? proofPhotoUrl,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      pickupName: pickupName ?? this.pickupName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      riderEarnings: riderEarnings ?? this.riderEarnings,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMin: estimatedDurationMin ?? this.estimatedDurationMin,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        customerName,
        pickupName,
        pickupAddress,
        dropoffAddress,
        riderEarnings,
        distanceKm,
      ];
}
'''

files['lib/domain/entities/transaction_entity.dart'] = '''import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String orderNumber;
  final double amount;
  final double tip;
  final DateTime date;
  final String type; // trip_earnings, withdrawal, bonus
  final String status; // completed, pending, failed

  const TransactionEntity({
    required this.id,
    required this.orderNumber,
    required this.amount,
    required this.tip,
    required this.date,
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [id, orderNumber, amount, tip, date, type, status];
}
'''

files['lib/domain/entities/earnings_entity.dart'] = '''import 'package:equatable/equatable.dart';
import 'transaction_entity.dart';

class DailyChartData extends Equatable {
  final String day;
  final double amount;

  const DailyChartData({required this.day, required this.amount});

  @override
  List<Object?> get props => [day, amount];
}

class EarningsEntity extends Equatable {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double availablePayout;
  final int completedTrips;
  final double basePay;
  final double tips;
  final double surgeBonuses;
  final List<DailyChartData> dailyData;
  final List<TransactionEntity> recentTransactions;

  const EarningsEntity({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.availablePayout,
    required this.completedTrips,
    required this.basePay,
    required this.tips,
    required this.surgeBonuses,
    required this.dailyData,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        todayEarnings,
        weeklyEarnings,
        monthlyEarnings,
        availablePayout,
        completedTrips,
        basePay,
        tips,
        surgeBonuses,
      ];
}
'''

files['lib/domain/entities/document_entity.dart'] = '''import 'package:equatable/equatable.dart';

enum DocumentStatus { verified, pending, rejected }

class DocumentEntity extends Equatable {
  final String type;
  final String title;
  final String documentNumber;
  final String expiryDate;
  final DocumentStatus status;
  final String? fileUrl;

  const DocumentEntity({
    required this.type,
    required this.title,
    required this.documentNumber,
    required this.expiryDate,
    required this.status,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [type, title, documentNumber, expiryDate, status, fileUrl];
}
'''

files['lib/domain/entities/notification_entity.dart'] = '''import 'package:equatable/equatable.dart';

enum NotificationType { order, earnings, system, safety }

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, title, message, type, timestamp, isRead];
}
'''

# Repositories
files['lib/domain/repositories/auth_repository.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rider_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> login(String phone);
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp);
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData);
  Future<Either<Failure, RiderEntity?>> getSavedRider();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> refreshToken();
}
'''

files['lib/domain/repositories/order_repository.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getActiveOrders();
  Future<Either<Failure, OrderEntity?>> getIncomingOrder();
  Future<Either<Failure, OrderEntity>> acceptOrder(String orderId);
  Future<Either<Failure, bool>> declineOrder(String orderId, String reason);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  });
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory({String? statusFilter});
  Future<Either<Failure, OrderEntity>> getOrderDetails(String orderId);
}
'''

files['lib/domain/repositories/dashboard_repository.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class DashboardRepository {
  Future<Either<Failure, bool>> toggleOnlineStatus(bool isOnline);
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary();
  Future<Either<Failure, void>> updateLiveLocation(double lat, double lng);
}
'''

files['lib/domain/repositories/earnings_repository.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/earnings_entity.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EarningsEntity>> getEarningsBreakdown(String period);
  Future<Either<Failure, bool>> requestPayout(double amount, String paymentMethod);
}
'''

files['lib/domain/repositories/profile_repository.dart'] = '''import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rider_entity.dart';
import '../entities/document_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, RiderEntity>> getProfile();
  Future<Either<Failure, RiderEntity>> updateProfile(RiderEntity rider);
  Future<Either<Failure, List<DocumentEntity>>> getDocuments();
  Future<Either<Failure, DocumentEntity>> uploadDocument(String docType, String filePath);
}
'''

# Use Cases - Auth
files['lib/domain/usecases/auth/login_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, bool>> call(String phone) {
    return repository.login(phone);
  }
}
'''

files['lib/domain/usecases/auth/verify_otp_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(String phone, String otp) {
    return repository.verifyOtp(phone, otp);
  }
}
'''

files['lib/domain/usecases/auth/register_rider_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterRiderUseCase {
  final AuthRepository repository;
  RegisterRiderUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(Map<String, dynamic> riderData) {
    return repository.register(riderData);
  }
}
'''

files['lib/domain/usecases/auth/logout_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
'''

files['lib/domain/usecases/auth/get_saved_auth_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/auth_repository.dart';

class GetSavedAuthUseCase {
  final AuthRepository repository;
  GetSavedAuthUseCase(this.repository);

  Future<Either<Failure, RiderEntity?>> call() {
    return repository.getSavedRider();
  }
}
'''

# Use Cases - Dashboard
files['lib/domain/usecases/dashboard/toggle_online_status_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class ToggleOnlineStatusUseCase {
  final DashboardRepository repository;
  ToggleOnlineStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(bool isOnline) {
    return repository.toggleOnlineStatus(isOnline);
  }
}
'''

files['lib/domain/usecases/dashboard/get_dashboard_summary_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  GetDashboardSummaryUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getDashboardSummary();
  }
}
'''

files['lib/domain/usecases/dashboard/update_live_location_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/dashboard_repository.dart';

class UpdateLiveLocationUseCase {
  final DashboardRepository repository;
  UpdateLiveLocationUseCase(this.repository);

  Future<Either<Failure, void>> call(double lat, double lng) {
    return repository.updateLiveLocation(lat, lng);
  }
}
'''

# Use Cases - Orders
files['lib/domain/usecases/orders/get_active_orders_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetActiveOrdersUseCase {
  final OrderRepository repository;
  GetActiveOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() {
    return repository.getActiveOrders();
  }
}
'''

files['lib/domain/usecases/orders/get_incoming_order_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetIncomingOrderUseCase {
  final OrderRepository repository;
  GetIncomingOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity?>> call() {
    return repository.getIncomingOrder();
  }
}
'''

files['lib/domain/usecases/orders/accept_order_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class AcceptOrderUseCase {
  final OrderRepository repository;
  AcceptOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.acceptOrder(orderId);
  }
}
'''

files['lib/domain/usecases/orders/decline_order_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/order_repository.dart';

class DeclineOrderUseCase {
  final OrderRepository repository;
  DeclineOrderUseCase(this.repository);

  Future<Either<Failure, bool>> call(String orderId, String reason) {
    return repository.declineOrder(orderId, reason);
  }
}
'''

files['lib/domain/usecases/orders/update_order_status_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(
    String orderId,
    OrderStatus status, {
    String? proofPhotoUrl,
    String? customerOtp,
  }) {
    return repository.updateOrderStatus(
      orderId,
      status,
      proofPhotoUrl: proofPhotoUrl,
      customerOtp: customerOtp,
    );
  }
}
'''

files['lib/domain/usecases/orders/get_order_history_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderHistoryUseCase {
  final OrderRepository repository;
  GetOrderHistoryUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({String? statusFilter}) {
    return repository.getOrderHistory(statusFilter: statusFilter);
  }
}
'''

files['lib/domain/usecases/orders/get_order_details_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderDetailsUseCase {
  final OrderRepository repository;
  GetOrderDetailsUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderDetails(orderId);
  }
}
'''

# Use Cases - Earnings
files['lib/domain/usecases/earnings/get_earnings_breakdown_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/earnings_entity.dart';
import '../../repositories/earnings_repository.dart';

class GetEarningsBreakdownUseCase {
  final EarningsRepository repository;
  GetEarningsBreakdownUseCase(this.repository);

  Future<Either<Failure, EarningsEntity>> call(String period) {
    return repository.getEarningsBreakdown(period);
  }
}
'''

files['lib/domain/usecases/earnings/request_payout_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/earnings_repository.dart';

class RequestPayoutUseCase {
  final EarningsRepository repository;
  RequestPayoutUseCase(this.repository);

  Future<Either<Failure, bool>> call(double amount, String paymentMethod) {
    return repository.requestPayout(amount, paymentMethod);
  }
}
'''

# Use Cases - Profile
files['lib/domain/usecases/profile/get_profile_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call() {
    return repository.getProfile();
  }
}
'''

files['lib/domain/usecases/profile/update_profile_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/rider_entity.dart';
import '../../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, RiderEntity>> call(RiderEntity rider) {
    return repository.updateProfile(rider);
  }
}
'''

files['lib/domain/usecases/profile/get_documents_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/document_entity.dart';
import '../../repositories/profile_repository.dart';

class GetDocumentsUseCase {
  final ProfileRepository repository;
  GetDocumentsUseCase(this.repository);

  Future<Either<Failure, List<DocumentEntity>>> call() {
    return repository.getDocuments();
  }
}
'''

files['lib/domain/usecases/profile/upload_document_usecase.dart'] = '''import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/document_entity.dart';
import '../../repositories/profile_repository.dart';

class UploadDocumentUseCase {
  final ProfileRepository repository;
  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call(String docType, String filePath) {
    return repository.uploadDocument(docType, filePath);
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

