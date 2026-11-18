import 'package:equatable/equatable.dart';

/// Represents a single immutable ledger entry from `RiderBalanceTransaction`.
/// Conforms to Section 2C & Section 5 of the Rider Payment Ledger Guide.
class RiderBalanceTransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String kind; // 'CREDIT' | 'DEBIT'
  final String reason; // 'DELIVERY_FULFILLED' | 'COD_DELIVERY_COLLECTED' | 'PAYOUT_DISBURSED'
  final String? note;
  final DateTime createdAt;
  final String? assignmentId;
  final String? orderId;
  final String? orderNumber;
  final String? paymentMethod; // 'AFRIMONEY' | 'COD' | null
  final String? settlementStatus; // 'YET_TO_PAY' | 'PAID_OUT' | 'COD_COLLECTED_BY_RIDER' | null

  const RiderBalanceTransactionEntity({
    required this.id,
    required this.amount,
    required this.kind,
    required this.reason,
    this.note,
    required this.createdAt,
    this.assignmentId,
    this.orderId,
    this.orderNumber,
    this.paymentMethod,
    this.settlementStatus,
  });

  bool get isCredit => kind.toUpperCase() == 'CREDIT';
  bool get isDebit => kind.toUpperCase() == 'DEBIT';
  bool get isPrepaidDelivery => reason.toUpperCase() == 'DELIVERY_FULFILLED';
  bool get isCodCollected => reason.toUpperCase() == 'COD_DELIVERY_COLLECTED';
  bool get isPayoutDisbursed => reason.toUpperCase() == 'PAYOUT_DISBURSED';

  /// True if this transaction actually changed `Rider.netBalance`.
  /// COD_DELIVERY_COLLECTED is recorded for audit visibility with 0 netBalance change.
  bool get affectsWalletBalance => !isCodCollected;

  @override
  List<Object?> get props => [
        id,
        amount,
        kind,
        reason,
        note,
        createdAt,
        assignmentId,
        orderId,
        orderNumber,
        paymentMethod,
        settlementStatus,
      ];
}

/// Aggregated response entity for `GET /mobileapi/rider/balance-transactions`.
class RiderBalanceLedgerEntity extends Equatable {
  final double netBalance;
  final double balanceCreditsTotal;
  final double balanceDebitsTotal;
  final List<RiderBalanceTransactionEntity> transactions;

  const RiderBalanceLedgerEntity({
    required this.netBalance,
    required this.balanceCreditsTotal,
    required this.balanceDebitsTotal,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
        netBalance,
        balanceCreditsTotal,
        balanceDebitsTotal,
        transactions,
      ];
}

/// Represents a payout withdrawal request (`SellerPayoutRequest` with `sellerSector = "RIDER"`).
/// Conforms to Section 6 of the Rider Payment Ledger Guide.
class RiderPayoutRequestEntity extends Equatable {
  final String id;
  final String sellerSector;
  final String sellerId;
  final double requestedAmount;
  final String status; // 'PENDING' | 'DISBURSED' | 'REJECTED'
  final String? sellerNote;
  final String? payoutMethod;
  final String? payoutAccountSnapshot;
  final String? payoutReference;
  final String? adminNote;
  final DateTime requestedAt;
  final DateTime? disbursedAt;

  const RiderPayoutRequestEntity({
    required this.id,
    this.sellerSector = 'RIDER',
    this.sellerId = '',
    required this.requestedAmount,
    required this.status,
    this.sellerNote,
    this.payoutMethod,
    this.payoutAccountSnapshot,
    this.payoutReference,
    this.adminNote,
    required this.requestedAt,
    this.disbursedAt,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isDisbursed => status.toUpperCase() == 'DISBURSED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  @override
  List<Object?> get props => [
        id,
        sellerSector,
        sellerId,
        requestedAmount,
        status,
        sellerNote,
        payoutMethod,
        payoutAccountSnapshot,
        payoutReference,
        adminNote,
        requestedAt,
        disbursedAt,
      ];
}

/// Aggregated response entity for `GET /mobileapi/rider/payout-requests`.
class RiderPayoutStatusEntity extends Equatable {
  final double netBalance;
  final String? payoutMethod;
  final String? payoutAccountSnapshot;
  final RiderPayoutRequestEntity? pendingRequest;
  final List<RiderPayoutRequestEntity> history;

  const RiderPayoutStatusEntity({
    required this.netBalance,
    this.payoutMethod,
    this.payoutAccountSnapshot,
    this.pendingRequest,
    required this.history,
  });

  bool get hasPendingRequest =>
      pendingRequest != null || history.any((req) => req.isPending);

  RiderPayoutRequestEntity? get effectivePendingRequest {
    if (pendingRequest != null) return pendingRequest;
    for (final req in history) {
      if (req.isPending) return req;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        netBalance,
        payoutMethod,
        payoutAccountSnapshot,
        pendingRequest,
        history,
      ];
}
