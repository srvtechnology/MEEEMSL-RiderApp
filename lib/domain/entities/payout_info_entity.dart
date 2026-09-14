import 'package:equatable/equatable.dart';

enum PaymentOption {
  bank,
  orangeMoney,
  afriMoney;

  String get apiValue {
    switch (this) {
      case PaymentOption.bank:
        return 'Bank';
      case PaymentOption.orangeMoney:
        return 'Orange Money';
      case PaymentOption.afriMoney:
        return 'AfriMoney';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentOption.bank:
        return 'Bank';
      case PaymentOption.orangeMoney:
        return 'Orange Money';
      case PaymentOption.afriMoney:
        return 'AfriMoney';
    }
  }

  static PaymentOption fromString(String? val) {
    if (val == null) return PaymentOption.bank;
    final normalized = val.trim().toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
    if (normalized == 'orangemoney' || normalized == 'orange') {
      return PaymentOption.orangeMoney;
    }
    if (normalized == 'afrimoney' || normalized == 'afri') {
      return PaymentOption.afriMoney;
    }
    if (normalized.contains('mobile')) {
      return PaymentOption.orangeMoney;
    }
    return PaymentOption.bank;
  }
}

/// Alias for backwards compatibility during migration.
typedef PayoutMethodType = PaymentOption;

class PayoutInfoEntity extends Equatable {
  final PaymentOption paymentOption;
  final String? preferredPayoutMethod;
  final String? bankName;
  final String? bankAddress;
  final String? accountHolderName;
  final String? accountNumber;
  final String? bbanNumber;
  final String? branchName;
  final String? mobileMoneyOption;
  final String? mobileNumber;
  final String? agentNumber;

  const PayoutInfoEntity({
    this.paymentOption = PaymentOption.bank,
    this.preferredPayoutMethod,
    this.bankName,
    this.bankAddress,
    this.accountHolderName,
    this.accountNumber,
    this.bbanNumber,
    this.branchName,
    this.mobileMoneyOption,
    this.mobileNumber,
    this.agentNumber,
  });

  /// Alias for backward compatibility
  PaymentOption get methodType => paymentOption;
  String? get routingNumber => bbanNumber;
  String? get mobileMoneyProvider => mobileMoneyOption ?? (paymentOption != PaymentOption.bank ? paymentOption.apiValue : null);
  String? get mobileMoneyNumber => mobileNumber;
  String? get beneficiaryName => accountHolderName;

  bool get isBank => paymentOption == PaymentOption.bank;
  bool get isOrangeMoney => paymentOption == PaymentOption.orangeMoney;
  bool get isAfriMoney => paymentOption == PaymentOption.afriMoney;
  bool get isMobileMoney => isOrangeMoney || isAfriMoney;

  String get displayName {
    if (paymentOption == PaymentOption.bank) {
      final acc = accountNumber != null && accountNumber!.length > 4
          ? accountNumber!.substring(accountNumber!.length - 4)
          : accountNumber ?? '';
      return '${bankName ?? "Bank"} •••• $acc';
    } else {
      final opt = paymentOption == PaymentOption.orangeMoney ? 'Orange Money' : 'AfriMoney';
      return '$opt • ${mobileNumber ?? ''}';
    }
  }

  PayoutInfoEntity copyWith({
    PaymentOption? paymentOption,
    String? preferredPayoutMethod,
    String? bankName,
    String? bankAddress,
    String? accountHolderName,
    String? accountNumber,
    String? bbanNumber,
    String? branchName,
    String? mobileMoneyOption,
    String? mobileNumber,
    String? agentNumber,
  }) {
    return PayoutInfoEntity(
      paymentOption: paymentOption ?? this.paymentOption,
      preferredPayoutMethod: preferredPayoutMethod ?? this.preferredPayoutMethod,
      bankName: bankName ?? this.bankName,
      bankAddress: bankAddress ?? this.bankAddress,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      bbanNumber: bbanNumber ?? this.bbanNumber,
      branchName: branchName ?? this.branchName,
      mobileMoneyOption: mobileMoneyOption ?? this.mobileMoneyOption,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      agentNumber: agentNumber ?? this.agentNumber,
    );
  }

  @override
  List<Object?> get props => [
        paymentOption,
        preferredPayoutMethod,
        bankName,
        bankAddress,
        accountHolderName,
        accountNumber,
        bbanNumber,
        branchName,
        mobileMoneyOption,
        mobileNumber,
        agentNumber,
      ];
}
