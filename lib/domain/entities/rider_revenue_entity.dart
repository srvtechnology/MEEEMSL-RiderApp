import 'package:equatable/equatable.dart';

class RiderRevenueSummaryEntity extends Equatable {
  final double totalDeliveredRevenue;
  final double pendingInProgressRevenue;
  final int deliveredCount;
  final int inProgressCount;
  final int totalDeliveriesCount;
  final String currency;

  const RiderRevenueSummaryEntity({
    required this.totalDeliveredRevenue,
    required this.pendingInProgressRevenue,
    required this.deliveredCount,
    required this.inProgressCount,
    required this.totalDeliveriesCount,
    this.currency = 'NLe',
  });

  @override
  List<Object?> get props => [
        totalDeliveredRevenue,
        pendingInProgressRevenue,
        deliveredCount,
        inProgressCount,
        totalDeliveriesCount,
        currency,
      ];
}

class RevenueOrderItemEntity extends Equatable {
  final String id;
  final String? productId;
  final String name;
  final String? variantName;
  final int quantity;
  final double price;
  final double shippingAmount;
  final String? image;

  const RevenueOrderItemEntity({
    required this.id,
    this.productId,
    required this.name,
    this.variantName,
    required this.quantity,
    required this.price,
    required this.shippingAmount,
    this.image,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        variantName,
        quantity,
        price,
        shippingAmount,
        image,
      ];
}

class RevenueStoreEntity extends Equatable {
  final String? id;
  final String name;
  final String? phone;
  final String address;

  const RevenueStoreEntity({
    this.id,
    required this.name,
    this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, address];
}

class RevenueCustomerEntity extends Equatable {
  final String? id;
  final String name;
  final String? phone;
  final String dropAddress;

  const RevenueCustomerEntity({
    this.id,
    required this.name,
    this.phone,
    required this.dropAddress,
  });

  @override
  List<Object?> get props => [id, name, phone, dropAddress];
}

class RiderRevenueDeliveryEntity extends Equatable {
  final String id;
  final String assignmentId;
  final String orderId;
  final String orderNumber;
  final String status;
  final String statusCategory; // 'DELIVERED' | 'IN_PROGRESS'
  final bool isDelivered;
  final DateTime offeredAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? deliveryOtp;
  final String? deliveryProofImage;
  final double? distanceKm;
  final double deliveryCharge;
  final double? totalAmount; // null when in progress, number when delivered
  final RevenueStoreEntity store;
  final RevenueCustomerEntity customer;
  final List<RevenueOrderItemEntity> items;
  final int totalItemsCount;

  const RiderRevenueDeliveryEntity({
    required this.id,
    required this.assignmentId,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.statusCategory,
    required this.isDelivered,
    required this.offeredAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.deliveryOtp,
    this.deliveryProofImage,
    this.distanceKm,
    required this.deliveryCharge,
    this.totalAmount,
    required this.store,
    required this.customer,
    required this.items,
    required this.totalItemsCount,
  });

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        orderId,
        orderNumber,
        status,
        statusCategory,
        isDelivered,
        offeredAt,
        acceptedAt,
        pickedUpAt,
        deliveredAt,
        deliveryOtp,
        deliveryProofImage,
        distanceKm,
        deliveryCharge,
        totalAmount,
        store,
        customer,
        items,
        totalItemsCount,
      ];
}

class RiderRevenueFiltersEntity extends Equatable {
  final String status;
  final String period;
  final String search;

  const RiderRevenueFiltersEntity({
    this.status = 'all',
    this.period = 'all',
    this.search = '',
  });

  @override
  List<Object?> get props => [status, period, search];
}

class RiderRevenueDataEntity extends Equatable {
  final RiderRevenueSummaryEntity summary;
  final RiderRevenueFiltersEntity filters;
  final int count;
  final List<RiderRevenueDeliveryEntity> deliveries;

  const RiderRevenueDataEntity({
    required this.summary,
    required this.filters,
    required this.count,
    required this.deliveries,
  });

  @override
  List<Object?> get props => [summary, filters, count, deliveries];
}
