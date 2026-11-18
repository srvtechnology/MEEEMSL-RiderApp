import 'package:equatable/equatable.dart';
import 'rider_ledger_entity.dart';

class RiderBankDetailsEntity extends Equatable {
  final String? paymentOption;
  final String? preferredPayoutMethod;
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final String? mobileNumber;
  final String? mobileMoneyOption;

  const RiderBankDetailsEntity({
    this.paymentOption,
    this.preferredPayoutMethod,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.mobileNumber,
    this.mobileMoneyOption,
  });

  bool get hasConfiguredDetails =>
      (preferredPayoutMethod?.trim().isNotEmpty ?? false) ||
      (paymentOption?.trim().isNotEmpty ?? false) ||
      (bankName?.trim().isNotEmpty ?? false) ||
      (accountNumber?.trim().isNotEmpty ?? false) ||
      (mobileNumber?.trim().isNotEmpty ?? false);

  String get displayMethod {
    if (preferredPayoutMethod != null && preferredPayoutMethod!.trim().isNotEmpty) {
      return preferredPayoutMethod!.trim();
    }
    if (mobileMoneyOption != null && mobileMoneyOption!.trim().isNotEmpty) {
      return mobileMoneyOption!.trim();
    }
    if (bankName != null && bankName!.trim().isNotEmpty) {
      return bankName!.trim();
    }
    if (paymentOption != null && paymentOption!.trim().isNotEmpty) {
      return paymentOption!.trim();
    }
    return 'Not Configured';
  }

  String get formattedSnapshot {
    final parts = <String>[];
    if (paymentOption != null && paymentOption!.trim().isNotEmpty) {
      parts.add('Method: ${paymentOption!.trim()}');
    }
    if (accountHolderName != null && accountHolderName!.trim().isNotEmpty) {
      parts.add('Holder: ${accountHolderName!.trim()}');
    }
    if (bankName != null && bankName!.trim().isNotEmpty) {
      parts.add('Bank: ${bankName!.trim()}');
    }
    if (accountNumber != null && accountNumber!.trim().isNotEmpty) {
      parts.add('Acc: ${accountNumber!.trim()}');
    }
    if (mobileNumber != null && mobileNumber!.trim().isNotEmpty) {
      parts.add('Mobile: ${mobileNumber!.trim()}');
    }
    if (mobileMoneyOption != null && mobileMoneyOption!.trim().isNotEmpty) {
      parts.add('Wallet: ${mobileMoneyOption!.trim()}');
    }
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        paymentOption,
        preferredPayoutMethod,
        bankName,
        accountHolderName,
        accountNumber,
        mobileNumber,
        mobileMoneyOption,
      ];
}

class RiderRevenueSummaryEntity extends Equatable {
  final double netBalance;
  final double availablePayoutBalance;
  final double totalDeliveredRevenue;
  final double prepaidDeliveredRevenue;
  final double codDeliveredRevenue;
  final double codCashCollectedTotal;
  final double pendingInProgressRevenue;
  final int deliveredCount;
  final int inProgressCount;
  final int totalDeliveriesCount;
  final String currency;
  final bool hasPendingPayoutRequest;
  final RiderPayoutRequestEntity? pendingPayoutRequest;

  const RiderRevenueSummaryEntity({
    this.netBalance = 0.0,
    double? availablePayoutBalance,
    required this.totalDeliveredRevenue,
    this.prepaidDeliveredRevenue = 0.0,
    this.codDeliveredRevenue = 0.0,
    this.codCashCollectedTotal = 0.0,
    required this.pendingInProgressRevenue,
    required this.deliveredCount,
    required this.inProgressCount,
    required this.totalDeliveriesCount,
    this.currency = 'NLe',
    this.hasPendingPayoutRequest = false,
    this.pendingPayoutRequest,
  }) : availablePayoutBalance = availablePayoutBalance ?? netBalance;

  double get withdrawableBalance =>
      availablePayoutBalance > 0 ? availablePayoutBalance : netBalance;

  @override
  List<Object?> get props => [
        netBalance,
        availablePayoutBalance,
        totalDeliveredRevenue,
        prepaidDeliveredRevenue,
        codDeliveredRevenue,
        codCashCollectedTotal,
        pendingInProgressRevenue,
        deliveredCount,
        inProgressCount,
        totalDeliveriesCount,
        currency,
        hasPendingPayoutRequest,
        pendingPayoutRequest,
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
  final String? paymentMethod; // 'AFRIMONEY' | 'COD'
  final String? settlementStatus; // 'PENDING' | 'YET_TO_PAY' | 'PAID_OUT' | 'COD_COLLECTED_BY_RIDER'
  final double? codAmountCollected;
  final DateTime? payoutRequestedAt;
  final DateTime? payoutDisbursedAt;
  final String? payoutReference;
  final String? payoutMethod;
  final String? payoutNote;
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
    this.paymentMethod,
    this.settlementStatus,
    this.codAmountCollected,
    this.payoutRequestedAt,
    this.payoutDisbursedAt,
    this.payoutReference,
    this.payoutMethod,
    this.payoutNote,
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

  bool get isPrepaid => (paymentMethod ?? '').toUpperCase() == 'AFRIMONEY';
  bool get isCod =>
      (paymentMethod ?? '').toUpperCase() == 'COD' ||
      (settlementStatus ?? '').toUpperCase() == 'COD_COLLECTED_BY_RIDER';

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        orderId,
        orderNumber,
        status,
        statusCategory,
        isDelivered,
        paymentMethod,
        settlementStatus,
        codAmountCollected,
        payoutRequestedAt,
        payoutDisbursedAt,
        payoutReference,
        payoutMethod,
        payoutNote,
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
  final RiderBankDetailsEntity? riderBankDetails;
  final RiderRevenueFiltersEntity filters;
  final int count;
  final List<RiderRevenueDeliveryEntity> deliveries;

  const RiderRevenueDataEntity({
    required this.summary,
    this.riderBankDetails,
    required this.filters,
    required this.count,
    required this.deliveries,
  });

  @override
  List<Object?> get props => [summary, riderBankDetails, filters, count, deliveries];
}
