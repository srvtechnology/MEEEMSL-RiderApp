import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/payout_info_model.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';

void main() {
  const tPayoutModel = PayoutInfoModel(
    paymentOption: PaymentOption.bank,
    preferredPayoutMethod: 'Bank Transfer',
    bankName: 'Sierra Leone Commercial Bank',
    branchName: 'Freetown Main',
    accountNumber: '9920184920',
    accountHolderName: 'Mohamed Kamara',
    bbanNumber: 'SL0010001000123456789',
    bankAddress: '15 Siaka Stevens St',
  );

  test('PayoutInfoModel should be a subclass of PayoutInfoEntity', () {
    expect(tPayoutModel, isA<PayoutInfoEntity>());
  });

  test('PayoutInfoModel fromJson & toJson works correctly for Bank', () {
    final json = {
      'paymentOption': 'Bank',
      'preferredPayoutMethod': 'Bank Transfer',
      'bankName': 'Rokel Commercial Bank',
      'branchName': 'Freetown Main',
      'accountNumber': '012345678901',
      'accountHolderName': 'Mohamed Kamara',
      'bbanNumber': 'SL0010001000123456789',
      'bankAddress': 'Freetown Central',
    };

    final model = PayoutInfoModel.fromJson(json);
    expect(model.paymentOption, PaymentOption.bank);
    expect(model.bankName, 'Rokel Commercial Bank');
    expect(model.branchName, 'Freetown Main');
    expect(model.accountNumber, '012345678901');
    expect(model.bbanNumber, 'SL0010001000123456789');

    final payload = model.toPayload();
    expect(payload['paymentOption'], 'Bank');
    expect(payload['preferredPayoutMethod'], 'Bank Transfer');
    expect(payload['bankName'], 'Rokel Commercial Bank');
    expect(payload['mobileMoneyOption'], isNull);
    expect(payload['mobileNumber'], isNull);
  });

  test('PayoutInfoModel fromJson & toPayload works correctly for Orange Money', () {
    final json = {
      'paymentOption': 'Orange Money',
      'preferredPayoutMethod': 'Mobile Wallet',
      'mobileMoneyOption': 'Orange Money',
      'mobileNumber': '+23276123456',
      'agentNumber': 'AG-9081',
    };

    final model = PayoutInfoModel.fromJson(json);
    expect(model.paymentOption, PaymentOption.orangeMoney);
    expect(model.mobileMoneyOption, 'Orange Money');
    expect(model.mobileNumber, '+23276123456');
    expect(model.agentNumber, 'AG-9081');

    final payload = model.toPayload();
    expect(payload['paymentOption'], 'Orange Money');
    expect(payload['preferredPayoutMethod'], 'Mobile Wallet');
    expect(payload['mobileMoneyOption'], 'Orange Money');
    expect(payload['mobileNumber'], '+23276123456');
    expect(payload['bankName'], isNull);
    expect(payload['accountNumber'], isNull);
  });

  test('PayoutInfoModel fromJson & toPayload works correctly for AfriMoney', () {
    final json = {
      'paymentOption': 'AfriMoney',
      'preferredPayoutMethod': 'Mobile Wallet',
      'mobileMoneyOption': 'AfriMoney',
      'mobileNumber': '+23277998877',
      'agentNumber': 'AF-1234',
    };

    final model = PayoutInfoModel.fromJson(json);
    expect(model.paymentOption, PaymentOption.afriMoney);
    expect(model.mobileMoneyOption, 'AfriMoney');
    expect(model.mobileNumber, '+23277998877');

    final payload = model.toPayload();
    expect(payload['paymentOption'], 'AfriMoney');
    expect(payload['bankName'], isNull);
  });

  test('PayoutInfoModel supports legacy JSON keys gracefully', () {
    final legacyBankJson = {
      'methodType': 'bank',
      'bankName': 'Chase Bank USA',
      'accountNumber': '9920184920',
      'accountHolder': 'Alex Johnson',
      'routingNumber': '021000021',
    };

    final bankModel = PayoutInfoModel.fromJson(legacyBankJson);
    expect(bankModel.paymentOption, PaymentOption.bank);
    expect(bankModel.methodType, PaymentOption.bank);
    expect(bankModel.bankName, 'Chase Bank USA');
    expect(bankModel.accountNumber, '9920184920');
    expect(bankModel.bbanNumber, '021000021');
    expect(bankModel.routingNumber, '021000021');

    final legacyMmJson = {
      'methodType': 'mobile_money',
      'provider': 'Orange Money',
      'phoneNumber': '+23276123456',
      'beneficiaryName': 'Alex Johnson',
    };

    final mmModel = PayoutInfoModel.fromJson(legacyMmJson);
    expect(mmModel.paymentOption, PaymentOption.orangeMoney);
    expect(mmModel.mobileNumber, '+23276123456');
    expect(mmModel.mobileMoneyNumber, '+23276123456');
  });
}
