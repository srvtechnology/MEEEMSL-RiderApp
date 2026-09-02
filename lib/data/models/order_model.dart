import '../../domain/entities/order_entity.dart';
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
      case 'at_pickup':
      case 'arrived_at_pickup':
        return OrderStatus.atPickup;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'out_for_delivery':
      case 'in_transit':
      case 'arrived_at_dropoff':
        return OrderStatus.outForDelivery;
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
      case OrderStatus.atPickup:
        return 'at_pickup';
      case OrderStatus.pickedUp:
        return 'picked_up';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
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
