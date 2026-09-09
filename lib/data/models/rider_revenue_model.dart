import '../../domain/entities/rider_revenue_entity.dart';

class RevenueOrderItemModel extends RevenueOrderItemEntity {
  const RevenueOrderItemModel({
    required super.id,
    super.productId,
    required super.name,
    super.variantName,
    required super.quantity,
    required super.price,
    required super.shippingAmount,
    super.image,
  });

  factory RevenueOrderItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueOrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString(),
      name: json['name']?.toString() ?? 'Order Item',
      variantName: json['variantName']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      shippingAmount: (json['shippingAmount'] as num?)?.toDouble() ?? 0.0,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'variantName': variantName,
      'quantity': quantity,
      'price': price,
      'shippingAmount': shippingAmount,
      'image': image,
    };
  }
}

class RevenueStoreModel extends RevenueStoreEntity {
  const RevenueStoreModel({
    super.id,
    required super.name,
    super.phone,
    required super.address,
  });

  factory RevenueStoreModel.fromJson(Map<String, dynamic> json) {
    return RevenueStoreModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Store',
      phone: json['phone']?.toString(),
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

class RevenueCustomerModel extends RevenueCustomerEntity {
  const RevenueCustomerModel({
    super.id,
    required super.name,
    super.phone,
    required super.dropAddress,
  });

  factory RevenueCustomerModel.fromJson(Map<String, dynamic> json) {
    return RevenueCustomerModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Customer',
      phone: json['phone']?.toString(),
      dropAddress: json['dropAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'dropAddress': dropAddress,
    };
  }
}

class RiderRevenueDeliveryModel extends RiderRevenueDeliveryEntity {
  const RiderRevenueDeliveryModel({
    required super.id,
    required super.assignmentId,
    required super.orderId,
    required super.orderNumber,
    required super.status,
    required super.statusCategory,
    required super.isDelivered,
    required super.offeredAt,
    super.acceptedAt,
    super.pickedUpAt,
    super.deliveredAt,
    super.deliveryOtp,
    super.deliveryProofImage,
    super.distanceKm,
    required super.deliveryCharge,
    super.totalAmount,
    required super.store,
    required super.customer,
    required super.items,
    required super.totalItemsCount,
  });

  factory RiderRevenueDeliveryModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString().toUpperCase() ?? 'DELIVERED';
    final isDelivered = json['isDelivered'] == true || rawStatus == 'DELIVERED';
    final statusCat = json['statusCategory']?.toString().toUpperCase() ??
        (isDelivered ? 'DELIVERED' : 'IN_PROGRESS');

    final itemsList = (json['items'] as List?)
            ?.map((e) => RevenueOrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <RevenueOrderItemModel>[];

    final storeMap = json['store'] is Map<String, dynamic>
        ? json['store'] as Map<String, dynamic>
        : <String, dynamic>{};
    final customerMap = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : <String, dynamic>{};

    final deliveryCharge = (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = isDelivered
        ? ((json['totalAmount'] as num?)?.toDouble() ?? deliveryCharge)
        : null;

    final offeredStr = json['offeredAt']?.toString();
    final acceptedStr = json['acceptedAt']?.toString();
    final pickedUpStr = json['pickedUpAt']?.toString();
    final deliveredStr = json['deliveredAt']?.toString();

    return RiderRevenueDeliveryModel(
      id: json['id']?.toString() ?? json['assignmentId']?.toString() ?? '',
      assignmentId: json['assignmentId']?.toString() ?? json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: rawStatus,
      statusCategory: statusCat,
      isDelivered: isDelivered,
      offeredAt: offeredStr != null ? (DateTime.tryParse(offeredStr) ?? DateTime.now()) : DateTime.now(),
      acceptedAt: acceptedStr != null ? DateTime.tryParse(acceptedStr) : null,
      pickedUpAt: pickedUpStr != null ? DateTime.tryParse(pickedUpStr) : null,
      deliveredAt: deliveredStr != null ? DateTime.tryParse(deliveredStr) : null,
      deliveryOtp: json['deliveryOtp']?.toString(),
      deliveryProofImage: json['deliveryProofImage']?.toString(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      deliveryCharge: deliveryCharge,
      totalAmount: totalAmount,
      store: RevenueStoreModel.fromJson(storeMap),
      customer: RevenueCustomerModel.fromJson(customerMap),
      items: itemsList,
      totalItemsCount: (json['totalItemsCount'] as num?)?.toInt() ??
          (itemsList.isNotEmpty ? itemsList.fold(0, (sum, it) => sum + it.quantity) : 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'status': status,
      'statusCategory': statusCategory,
      'isDelivered': isDelivered,
      'offeredAt': offeredAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'deliveryOtp': deliveryOtp,
      'deliveryProofImage': deliveryProofImage,
      'distanceKm': distanceKm,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'store': (store as RevenueStoreModel).toJson(),
      'customer': (customer as RevenueCustomerModel).toJson(),
      'items': items.map((e) => (e as RevenueOrderItemModel).toJson()).toList(),
      'totalItemsCount': totalItemsCount,
    };
  }
}

class RiderRevenueSummaryModel extends RiderRevenueSummaryEntity {
  const RiderRevenueSummaryModel({
    required super.totalDeliveredRevenue,
    required super.pendingInProgressRevenue,
    required super.deliveredCount,
    required super.inProgressCount,
    required super.totalDeliveriesCount,
    super.currency,
  });

  factory RiderRevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    return RiderRevenueSummaryModel(
      totalDeliveredRevenue: (json['totalDeliveredRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingInProgressRevenue: (json['pendingInProgressRevenue'] as num?)?.toDouble() ?? 0.0,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
      inProgressCount: (json['inProgressCount'] as num?)?.toInt() ?? 0,
      totalDeliveriesCount: (json['totalDeliveriesCount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'NLe',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDeliveredRevenue': totalDeliveredRevenue,
      'pendingInProgressRevenue': pendingInProgressRevenue,
      'deliveredCount': deliveredCount,
      'inProgressCount': inProgressCount,
      'totalDeliveriesCount': totalDeliveriesCount,
      'currency': currency,
    };
  }
}

class RiderRevenueFiltersModel extends RiderRevenueFiltersEntity {
  const RiderRevenueFiltersModel({
    super.status,
    super.period,
    super.search,
  });

  factory RiderRevenueFiltersModel.fromJson(Map<String, dynamic> json) {
    return RiderRevenueFiltersModel(
      status: json['status']?.toString() ?? 'all',
      period: json['period']?.toString() ?? 'all',
      search: json['search']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'period': period,
      'search': search,
    };
  }
}

class RiderRevenueDataModel extends RiderRevenueDataEntity {
  const RiderRevenueDataModel({
    required super.summary,
    required super.filters,
    required super.count,
    required super.deliveries,
  });

  factory RiderRevenueDataModel.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final filtersMap = json['filters'] is Map<String, dynamic>
        ? json['filters'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawDeliveries = (json['deliveries'] as List?)
            ?.map((e) => RiderRevenueDeliveryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <RiderRevenueDeliveryModel>[];

    return RiderRevenueDataModel(
      summary: RiderRevenueSummaryModel.fromJson(summaryMap),
      filters: RiderRevenueFiltersModel.fromJson(filtersMap),
      count: (json['count'] as num?)?.toInt() ?? rawDeliveries.length,
      deliveries: rawDeliveries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': (summary as RiderRevenueSummaryModel).toJson(),
      'filters': (filters as RiderRevenueFiltersModel).toJson(),
      'count': count,
      'deliveries': deliveries.map((e) => (e as RiderRevenueDeliveryModel).toJson()).toList(),
    };
  }
}
