import '../../domain/entities/rider_ledger_entity.dart';

double _parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty) return null;
  return DateTime.tryParse(str);
}

class RiderBalanceTransactionModel extends RiderBalanceTransactionEntity {
  const RiderBalanceTransactionModel({
    required super.id,
    required super.amount,
    required super.kind,
    required super.reason,
    super.note,
    required super.createdAt,
    super.assignmentId,
    super.orderId,
    super.orderNumber,
    super.paymentMethod,
    super.settlementStatus,
  });

  factory RiderBalanceTransactionModel.fromJson(Map<String, dynamic> json) {
    return RiderBalanceTransactionModel(
      id: json['id']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      kind: json['kind']?.toString().toUpperCase() ?? 'CREDIT',
      reason: json['reason']?.toString().toUpperCase() ?? 'DELIVERY_FULFILLED',
      note: json['note']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      assignmentId: json['assignmentId']?.toString(),
      orderId: json['orderId']?.toString(),
      orderNumber: json['orderNumber']?.toString(),
      paymentMethod: json['paymentMethod']?.toString().toUpperCase(),
      settlementStatus: json['settlementStatus']?.toString().toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'kind': kind,
      'reason': reason,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'assignmentId': assignmentId,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'paymentMethod': paymentMethod,
      'settlementStatus': settlementStatus,
    };
  }
}

class RiderBalanceLedgerModel extends RiderBalanceLedgerEntity {
  const RiderBalanceLedgerModel({
    required super.netBalance,
    required super.balanceCreditsTotal,
    required super.balanceDebitsTotal,
    required super.transactions,
  });

  factory RiderBalanceLedgerModel.fromJson(Map<String, dynamic> json) {
    final rawList = (json['transactions'] as List?) ??
        (json['recentTransactions'] as List?) ??
        const [];
    final transactions = rawList
        .whereType<Map>()
        .map((e) => RiderBalanceTransactionModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    return RiderBalanceLedgerModel(
      netBalance: _parseDouble(json['netBalance']),
      balanceCreditsTotal: _parseDouble(json['balanceCreditsTotal']),
      balanceDebitsTotal: _parseDouble(json['balanceDebitsTotal']),
      transactions: transactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netBalance': netBalance,
      'balanceCreditsTotal': balanceCreditsTotal,
      'balanceDebitsTotal': balanceDebitsTotal,
      'transactions': transactions
          .map((e) => e is RiderBalanceTransactionModel
              ? e.toJson()
              : {
                  'id': e.id,
                  'amount': e.amount,
                  'kind': e.kind,
                  'reason': e.reason,
                  'note': e.note,
                  'createdAt': e.createdAt.toIso8601String(),
                  'assignmentId': e.assignmentId,
                  'orderId': e.orderId,
                  'orderNumber': e.orderNumber,
                  'paymentMethod': e.paymentMethod,
                  'settlementStatus': e.settlementStatus,
                })
          .toList(),
    };
  }
}

class RiderPayoutRequestModel extends RiderPayoutRequestEntity {
  const RiderPayoutRequestModel({
    required super.id,
    super.sellerSector,
    super.sellerId,
    required super.requestedAmount,
    required super.status,
    super.sellerNote,
    super.payoutMethod,
    super.payoutAccountSnapshot,
    super.payoutReference,
    super.adminNote,
    required super.requestedAt,
    super.disbursedAt,
  });

  factory RiderPayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return RiderPayoutRequestModel(
      id: json['id']?.toString() ?? '',
      sellerSector: json['sellerSector']?.toString() ?? 'RIDER',
      sellerId: json['sellerId']?.toString() ?? '',
      requestedAmount: _parseDouble(
        json['requestedAmount'] ?? json['amount'],
      ),
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      sellerNote: json['sellerNote']?.toString(),
      payoutMethod: json['payoutMethod']?.toString(),
      payoutAccountSnapshot: json['payoutAccountSnapshot']?.toString(),
      payoutReference: json['payoutReference']?.toString(),
      adminNote: json['adminNote']?.toString(),
      requestedAt:
          _parseDate(json['requestedAt'] ?? json['createdAt']) ?? DateTime.now(),
      disbursedAt: _parseDate(json['disbursedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerSector': sellerSector,
      'sellerId': sellerId,
      'requestedAmount': requestedAmount,
      'status': status,
      'sellerNote': sellerNote,
      'payoutMethod': payoutMethod,
      'payoutAccountSnapshot': payoutAccountSnapshot,
      'payoutReference': payoutReference,
      'adminNote': adminNote,
      'requestedAt': requestedAt.toIso8601String(),
      'disbursedAt': disbursedAt?.toIso8601String(),
    };
  }
}

class RiderPayoutStatusModel extends RiderPayoutStatusEntity {
  const RiderPayoutStatusModel({
    required super.netBalance,
    super.payoutMethod,
    super.payoutAccountSnapshot,
    super.pendingRequest,
    required super.history,
  });

  factory RiderPayoutStatusModel.fromJson(Map<String, dynamic> json) {
    final pendingMap = json['pendingRequest'] is Map
        ? Map<String, dynamic>.from(json['pendingRequest'] as Map)
        : null;
    final rawHistory = (json['history'] as List?) ??
        (json['requests'] as List?) ??
        const [];
    final history = rawHistory
        .whereType<Map>()
        .map((e) => RiderPayoutRequestModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    return RiderPayoutStatusModel(
      netBalance: _parseDouble(json['netBalance']),
      payoutMethod: json['payoutMethod']?.toString(),
      payoutAccountSnapshot: json['payoutAccountSnapshot']?.toString(),
      pendingRequest: pendingMap != null
          ? RiderPayoutRequestModel.fromJson(pendingMap)
          : null,
      history: history,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netBalance': netBalance,
      'payoutMethod': payoutMethod,
      'payoutAccountSnapshot': payoutAccountSnapshot,
      'pendingRequest': pendingRequest is RiderPayoutRequestModel
          ? (pendingRequest as RiderPayoutRequestModel).toJson()
          : null,
      'history': history
          .map((e) => e is RiderPayoutRequestModel
              ? e.toJson()
              : {
                  'id': e.id,
                  'sellerSector': e.sellerSector,
                  'sellerId': e.sellerId,
                  'requestedAmount': e.requestedAmount,
                  'status': e.status,
                  'sellerNote': e.sellerNote,
                  'payoutMethod': e.payoutMethod,
                  'payoutAccountSnapshot': e.payoutAccountSnapshot,
                  'payoutReference': e.payoutReference,
                  'adminNote': e.adminNote,
                  'requestedAt': e.requestedAt.toIso8601String(),
                  'disbursedAt': e.disbursedAt?.toIso8601String(),
                })
          .toList(),
    };
  }
}
