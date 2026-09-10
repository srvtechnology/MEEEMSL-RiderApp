import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

enum OrderStatus {
  pending,
  accepted,        // 1. ACCEPTED (Rider accepted, heading to store)
  atPickup,        // 2. AT_PICKUP (Arrived at vendor store)
  pickedUp,        // 3. PICKED_UP (Items collected & verified)
  outForDelivery,  // 4. OUT_FOR_DELIVERY (On the way to customer)
  delivered,       // 5. DELIVERED (Delivery completed)
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Heading to Pickup Store';
      case OrderStatus.atPickup:
        return 'Arrived at Store';
      case OrderStatus.pickedUp:
        return 'Order Picked Up';
      case OrderStatus.outForDelivery:
        return 'On the Way to Customer';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get stepNumberText {
    switch (this) {
      case OrderStatus.accepted:
        return 'Step 1 of 5';
      case OrderStatus.atPickup:
        return 'Step 2 of 5';
      case OrderStatus.pickedUp:
        return 'Step 3 of 5';
      case OrderStatus.outForDelivery:
        return 'Step 4 of 5';
      case OrderStatus.delivered:
        return 'Step 5 of 5 (Delivered)';
      default:
        return '';
    }
  }

  String get nextStepActionTitle {
    switch (this) {
      case OrderStatus.accepted:
        return 'Swipe when Arrived at Store';
      case OrderStatus.atPickup:
        return 'Swipe to Confirm Items Picked Up';
      case OrderStatus.pickedUp:
        return 'Swipe to Start Delivery to Customer';
      case OrderStatus.outForDelivery:
        return 'Swipe to Complete Delivery (Enter OTP)';
      default:
        return 'Confirm Step';
    }
  }

  /// Exact uppercase API status string conforming to MOBILE_RIDER_APP_API_DOC_PART_2.md Section 8
  String get toApiStatus {
    switch (this) {
      case OrderStatus.pending:
        return 'OFFERED';
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.atPickup:
        return 'AT_PICKUP';
      case OrderStatus.pickedUp:
        return 'PICKED_UP';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED_BY_RIDER';
    }
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String? assignmentId;
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
  final int? cycle;
  final int? riderAttempt;

  const OrderEntity({
    required this.id,
    this.assignmentId,
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
    this.cycle,
    this.riderAttempt,
  });

  OrderEntity copyWith({
    String? id,
    String? assignmentId,
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
    int? cycle,
    int? riderAttempt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
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
      cycle: cycle ?? this.cycle,
      riderAttempt: riderAttempt ?? this.riderAttempt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        orderNumber,
        status,
        customerName,
        pickupName,
        pickupAddress,
        dropoffAddress,
        riderEarnings,
        distanceKm,
        cycle,
        riderAttempt,
      ];
}
