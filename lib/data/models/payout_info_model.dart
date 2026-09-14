import '../../domain/entities/payout_info_entity.dart';

class PayoutInfoModel extends PayoutInfoEntity {
  const PayoutInfoModel({
    PaymentOption paymentOption = PaymentOption.bank,
    super.preferredPayoutMethod,
    super.bankName,
    super.bankAddress,
    String? accountHolderName,
    super.accountNumber,
    String? bbanNumber,
    super.branchName,
    String? mobileMoneyOption,
    String? mobileNumber,
    super.agentNumber,
    // Support legacy named parameter during migration
    PaymentOption? methodType,
    String? routingNumber,
    String? mobileMoneyProvider,
    String? mobileMoneyNumber,
    String? beneficiaryName,
  }) : super(
          paymentOption: methodType ?? paymentOption,
          bbanNumber: bbanNumber ?? routingNumber,
          mobileMoneyOption: mobileMoneyOption ?? mobileMoneyProvider,
          mobileNumber: mobileNumber ?? mobileMoneyNumber,
          accountHolderName: accountHolderName ?? beneficiaryName,
        );

  factory PayoutInfoModel.fromJson(Map<String, dynamic> json) {
    final rawOption = json['paymentOption'] ??
        json['mobileMoneyOption'] ??
        json['methodType'] ??
        json['type'];
    final paymentOption = PaymentOption.fromString(rawOption?.toString());

    final preferredPayoutMethod = json['preferredPayoutMethod'] as String? ??
        (paymentOption == PaymentOption.bank ? 'Bank Transfer' : 'Mobile Wallet');

    final mobileMoneyOption = json['mobileMoneyOption'] as String? ??
        (paymentOption != PaymentOption.bank ? paymentOption.apiValue : null);

    return PayoutInfoModel(
      paymentOption: paymentOption,
      preferredPayoutMethod: preferredPayoutMethod,
      bankName: json['bankName'] as String?,
      bankAddress: json['bankAddress'] as String?,
      accountHolderName:
          (json['accountHolderName'] ?? json['accountHolder'] ?? json['beneficiaryName']) as String?,
      accountNumber: json['accountNumber'] as String?,
      bbanNumber:
          (json['bbanNumber'] ?? json['bban'] ?? json['routingNumber']) as String?,
      branchName: json['branchName'] as String?,
      mobileMoneyOption: mobileMoneyOption,
      mobileNumber: (json['mobileNumber'] ??
          json['mobileMoneyNumber'] ??
          json['phoneNumber'] ??
          json['phone']) as String?,
      agentNumber: json['agentNumber'] as String?,
    );
  }

  /// Implements API Doc Section 3 & 7 rules for backend submission payloads
  /// Clears opposing channel fields to prevent conflicting payout states.
  Map<String, dynamic> toPayload() {
    if (paymentOption == PaymentOption.bank) {
      return {
        'paymentOption': 'Bank',
        'preferredPayoutMethod': 'Bank Transfer',
        'bankName': bankName,
        'bankAddress': bankAddress,
        'accountHolderName': accountHolderName,
        'accountNumber': accountNumber,
        'bbanNumber': bbanNumber,
        'branchName': branchName,
        'mobileMoneyOption': null,
        'mobileNumber': null,
        'agentNumber': null,
      };
    } else {
      final opt = paymentOption.apiValue;
      return {
        'paymentOption': opt,
        'preferredPayoutMethod': 'Mobile Wallet',
        'mobileMoneyOption': opt,
        'mobileNumber': mobileNumber,
        'agentNumber': agentNumber,
        'bankName': null,
        'bankAddress': null,
        'accountHolderName': null,
        'accountNumber': null,
        'bbanNumber': null,
        'branchName': null,
      };
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentOption': paymentOption.apiValue,
      'preferredPayoutMethod': preferredPayoutMethod ??
          (paymentOption == PaymentOption.bank ? 'Bank Transfer' : 'Mobile Wallet'),
      'bankName': bankName,
      'bankAddress': bankAddress,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'bbanNumber': bbanNumber,
      'branchName': branchName,
      'mobileMoneyOption': mobileMoneyOption,
      'mobileNumber': mobileNumber,
      'agentNumber': agentNumber,
      // Backward compatibility keys
      'methodType': paymentOption == PaymentOption.bank ? 'bank' : 'mobile_money',
      'routingNumber': bbanNumber,
      'mobileMoneyProvider': mobileMoneyOption,
      'mobileMoneyNumber': mobileNumber,
      'beneficiaryName': accountHolderName,
    };
  }

  factory PayoutInfoModel.fromEntity(PayoutInfoEntity entity) {
    return PayoutInfoModel(
      paymentOption: entity.paymentOption,
      preferredPayoutMethod: entity.preferredPayoutMethod,
      bankName: entity.bankName,
      bankAddress: entity.bankAddress,
      accountHolderName: entity.accountHolderName,
      accountNumber: entity.accountNumber,
      bbanNumber: entity.bbanNumber,
      branchName: entity.branchName,
      mobileMoneyOption: entity.mobileMoneyOption,
      mobileNumber: entity.mobileNumber,
      agentNumber: entity.agentNumber,
    );
  }
}
