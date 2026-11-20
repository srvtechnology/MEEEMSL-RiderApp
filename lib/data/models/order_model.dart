import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    super.pickupProofPhotos = const [],
    super.cycle,
    super.riderAttempt,
  });

  static OrderStatus _parseStatus(String? statusStr) {
    switch (statusStr?.trim().toLowerCase()) {
      case 'accepted':
      case 'order_accepted':
      case 'assigned':
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
      case 'in_progress':
      case 'inprogress':
      case 'arrived_at_dropoff':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'cancelled_by_rider':
      case 'cancelledbyrider':
      case 'timed_out':
      case 'timedout':
      case 'rejected':
      case 'declined':
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
    Map<String, dynamic>? safeMap(dynamic val) {
      if (val == null) return null;
      if (val is Map<String, dynamic>) return val;
      if (val is Map) {
        try {
          return Map<String, dynamic>.from(val);
        } catch (_) {}
      }
      if (val is String && val.trim().startsWith('{')) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return null;
    }

    final orderMap = safeMap(json['order']);
    final pickupLocationMap = safeMap(json['pickupLocation'] ?? orderMap?['pickupLocation']);
    final dropoffLocationMap = safeMap(json['dropoffLocation'] ?? orderMap?['dropoffLocation']);
    final sellerMap = safeMap(orderMap?['seller'] ?? json['seller']);
    final businessInfo = safeMap(sellerMap?['businessInfo'] ?? sellerMap?['business_info']);
    final store = safeMap(sellerMap?['store'] ?? json['store'] ?? orderMap?['store']);
    final customer = safeMap(orderMap?['customer'] ?? json['customer']);

    final customerName = dropoffLocationMap?['name']?.toString() ??
        orderMap?['shippingFullName']?.toString() ??
        json['shippingFullName']?.toString() ??
        orderMap?['customerName']?.toString() ??
        json['customerName']?.toString() ??
        customer?['name']?.toString() ??
        'Customer';

    final customerPhone = dropoffLocationMap?['phone']?.toString() ??
        orderMap?['shippingPhone']?.toString() ??
        json['shippingPhone']?.toString() ??
        orderMap?['customerPhone']?.toString() ??
        json['customerPhone']?.toString() ??
        customer?['phone']?.toString() ??
        '';

    final dropoffParts = [
      orderMap?['shippingAddressLine1']?.toString() ?? json['shippingAddressLine1']?.toString(),
      orderMap?['shippingAddressLine2']?.toString() ?? json['shippingAddressLine2']?.toString(),
      orderMap?['shippingCity']?.toString() ?? json['shippingCity']?.toString(),
    ].where((s) => s != null && s.trim().isNotEmpty).toList();

    final dropoffAddress = dropoffLocationMap?['address']?.toString() ??
        (dropoffParts.isNotEmpty
            ? dropoffParts.join(', ')
            : (customer?['dropAddress']?.toString() ??
                customer?['address']?.toString() ??
                json['customerAddress']?.toString() ??
                json['dropoffAddress']?.toString() ??
                orderMap?['dropoffAddress']?.toString() ??
                ''));

    final pickupName = pickupLocationMap?['name']?.toString() ??
        store?['name']?.toString() ??
        businessInfo?['businessName']?.toString() ??
        orderMap?['seller']?['store']?['name']?.toString() ??
        json['seller']?['store']?['name']?.toString() ??
        json['shopName']?.toString() ??
        json['pickupName']?.toString() ??
        orderMap?['pickupName']?.toString() ??
        'Store / Vendor';

    final pickupParts = [
      businessInfo?['street']?.toString() ?? store?['address']?.toString(),
      businessInfo?['city']?.toString() ?? store?['city']?.toString(),
    ].where((s) => s != null && s.trim().isNotEmpty).toList();

    final pickupAddress = pickupLocationMap?['address']?.toString() ??
        (pickupParts.isNotEmpty
            ? pickupParts.join(', ')
            : (store?['address']?.toString() ??
                json['shopAddress']?.toString() ??
                json['pickupAddress']?.toString() ??
                orderMap?['pickupAddress']?.toString() ??
                ''));

    final pickupPhone = pickupLocationMap?['phone']?.toString() ??
        businessInfo?['pocContact']?.toString() ??
        store?['phone']?.toString() ??
        (sellerMap?['user'] is Map ? (sellerMap!['user'] as Map)['phone']?.toString() : null) ??
        json['pickupPhone']?.toString() ??
        orderMap?['pickupPhone']?.toString() ??
        '';

    double? parseCoordinate(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    (double, double)? extractGeoJson(dynamic obj) {
      if (obj == null) return null;
      if (obj is List && obj.length >= 2) {
        final p0 = parseCoordinate(obj[0]);
        final p1 = parseCoordinate(obj[1]);
        if (p0 != null && p1 != null) {
          if ((p0.abs() <= 90 && p1.abs() > 90) || (p0 >= 6 && p0 <= 38 && p1 >= 68 && p1 <= 98)) {
            return (p0, p1);
          }
          return (p1, p0);
        }
      }
      if (obj is Map) {
        final innerCoords = obj['coordinates'] ??
            (obj['location'] is Map ? (obj['location'] as Map)['coordinates'] : null) ??
            (obj['geo'] is Map ? (obj['geo'] as Map)['coordinates'] : null);
        if (innerCoords != null) return extractGeoJson(innerCoords);
      }
      return null;
    }

    final shippingAddressMap = safeMap(orderMap?['shippingAddress'] ?? json['shippingAddress']);
    final deliveryAddressMap = safeMap(orderMap?['deliveryAddress'] ?? json['deliveryAddress']);
    final coords = orderMap?['coordinates'] ?? json['coordinates'];

    // 1. Resolve Customer Dropoff Coordinates
    final customerAddressMap = safeMap(customer?['address']);
    final customerLocationMap = safeMap(customer?['location']);

    double? rawDropLat = parseCoordinate(json['dropoffLatitude']) ??
        parseCoordinate(dropoffLocationMap?['latitude']) ??
        parseCoordinate(dropoffLocationMap?['lat']) ??
        parseCoordinate(json['dropoffLat']) ??
        parseCoordinate(orderMap?['dropoffLatitude']) ??
        parseCoordinate(orderMap?['dropoffLat']) ??
        parseCoordinate(orderMap?['shippingLatitude']) ??
        parseCoordinate(json['shippingLatitude']) ??
        parseCoordinate(orderMap?['shippingLat']) ??
        parseCoordinate(json['shippingLat']) ??
        parseCoordinate(orderMap?['deliveryLatitude']) ??
        parseCoordinate(json['deliveryLatitude']) ??
        parseCoordinate(shippingAddressMap?['latitude']) ??
        parseCoordinate(shippingAddressMap?['lat']) ??
        parseCoordinate(deliveryAddressMap?['latitude']) ??
        parseCoordinate(deliveryAddressMap?['lat']) ??
        parseCoordinate(customer?['latitude']) ??
        parseCoordinate(customer?['lat']) ??
        parseCoordinate(customerAddressMap?['latitude']) ??
        parseCoordinate(customerAddressMap?['lat']) ??
        parseCoordinate(customerLocationMap?['latitude']) ??
        parseCoordinate(customerLocationMap?['lat']);

    double? rawDropLng = parseCoordinate(json['dropoffLongitude']) ??
        parseCoordinate(dropoffLocationMap?['longitude']) ??
        parseCoordinate(dropoffLocationMap?['lng']) ??
        parseCoordinate(json['dropoffLng']) ??
        parseCoordinate(orderMap?['dropoffLongitude']) ??
        parseCoordinate(orderMap?['dropoffLng']) ??
        parseCoordinate(orderMap?['shippingLongitude']) ??
        parseCoordinate(json['shippingLongitude']) ??
        parseCoordinate(orderMap?['shippingLng']) ??
        parseCoordinate(json['shippingLng']) ??
        parseCoordinate(orderMap?['deliveryLongitude']) ??
        parseCoordinate(json['deliveryLongitude']) ??
        parseCoordinate(shippingAddressMap?['longitude']) ??
        parseCoordinate(shippingAddressMap?['lng']) ??
        parseCoordinate(deliveryAddressMap?['longitude']) ??
        parseCoordinate(deliveryAddressMap?['lng']) ??
        parseCoordinate(customer?['longitude']) ??
        parseCoordinate(customer?['lng']) ??
        parseCoordinate(customerAddressMap?['longitude']) ??
        parseCoordinate(customerAddressMap?['lng']) ??
        parseCoordinate(customerLocationMap?['longitude']) ??
        parseCoordinate(customerLocationMap?['lng']);

    if (rawDropLat == null || rawDropLng == null) {
      final geo = extractGeoJson(coords) ??
          extractGeoJson(dropoffLocationMap) ??
          extractGeoJson(deliveryAddressMap) ??
          extractGeoJson(shippingAddressMap) ??
          extractGeoJson(customerLocationMap) ??
          extractGeoJson(customerAddressMap);
      if (geo != null) {
        rawDropLat ??= geo.$1;
        rawDropLng ??= geo.$2;
      }
    }

    // Dynamic coordinate lookup from address text and landmarks across Sierra Leone & West Bengal
    (double, double)? resolveAddressCoordinates(String address) {
      final lower = address.toLowerCase();

      // 1. Sierra Leone locations & street landmarks (MEEEM Platform Core)
      if (lower.contains('siaka stevens')) return const (8.4842, -13.2341);
      if (lower.contains('wilkinson')) return const (8.4756, -13.2652);
      if (lower.contains('lumley')) return const (8.4632, -13.2778);
      if (lower.contains('aberdeen')) return const (8.4900, -13.2900);
      if (lower.contains('congo cross')) return const (8.4780, -13.2500);
      if (lower.contains('kissy')) return const (8.4700, -13.1900);
      if (lower.contains('tower hill')) return const (8.4800, -13.2300);
      if (lower.contains('brookfields')) return const (8.4720, -13.2450);
      if (lower.contains('fourah bay')) return const (8.4850, -13.2180);
      if (lower.contains('regent')) return const (8.4350, -13.2200);
      if (lower.contains('waterloo')) return const (8.3389, -13.0708);
      if (lower.contains('goderich')) return const (8.4300, -13.2800);
      if (lower.contains('lakka')) return const (8.4000, -13.2800);
      if (lower.contains('hamilton')) return const (8.3700, -13.2700);
      if (lower.contains('no 2 river') || lower.contains('river no 2')) return const (8.3300, -13.2600);
      if (lower.contains('baw baw')) return const (8.3500, -13.2700);
      if (lower.contains('freetown')) return const (8.4842, -13.2341);
      if (lower.contains('bo')) return const (7.9644, -11.7383);
      if (lower.contains('kenema')) return const (7.8767, -11.1875);
      if (lower.contains('makeni')) return const (8.8833, -12.0500);
      if (lower.contains('koidu')) return const (8.6439, -10.9708);

      // 2. West Bengal districts & landmarks
      if (lower.contains('patiram')) return const (25.3340, 88.7600);
      if (lower.contains('balurghat')) return const (25.2200, 88.7667);
      if (lower.contains('gangarampur')) return const (25.4000, 88.5200);
      if (lower.contains('buniadpur')) return const (25.3833, 88.3833);
      if (lower.contains('malda') || lower.contains('english bazar')) return const (25.0000, 88.1400);
      if (lower.contains('raiganj')) return const (25.6167, 88.1167);
      if (lower.contains('siliguri')) return const (26.7271, 88.3953);
      if (lower.contains('jalpaiguri')) return const (26.5400, 88.7200);
      if (lower.contains('khagrabari') || lower.contains('khagra bari')) return const (26.3442, 89.4529);
      if (lower.contains('cooch') || lower.contains('cob') || lower.contains('koch bihar')) return const (26.3239, 89.4510);
      if (lower.contains('alipurduar')) return const (26.4919, 89.5271);
      if (lower.contains('tufanganj')) return const (26.3167, 89.6667);
      if (lower.contains('dinhata')) return const (26.1333, 89.4667);
      if (lower.contains('mathabhanga')) return const (26.3333, 89.2167);
      if (lower.contains('mekhliganj')) return const (26.3456, 88.9167);
      if (lower.contains('haldibari')) return const (26.3333, 88.7667);
      if (lower.contains('kolkata') || lower.contains('calcutta')) return const (22.5726, 88.3639);

      // Check if address string contains literal coordinate pair like "25.3340, 88.7600" or "8.4842, -13.2341"
      final match = RegExp(r'(-?\d{1,2}\.\d{3,})\s*,\s*(-?\d{1,3}\.\d{3,})').firstMatch(address);
      if (match != null) {
        final p1 = double.tryParse(match.group(1)!);
        final p2 = double.tryParse(match.group(2)!);
        if (p1 != null && p2 != null) {
          if ((p1 >= 68 && p1 <= 98) && (p2 >= 6 && p2 <= 38)) {
            return (p2, p1);
          } else {
            return (p1, p2);
          }
        }
      }
      return null;
    }

    // ONLY if backend did not provide dropoff coordinates, try geocoding address text
    if (rawDropLat == null || rawDropLng == null || (rawDropLat == 0.0 && rawDropLng == 0.0)) {
      final resolved = resolveAddressCoordinates(dropoffAddress);
      if (resolved != null) {
        rawDropLat = resolved.$1;
        rawDropLng = resolved.$2;
      }
    }

    // 2. Resolve Seller / Store Pickup Coordinates
    final storeLocationMap = safeMap(store?['location'] ?? businessInfo?['location'] ?? sellerMap?['location']);

    double? rawPickLat = parseCoordinate(json['sellerLatitude']) ??
        parseCoordinate(json['sellerLat']) ??
        parseCoordinate(pickupLocationMap?['latitude']) ??
        parseCoordinate(pickupLocationMap?['lat']) ??
        parseCoordinate(orderMap?['sellerLatitude']) ??
        parseCoordinate(orderMap?['sellerLat']) ??
        parseCoordinate(businessInfo?['latitude']) ??
        parseCoordinate(businessInfo?['lat']) ??
        parseCoordinate(store?['lat']) ??
        parseCoordinate(store?['latitude']) ??
        parseCoordinate(storeLocationMap?['latitude']) ??
        parseCoordinate(storeLocationMap?['lat']) ??
        parseCoordinate(json['pickupLat']) ??
        parseCoordinate(json['pickupLatitude']) ??
        parseCoordinate(orderMap?['pickupLat']) ??
        parseCoordinate(orderMap?['pickupLatitude']) ??
        parseCoordinate(sellerMap?['latitude']) ??
        parseCoordinate(sellerMap?['lat']);

    double? rawPickLng = parseCoordinate(json['sellerLongitude']) ??
        parseCoordinate(json['sellerLng']) ??
        parseCoordinate(pickupLocationMap?['longitude']) ??
        parseCoordinate(pickupLocationMap?['lng']) ??
        parseCoordinate(orderMap?['sellerLongitude']) ??
        parseCoordinate(orderMap?['sellerLng']) ??
        parseCoordinate(businessInfo?['longitude']) ??
        parseCoordinate(businessInfo?['lng']) ??
        parseCoordinate(store?['lng']) ??
        parseCoordinate(store?['longitude']) ??
        parseCoordinate(storeLocationMap?['longitude']) ??
        parseCoordinate(storeLocationMap?['lng']) ??
        parseCoordinate(json['pickupLng']) ??
        parseCoordinate(json['pickupLongitude']) ??
        parseCoordinate(orderMap?['pickupLng']) ??
        parseCoordinate(orderMap?['pickupLongitude']) ??
        parseCoordinate(sellerMap?['longitude']) ??
        parseCoordinate(sellerMap?['lng']);

    if (rawPickLat == null || rawPickLng == null) {
      final geoPick = extractGeoJson(pickupLocationMap) ??
          extractGeoJson(storeLocationMap) ??
          extractGeoJson(businessInfo) ??
          extractGeoJson(store) ??
          extractGeoJson(sellerMap);
      if (geoPick != null) {
        rawPickLat ??= geoPick.$1;
        rawPickLng ??= geoPick.$2;
      }
    }

    // ONLY if backend did not provide pickup coordinates, try geocoding address text
    if (rawPickLat == null || rawPickLng == null || (rawPickLat == 0.0 && rawPickLng == 0.0)) {
      final resolvedPick = resolveAddressCoordinates(pickupAddress);
      if (resolvedPick != null) {
        rawPickLat = resolvedPick.$1;
        rawPickLng = resolvedPick.$2;
      }
    }

    // Dynamic fallback ONLY if backend coordinates and address geocoding are completely missing
    if (rawPickLat == null || rawPickLng == null || (rawPickLat == 0.0 && rawPickLng == 0.0)) {
      final isIndia = pickupAddress.toLowerCase().contains('cooch') ||
          pickupAddress.toLowerCase().contains('patiram') ||
          pickupAddress.toLowerCase().contains('bengal') ||
          pickupAddress.toLowerCase().contains('india');
      if (isIndia) {
        rawPickLat = 26.3239;
        rawPickLng = 89.4510;
      } else {
        rawPickLat = 8.4842;
        rawPickLng = -13.2341;
      }
    }

    if (rawDropLat == null || rawDropLng == null || (rawDropLat == 0.0 && rawDropLng == 0.0)) {
      final isIndia = dropoffAddress.toLowerCase().contains('cooch') ||
          dropoffAddress.toLowerCase().contains('patiram') ||
          dropoffAddress.toLowerCase().contains('bengal') ||
          dropoffAddress.toLowerCase().contains('india');
      if (isIndia) {
        rawDropLat = 26.3442;
        rawDropLng = 89.4529;
      } else {
        rawDropLat = 8.4632;
        rawDropLng = -13.2778;
      }
    }

    final orderNumber = orderMap?['orderNumber']?.toString() ??
        json['orderNumber']?.toString() ??
        orderMap?['orderNo']?.toString() ??
        json['orderNo']?.toString() ??
        (json['id'] != null ? json['id'].toString() : '');

    final pickupLat = rawPickLat;
    final pickupLng = rawPickLng;
    final dropoffLat = rawDropLat;
    final dropoffLng = rawDropLng;

    debugPrint('[OrderModel.fromJson] #$orderNumber | Pickup: ($pickupLat, $pickupLng) from "$pickupAddress" | Dropoff: ($dropoffLat, $dropoffLng) from "$dropoffAddress"');

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
        parseDouble(json['totalAmount']) ??
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
        parseDouble(json['deliveryCharge']) ??
        parseDouble(json['earning']) ??
        parseDouble(json['earningForThisDelivery']) ??
        parseDouble(orderMap?['deliveryFee']) ??
        parseDouble(orderMap?['deliveryEarning']) ??
        parseDouble(orderMap?['deliveryCharge']) ??
        parseDouble(orderMap?['earning']) ??
        parseDouble(orderMap?['earningForThisDelivery']) ??
        parseDouble(json['riderEarnings']) ??
        parseDouble(orderMap?['riderEarnings']) ??
        parseDouble(orderMap?['shipping']) ??
        parseDouble(orderMap?['shippingAmount']) ??
        parseDouble(json['totalAmount']) ??
        (itemsShippingSum > 0.0 ? itemsShippingSum : 0.0);

    final distanceKm = parseDouble(json['distanceKm']) ?? parseDouble(orderMap?['distanceKm']) ?? 2.1;
    final estimatedDuration = int.tryParse(json['estimatedDurationMin']?.toString() ?? '') ?? 15;

    final rawAssignmentId = json['assignmentId']?.toString() ??
        orderMap?['assignmentId']?.toString() ??
        (json['orderId'] != null ? json['id']?.toString() : null);

    final cycle = int.tryParse(json['cycle']?.toString() ?? '') ?? int.tryParse(orderMap?['cycle']?.toString() ?? '');
    final riderAttempt = int.tryParse(json['riderAttempt']?.toString() ?? '') ?? int.tryParse(orderMap?['riderAttempt']?.toString() ?? '');

    final resolvedId = json['id']?.toString() ??
        orderMap?['id']?.toString() ??
        json['orderId']?.toString() ??
        orderMap?['orderId']?.toString() ??
        '';

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
      pickupProofPhotos: () {
        final rawPhotos = json['pickupProofPhotos'] ??
            orderMap?['pickupProofPhotos'] ??
            json['pickupPhotos'] ??
            orderMap?['pickupPhotos'] ??
            (json['activeAssignment'] is Map ? (json['activeAssignment'] as Map)['pickupProofPhotos'] : null);
        if (rawPhotos is List) {
          return rawPhotos
              .where((p) => p != null && p.toString().trim().isNotEmpty)
              .map((p) => p.toString())
              .toList();
        }
        return const <String>[];
      }(),
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
      'pickupProofPhotos': pickupProofPhotos,
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
      pickupProofPhotos: entity.pickupProofPhotos,
      cycle: entity.cycle,
      riderAttempt: entity.riderAttempt,
    );
  }
}
