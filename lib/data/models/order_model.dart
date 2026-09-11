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

    final customerName = orderMap?['shippingFullName']?.toString() ??
        json['shippingFullName']?.toString() ??
        orderMap?['customerName']?.toString() ??
        json['customerName']?.toString() ??
        (orderMap?['customer'] is Map ? (orderMap!['customer'] as Map)['name']?.toString() : null) ??
        (json['customer'] is Map ? (json['customer'] as Map)['name']?.toString() : null) ??
        'Customer';

    final customerPhone = orderMap?['shippingPhone']?.toString() ??
        json['shippingPhone']?.toString() ??
        orderMap?['customerPhone']?.toString() ??
        json['customerPhone']?.toString() ??
        (orderMap?['customer'] is Map ? (orderMap!['customer'] as Map)['phone']?.toString() : null) ??
        (json['customer'] is Map ? (json['customer'] as Map)['phone']?.toString() : null) ??
        '';

    final dropoffParts = [
      orderMap?['shippingAddressLine1']?.toString() ?? json['shippingAddressLine1']?.toString(),
      orderMap?['shippingAddressLine2']?.toString() ?? json['shippingAddressLine2']?.toString(),
      orderMap?['shippingCity']?.toString() ?? json['shippingCity']?.toString(),
    ].where((s) => s != null && s.trim().isNotEmpty).toList();

    final dropoffAddress = dropoffParts.isNotEmpty
        ? dropoffParts.join(', ')
        : (json['customerAddress']?.toString() ?? json['dropoffAddress']?.toString() ?? '');

    final pickupName = store?['name']?.toString() ??
        businessInfo?['businessName']?.toString() ??
        orderMap?['seller']?['store']?['name']?.toString() ??
        json['seller']?['store']?['name']?.toString() ??
        json['shopName']?.toString() ??
        json['pickupName']?.toString() ??
        'Store / Vendor';

    final pickupParts = [
      businessInfo?['street']?.toString() ?? store?['address']?.toString(),
      businessInfo?['city']?.toString() ?? store?['city']?.toString(),
    ].where((s) => s != null && s.trim().isNotEmpty).toList();

    final pickupAddress = pickupParts.isNotEmpty
        ? pickupParts.join(', ')
        : (json['shopAddress']?.toString() ?? json['pickupAddress']?.toString() ?? '');

    final pickupPhone = businessInfo?['pocContact']?.toString() ??
        store?['phone']?.toString() ??
        (sellerMap?['user'] is Map ? (sellerMap!['user'] as Map)['phone']?.toString() : null) ??
        json['pickupPhone']?.toString() ??
        '';

    final pickupLat = double.tryParse(businessInfo?['latitude']?.toString() ?? '') ??
        double.tryParse(store?['lat']?.toString() ?? '') ??
        double.tryParse(json['sellerLatitude']?.toString() ?? '') ??
        double.tryParse(json['pickupLat']?.toString() ?? '') ??
        8.484245;

    final pickupLng = double.tryParse(businessInfo?['longitude']?.toString() ?? '') ??
        double.tryParse(store?['lng']?.toString() ?? '') ??
        double.tryParse(json['sellerLongitude']?.toString() ?? '') ??
        double.tryParse(json['pickupLng']?.toString() ?? '') ??
        -13.234125;

    final dropoffLat = double.tryParse(json['dropoffLat']?.toString() ?? '') ??
        double.tryParse(orderMap?['dropoffLat']?.toString() ?? '') ??
        8.460;
    final dropoffLng = double.tryParse(json['dropoffLng']?.toString() ?? '') ??
        double.tryParse(orderMap?['dropoffLng']?.toString() ?? '') ??
        -13.250;

    final rawItems = orderMap?['items'] ?? json['items'];
    final items = <OrderItemModel>[];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          try {
            items.add(OrderItemModel.fromJson(it));
          } catch (_) {}
        } else if (it is Map) {
          try {
            items.add(OrderItemModel.fromJson(Map<String, dynamic>.from(it)));
          } catch (_) {}
        }
      }
    }

    final orderNumber = orderMap?['orderNumber']?.toString() ??
        json['orderNumber']?.toString() ??
        '';

    String? resolvedOtp = json['deliveryOtp']?.toString() ??
        orderMap?['deliveryOtp']?.toString();
    if ((resolvedOtp == null || resolvedOtp.trim().isEmpty) && rawItems is List && rawItems.isNotEmpty) {
      for (final it in rawItems) {
        if (it is Map && it['deliveryOtp'] != null && it['deliveryOtp'].toString().trim().isNotEmpty) {
          resolvedOtp = it['deliveryOtp'].toString();
          break;
        }
      }
    }
    final deliveryOtp = resolvedOtp ?? '';

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().trim());
    }

    final subtotal = parseDouble(orderMap?['totalAmount']) ??
        parseDouble(orderMap?['subtotal']) ??
        parseDouble(json['subtotal']) ??
        0.0;

    double itemsShippingSum = 0.0;
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map) {
          itemsShippingSum += parseDouble(it['shippingAmount']) ?? 0.0;
        }
      }
    }

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
    final estimatedDuration = int.tryParse(json['estimatedDurationMin']?.toString() ?? '') ?? 15;

    final rawAssignmentId = json['assignmentId']?.toString() ??
        orderMap?['assignmentId']?.toString() ??
        (json['orderId'] != null ? json['id']?.toString() : null);

    final cycle = int.tryParse(json['cycle']?.toString() ?? '') ?? int.tryParse(orderMap?['cycle']?.toString() ?? '');
    final riderAttempt = int.tryParse(json['riderAttempt']?.toString() ?? '') ?? int.tryParse(orderMap?['riderAttempt']?.toString() ?? '');

    final resolvedId = json['id']?.toString() ?? orderMap?['id']?.toString() ?? '';

    final rawCreatedAt = json['createdAt']?.toString() ??
        orderMap?['createdAt']?.toString() ??
        json['offeredAt']?.toString() ??
        json['acceptedAt']?.toString();
    final createdAt = rawCreatedAt != null
        ? (DateTime.tryParse(rawCreatedAt) ?? DateTime.now())
        : DateTime.now();

    return OrderModel(
      id: resolvedId,
      assignmentId: rawAssignmentId,
      orderNumber: orderNumber,
      status: _parseStatus((json['status'] ?? orderMap?['status'])?.toString()),
      customerName: customerName,
      customerPhone: customerPhone,
      customerAvatar: json['customerAvatar']?.toString() ?? '',
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      pickupPhone: pickupPhone,
      dropoffAddress: dropoffAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      items: items,
      subtotal: subtotal,
      riderEarnings: earnings,
      distanceKm: distanceKm,
      estimatedDurationMin: estimatedDuration,
      createdAt: createdAt,
      notes: json['notes']?.toString() ?? '',
      deliveryOtp: deliveryOtp,
      proofPhotoUrl: (json['proofPhotoUrl'] ?? json['deliveryProofImage'] ?? orderMap?['deliveryProofImage'])?.toString(),
      cycle: cycle,
      riderAttempt: riderAttempt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
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
      'cycle': cycle,
      'riderAttempt': riderAttempt,
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
