import '../../domain/entities/payout_info_entity.dart';

class PayoutInfoModel extends PayoutInfoEntity {
  const PayoutInfoModel({
    required super.methodType,
    super.bankName,
    super.accountNumber,
    super.accountHolderName,
    super.routingNumber,
    super.mobileMoneyProvider,
    super.mobileMoneyNumber,
    super.beneficiaryName,
  });

  factory PayoutInfoModel.fromJson(Map<String, dynamic> json) {
    final methodStr = (json['methodType'] ?? json['type'] ?? 'bank').toString().toLowerCase();
    final methodType = methodStr.contains('mobile')
        ? PayoutMethodType.mobileMoney
        : PayoutMethodType.bank;

    return PayoutInfoModel(
      methodType: methodType,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolderName: json['accountHolderName'] ?? json['accountHolder'] as String?,
      routingNumber: json['routingNumber'] as String?,
      mobileMoneyProvider: json['mobileMoneyProvider'] ?? json['provider'] as String?,
      mobileMoneyNumber: json['mobileMoneyNumber'] ?? json['phoneNumber'] as String?,
      beneficiaryName: json['beneficiaryName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'methodType': methodType == PayoutMethodType.mobileMoney ? 'mobile_money' : 'bank',
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'routingNumber': routingNumber,
      'mobileMoneyProvider': mobileMoneyProvider,
      'mobileMoneyNumber': mobileMoneyNumber,
      'beneficiaryName': beneficiaryName,
    };
  }

  factory PayoutInfoModel.fromEntity(PayoutInfoEntity entity) {
    return PayoutInfoModel(
      methodType: entity.methodType,
      bankName: entity.bankName,
      accountNumber: entity.accountNumber,
      accountHolderName: entity.accountHolderName,
      routingNumber: entity.routingNumber,
      mobileMoneyProvider: entity.mobileMoneyProvider,
      mobileMoneyNumber: entity.mobileMoneyNumber,
      beneficiaryName: entity.beneficiaryName,
    );
  }
}
