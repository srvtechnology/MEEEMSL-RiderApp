import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    super.assignmentId,
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
    super.cycle,
    super.riderAttempt,
  });

  static OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr?.trim().toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'at_pickup':
      case 'atpickup':
      case 'arrived_at_pickup':
        return OrderStatus.atPickup;
      case 'picked_up':
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'out_for_delivery':
      case 'outfordelivery':
      case 'in_transit':
      case 'arrived_at_dropoff':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'cancelled_by_rider':
      case 'cancelledbyrider':
      case 'timed_out':
      case 'timedout':
        return OrderStatus.cancelled;
      case 'offered':
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    return status.toApiStatus;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderMap = json['order'] as Map<String, dynamic>?;
    final sellerMap = orderMap?['seller'] as Map<String, dynamic>? ??
        json['seller'] as Map<String, dynamic>?;
    final businessInfo = sellerMap?['businessInfo'] as Map<String, dynamic>?;
    final store = sellerMap?['store'] as Map<String, dynamic>?;

    final customerName = orderMap?['shippingFullName'] as String? ??
        json['shippingFullName'] as String? ??
        json['customerName'] as String? ??
        'Customer';

    final customerPhone = orderMap?['shippingPhone'] as String? ??
        json['shippingPhone'] as String? ??
        json['customerPhone'] as String? ??
        '';

    final dropoffParts = [
      orderMap?['shippingAddressLine1'] ?? json['shippingAddressLine1'],
      orderMap?['shippingAddressLine2'] ?? json['shippingAddressLine2'],
      orderMap?['shippingCity'] ?? json['shippingCity'],
    ].where((s) => s != null && s.toString().trim().isNotEmpty).toList();

    final dropoffAddress = dropoffParts.isNotEmpty
        ? dropoffParts.join(', ')
        : (json['customerAddress'] as String? ?? json['dropoffAddress'] as String? ?? '');

    final pickupName = store?['name'] as String? ??
        businessInfo?['businessName'] as String? ??
        json['shopName'] as String? ??
        json['pickupName'] as String? ??
        'Store / Vendor';

    final pickupParts = [
      businessInfo?['street'],
      businessInfo?['city'],
    ].where((s) => s != null && s.toString().trim().isNotEmpty).toList();

    final pickupAddress = pickupParts.isNotEmpty
        ? pickupParts.join(', ')
        : (json['shopAddress'] as String? ?? json['pickupAddress'] as String? ?? '');

    final pickupPhone = businessInfo?['pocContact'] as String? ??
        json['customerPhone'] as String? ??
        json['pickupPhone'] as String? ??
        '';

    final pickupLat = (businessInfo?['latitude'] as num?)?.toDouble() ??
        (json['pickupLat'] as num?)?.toDouble() ??
        8.484245;

    final pickupLng = (businessInfo?['longitude'] as num?)?.toDouble() ??
        (json['pickupLng'] as num?)?.toDouble() ??
        -13.234125;

    final rawItems = orderMap?['items'] ?? json['items'];
    final items = (rawItems is List)
        ? rawItems
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OrderItemModel>[];

    final orderNumber = orderMap?['orderNumber'] as String? ??
        json['orderNumber'] as String? ??
        '';

    final deliveryOtp = json['deliveryOtp'] as String? ??
        orderMap?['deliveryOtp'] as String? ??
        '';

    final subtotal = (orderMap?['totalAmount'] as num?)?.toDouble() ??
        (orderMap?['subtotal'] as num?)?.toDouble() ??
        (json['subtotal'] as num?)?.toDouble() ??
        0.0;

    double itemsShippingSum = 0.0;
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          itemsShippingSum += (it['shippingAmount'] as num?)?.toDouble() ?? 0.0;
        }
      }
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().trim());
    }

    // Section 5: deliveryFee, deliveryEarning, earning alongside earningForThisDelivery
    final earnings = parseDouble(json['deliveryFee']) ??
        parseDouble(json['deliveryEarning']) ??
        parseDouble(json['earning']) ??
        parseDouble(json['earningForThisDelivery']) ??
        parseDouble(orderMap?['deliveryFee']) ??
        parseDouble(orderMap?['deliveryEarning']) ??
        parseDouble(orderMap?['earning']) ??
        parseDouble(orderMap?['earningForThisDelivery']) ??
        parseDouble(json['riderEarnings']) ??
        parseDouble(orderMap?['riderEarnings']) ??
        parseDouble(orderMap?['shipping']) ??
        parseDouble(orderMap?['shippingAmount']) ??
        (itemsShippingSum > 0.0 ? itemsShippingSum : 0.0);

    final distanceKm = parseDouble(json['distanceKm']) ?? parseDouble(orderMap?['distanceKm']) ?? 2.1;
    final estimatedDuration = (json['estimatedDurationMin'] as num?)?.toInt() ?? 15;

    final assignmentId = json['assignmentId']?.toString() ?? orderMap?['assignmentId']?.toString();
    final cycle = int.tryParse(json['cycle']?.toString() ?? '') ?? int.tryParse(orderMap?['cycle']?.toString() ?? '');
    final riderAttempt = int.tryParse(json['riderAttempt']?.toString() ?? '') ?? int.tryParse(orderMap?['riderAttempt']?.toString() ?? '');

    return OrderModel(
      id: json['id'] as String? ?? orderMap?['id'] as String? ?? '',
      assignmentId: assignmentId,
      orderNumber: orderNumber,
      status: _parseStatus(json['status'] as String?),
      customerName: customerName,
      customerPhone: customerPhone,
      customerAvatar: json['customerAvatar'] as String? ?? '',
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      pickupPhone: pickupPhone,
      dropoffAddress: dropoffAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble() ?? 8.460,
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble() ?? -13.250,
      items: items,
      subtotal: subtotal,
      riderEarnings: earnings,
      distanceKm: distanceKm,
      estimatedDurationMin: estimatedDuration,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : (json['offeredAt'] != null
              ? DateTime.tryParse(json['offeredAt'] as String) ?? DateTime.now()
              : DateTime.now()),
      notes: json['notes'] as String? ?? '',
      deliveryOtp: deliveryOtp,
      proofPhotoUrl: (json['proofPhotoUrl'] ?? json['deliveryProofImage']) as String?,
      cycle: cycle,
      riderAttempt: riderAttempt,
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
      assignmentId: entity.assignmentId,
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
      cycle: entity.cycle,
      riderAttempt: entity.riderAttempt,
    );
  }
}
