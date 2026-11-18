import '../../domain/entities/rider_revenue_entity.dart';
import 'rider_ledger_model.dart';

double _parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  return DateTime.tryParse(str);
}

class RiderBankDetailsModel extends RiderBankDetailsEntity {
  const RiderBankDetailsModel({
    super.paymentOption,
    super.preferredPayoutMethod,
    super.bankName,
    super.accountHolderName,
    super.accountNumber,
    super.mobileNumber,
    super.mobileMoneyOption,
  });

  factory RiderBankDetailsModel.fromJson(Map<String, dynamic> json) {
    return RiderBankDetailsModel(
      paymentOption: json['paymentOption']?.toString(),
      preferredPayoutMethod: json['preferredPayoutMethod']?.toString(),
      bankName: json['bankName']?.toString(),
      accountHolderName: json['accountHolderName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      mobileMoneyOption: json['mobileMoneyOption']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentOption': paymentOption,
      'preferredPayoutMethod': preferredPayoutMethod,
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'mobileNumber': mobileNumber,
      'mobileMoneyOption': mobileMoneyOption,
    };
  }
}

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
      quantity: _parseInt(json['quantity'], fallback: 1),
      price: _parseDouble(json['price']),
      shippingAmount: _parseDouble(json['shippingAmount']),
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
    super.paymentMethod,
    super.settlementStatus,
    super.codAmountCollected,
    super.payoutRequestedAt,
    super.payoutDisbursedAt,
    super.payoutReference,
    super.payoutMethod,
    super.payoutNote,
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
            ?.whereType<Map>()
            .map((e) => RevenueOrderItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        <RevenueOrderItemModel>[];

    final storeMap = json['store'] is Map
        ? Map<String, dynamic>.from(json['store'] as Map)
        : <String, dynamic>{};
    final customerMap = json['customer'] is Map
        ? Map<String, dynamic>.from(json['customer'] as Map)
        : <String, dynamic>{};

    final deliveryCharge = _parseDouble(json['deliveryCharge'] ?? json['deliveryFee']);
    final totalAmount = isDelivered
        ? (_parseNullableDouble(json['totalAmount']) ?? deliveryCharge)
        : null;

    return RiderRevenueDeliveryModel(
      id: json['id']?.toString() ?? json['assignmentId']?.toString() ?? '',
      assignmentId: json['assignmentId']?.toString() ?? json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: rawStatus,
      statusCategory: statusCat,
      isDelivered: isDelivered,
      paymentMethod: json['paymentMethod']?.toString().toUpperCase(),
      settlementStatus: json['settlementStatus']?.toString().toUpperCase(),
      codAmountCollected: _parseNullableDouble(json['codAmountCollected']),
      payoutRequestedAt: _parseDate(json['payoutRequestedAt']),
      payoutDisbursedAt: _parseDate(json['payoutDisbursedAt']),
      payoutReference: json['payoutReference']?.toString(),
      payoutMethod: json['payoutMethod']?.toString(),
      payoutNote: json['payoutNote']?.toString(),
      offeredAt: _parseDate(json['offeredAt']) ?? DateTime.now(),
      acceptedAt: _parseDate(json['acceptedAt']),
      pickedUpAt: _parseDate(json['pickedUpAt']),
      deliveredAt: _parseDate(json['deliveredAt']),
      deliveryOtp: json['deliveryOtp']?.toString(),
      deliveryProofImage: json['deliveryProofImage']?.toString(),
      distanceKm: _parseNullableDouble(json['distanceKm']),
      deliveryCharge: deliveryCharge,
      totalAmount: totalAmount,
      store: RevenueStoreModel.fromJson(storeMap),
      customer: RevenueCustomerModel.fromJson(customerMap),
      items: itemsList,
      totalItemsCount: _parseInt(
        json['totalItemsCount'],
        fallback: itemsList.isNotEmpty
            ? itemsList.fold(0, (sum, it) => sum + it.quantity)
            : 1,
      ),
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
      'paymentMethod': paymentMethod,
      'settlementStatus': settlementStatus,
      'codAmountCollected': codAmountCollected,
      'payoutRequestedAt': payoutRequestedAt?.toIso8601String(),
      'payoutDisbursedAt': payoutDisbursedAt?.toIso8601String(),
      'payoutReference': payoutReference,
      'payoutMethod': payoutMethod,
      'payoutNote': payoutNote,
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
    super.netBalance,
    super.availablePayoutBalance,
    required super.totalDeliveredRevenue,
    super.prepaidDeliveredRevenue,
    super.codDeliveredRevenue,
    super.codCashCollectedTotal,
    required super.pendingInProgressRevenue,
    required super.deliveredCount,
    required super.inProgressCount,
    required super.totalDeliveriesCount,
    super.currency,
    super.hasPendingPayoutRequest,
    super.pendingPayoutRequest,
  });

  factory RiderRevenueSummaryModel.fromJson(Map<String, dynamic> json) {
    final netBalance = _parseDouble(
      json['netBalance'] ?? json['availablePayoutBalance'],
    );
    final availablePayoutBalance = _parseDouble(
      json['availablePayoutBalance'],
      fallback: netBalance,
    );
    final pendingMap = json['pendingPayoutRequest'] is Map
        ? Map<String, dynamic>.from(json['pendingPayoutRequest'] as Map)
        : null;
    final pendingReq = pendingMap != null
        ? RiderPayoutRequestModel.fromJson(pendingMap)
        : null;

    return RiderRevenueSummaryModel(
      netBalance: netBalance,
      availablePayoutBalance: availablePayoutBalance,
      totalDeliveredRevenue: _parseDouble(json['totalDeliveredRevenue']),
      prepaidDeliveredRevenue: _parseDouble(json['prepaidDeliveredRevenue']),
      codDeliveredRevenue: _parseDouble(json['codDeliveredRevenue']),
      codCashCollectedTotal: _parseDouble(json['codCashCollectedTotal']),
      pendingInProgressRevenue: _parseDouble(json['pendingInProgressRevenue']),
      deliveredCount: _parseInt(json['deliveredCount']),
      inProgressCount: _parseInt(json['inProgressCount']),
      totalDeliveriesCount: _parseInt(json['totalDeliveriesCount']),
      currency: json['currency']?.toString() ?? 'NLe',
      hasPendingPayoutRequest:
          json['hasPendingPayoutRequest'] == true || pendingReq != null,
      pendingPayoutRequest: pendingReq,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netBalance': netBalance,
      'availablePayoutBalance': availablePayoutBalance,
      'totalDeliveredRevenue': totalDeliveredRevenue,
      'prepaidDeliveredRevenue': prepaidDeliveredRevenue,
      'codDeliveredRevenue': codDeliveredRevenue,
      'codCashCollectedTotal': codCashCollectedTotal,
      'pendingInProgressRevenue': pendingInProgressRevenue,
      'deliveredCount': deliveredCount,
      'inProgressCount': inProgressCount,
      'totalDeliveriesCount': totalDeliveriesCount,
      'currency': currency,
      'hasPendingPayoutRequest': hasPendingPayoutRequest,
      'pendingPayoutRequest': pendingPayoutRequest is RiderPayoutRequestModel
          ? (pendingPayoutRequest as RiderPayoutRequestModel).toJson()
          : null,
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
    super.riderBankDetails,
    required super.filters,
    required super.count,
    required super.deliveries,
  });

  factory RiderRevenueDataModel.fromJson(Map<String, dynamic> json) {
    final summaryMap = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : <String, dynamic>{};
    final bankDetailsMap = json['riderBankDetails'] is Map
        ? Map<String, dynamic>.from(json['riderBankDetails'] as Map)
        : null;
    final filtersMap = json['filters'] is Map
        ? Map<String, dynamic>.from(json['filters'] as Map)
        : <String, dynamic>{};

    final rawDeliveries = (json['deliveries'] as List?)
            ?.whereType<Map>()
            .map((e) => RiderRevenueDeliveryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        <RiderRevenueDeliveryModel>[];

    return RiderRevenueDataModel(
      summary: RiderRevenueSummaryModel.fromJson(summaryMap),
      riderBankDetails: bankDetailsMap != null
          ? RiderBankDetailsModel.fromJson(bankDetailsMap)
          : null,
      filters: RiderRevenueFiltersModel.fromJson(filtersMap),
      count: _parseInt(json['count'], fallback: rawDeliveries.length),
      deliveries: rawDeliveries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': (summary as RiderRevenueSummaryModel).toJson(),
      'riderBankDetails': riderBankDetails is RiderBankDetailsModel
          ? (riderBankDetails as RiderBankDetailsModel).toJson()
          : null,
      'filters': (filters as RiderRevenueFiltersModel).toJson(),
      'count': count,
      'deliveries': deliveries.map((e) => (e as RiderRevenueDeliveryModel).toJson()).toList(),
    };
  }
}
