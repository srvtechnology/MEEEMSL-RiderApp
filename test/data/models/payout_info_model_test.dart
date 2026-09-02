import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/payout_info_model.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';

void main() {
  const tPayoutModel = PayoutInfoModel(
    methodType: PayoutMethodType.bank,
    bankName: 'Chase Bank USA',
    accountNumber: '9920184920',
    accountHolderName: 'Alex Johnson',
    routingNumber: '021000021',
  );

  test('PayoutInfoModel should be a subclass of PayoutInfoEntity', () {
    expect(tPayoutModel, isA<PayoutInfoEntity>());
  });

  test('PayoutInfoModel fromJson & toJson works correctly for bank', () {
    final json = {
      'methodType': 'bank',
      'bankName': 'Chase Bank USA',
      'accountNumber': '9920184920',
      'accountHolderName': 'Alex Johnson',
      'routingNumber': '021000021',
    };

    final model = PayoutInfoModel.fromJson(json);
    expect(model.methodType, PayoutMethodType.bank);
    expect(model.bankName, 'Chase Bank USA');
    expect(model.accountNumber, '9920184920');

    final serialized = model.toJson();
    expect(serialized['methodType'], 'bank');
    expect(serialized['bankName'], 'Chase Bank USA');
  });

  test('PayoutInfoModel fromJson & toJson works correctly for mobile money', () {
    final json = {
      'methodType': 'mobile_money',
      'mobileMoneyProvider': 'M-Pesa',
      'mobileMoneyNumber': '+1 555 234 5678',
      'beneficiaryName': 'Alex Johnson',
    };

    final model = PayoutInfoModel.fromJson(json);
    expect(model.methodType, PayoutMethodType.mobileMoney);
    expect(model.mobileMoneyProvider, 'M-Pesa');
    expect(model.mobileMoneyNumber, '+1 555 234 5678');
  });
}
