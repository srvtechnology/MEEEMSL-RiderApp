import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/data/models/operating_zone_model.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';

void main() {
  const tZoneModel = OperatingZoneModel(
    id: 'zone_1',
    name: 'Downtown Commercial District',
    district: 'Central Zone',
    isSelected: true,
    surgeMultiplier: 1.2,
    activeRiders: 45,
  );

  test('OperatingZoneModel should be a subclass of OperatingZoneEntity', () {
    expect(tZoneModel, isA<OperatingZoneEntity>());
  });

  test('OperatingZoneModel fromJson & toJson works correctly', () {
    final json = {
      'id': 'zone_1',
      'name': 'Downtown Commercial District',
      'district': 'Central Zone',
      'isSelected': true,
      'surgeMultiplier': 1.2,
      'activeRiders': 45,
    };

    final model = OperatingZoneModel.fromJson(json);
    expect(model.id, 'zone_1');
    expect(model.surgeMultiplier, 1.2);
    expect(model.activeRiders, 45);

    final serialized = model.toJson();
    expect(serialized['name'], 'Downtown Commercial District');
  });
}
