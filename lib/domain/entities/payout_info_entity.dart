import 'package:equatable/equatable.dart';

enum PayoutMethodType {
  bank,
  mobileMoney,
}

class PayoutInfoEntity extends Equatable {
  final PayoutMethodType methodType;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? routingNumber;
  final String? mobileMoneyProvider;
  final String? mobileMoneyNumber;
  final String? beneficiaryName;

  const PayoutInfoEntity({
    required this.methodType,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.routingNumber,
    this.mobileMoneyProvider,
    this.mobileMoneyNumber,
    this.beneficiaryName,
  });

  String get displayName {
    if (methodType == PayoutMethodType.bank) {
      return '$bankName •••• ${accountNumber != null && accountNumber!.length > 4 ? accountNumber!.substring(accountNumber!.length - 4) : accountNumber ?? ''}';
    } else {
      return '$mobileMoneyProvider • ${mobileMoneyNumber ?? ''}';
    }
  }

  @override
  List<Object?> get props => [
        methodType,
        bankName,
        accountNumber,
        accountHolderName,
        routingNumber,
        mobileMoneyProvider,
        mobileMoneyNumber,
        beneficiaryName,
      ];
}
