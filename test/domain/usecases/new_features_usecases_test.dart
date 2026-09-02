import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/operating_zone_entity.dart';
import 'package:meeem_rider/domain/entities/payout_info_entity.dart';
import 'package:meeem_rider/domain/entities/vehicle_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/repositories/profile_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/login_with_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/reset_password_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_operating_zones_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_operating_zones_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/get_payout_info_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_payout_info_usecase.dart';
import 'package:meeem_rider/domain/usecases/profile/update_vehicle_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProfileRepository = MockProfileRepository();
  });

  const tRider = RiderEntity(
    id: 'rider_1',
    name: 'Alex Johnson',
    phone: '+1 555 234 5678',
    email: 'alex@example.com',
    avatar: '',
    rating: 4.9,
    totalTrips: 1420,
    isOnline: true,
    walletBalance: 150.0,
    approvalStatus: 'approved',
  );

  group('Authentication & Password Reset UseCases', () {
    test('LoginWithPasswordUseCase should call repository.loginWithPassword', () async {
      final useCase = LoginWithPasswordUseCase(mockAuthRepository);
      when(() => mockAuthRepository.loginWithPassword('alex@example.com', 'secret123'))
          .thenAnswer((_) async => const Right(tRider));

      final result = await useCase('alex@example.com', 'secret123');
      expect(result, const Right(tRider));
      verify(() => mockAuthRepository.loginWithPassword('alex@example.com', 'secret123')).called(1);
    });

    test('ResetPasswordUseCase sendResetCode & confirmReset', () async {
      final useCase = ResetPasswordUseCase(mockAuthRepository);
      when(() => mockAuthRepository.forgotPassword('alex@example.com'))
          .thenAnswer((_) async => const Right(true));
      when(() => mockAuthRepository.resetPassword('alex@example.com', '4920', 'newpass123'))
          .thenAnswer((_) async => const Right(true));

      final sendResult = await useCase.sendResetCode('alex@example.com');
      expect(sendResult, const Right(true));

      final confirmResult = await useCase.confirmReset('alex@example.com', '4920', 'newpass123');
      expect(confirmResult, const Right(true));
    });
  });

  group('Operating Zones UseCases', () {
    const tZones = [
      OperatingZoneEntity(
        id: 'zone_1',
        name: 'Downtown Commercial District',
        district: 'Central Zone',
        isSelected: true,
        surgeMultiplier: 1.2,
        activeRiders: 45,
      ),
    ];

    test('GetOperatingZonesUseCase returns list of zones', () async {
      final useCase = GetOperatingZonesUseCase(mockProfileRepository);
      when(() => mockProfileRepository.getOperatingZones()).thenAnswer((_) async => const Right(tZones));

      final result = await useCase();
      expect(result, const Right(tZones));
      verify(() => mockProfileRepository.getOperatingZones()).called(1);
    });

    test('UpdateOperatingZonesUseCase saves zone selections', () async {
      final useCase = UpdateOperatingZonesUseCase(mockProfileRepository);
      when(() => mockProfileRepository.updateOperatingZones(['zone_1', 'zone_2']))
          .thenAnswer((_) async => const Right(true));

      final result = await useCase(['zone_1', 'zone_2']);
      expect(result, const Right(true));
      verify(() => mockProfileRepository.updateOperatingZones(['zone_1', 'zone_2'])).called(1);
    });
  });

  group('Payout Info & Vehicle UseCases', () {
    const tPayout = PayoutInfoEntity(
      methodType: PayoutMethodType.bank,
      bankName: 'Chase Bank USA',
      accountNumber: '9920184920',
      accountHolderName: 'Alex Johnson',
    );

    const tVehicle = VehicleEntity(
      type: '2-Wheeler (Motorcycle / Scooter)',
      model: 'Honda CB500X',
      licensePlate: 'RD-8842-NY',
      color: 'Sapphire Blue',
      year: '2023',
    );

    test('GetPayoutInfoUseCase & UpdatePayoutInfoUseCase', () async {
      final getUseCase = GetPayoutInfoUseCase(mockProfileRepository);
      final updateUseCase = UpdatePayoutInfoUseCase(mockProfileRepository);

      when(() => mockProfileRepository.getPayoutInfo()).thenAnswer((_) async => const Right(tPayout));
      when(() => mockProfileRepository.updatePayoutInfo(tPayout)).thenAnswer((_) async => const Right(tPayout));

      final getResult = await getUseCase();
      expect(getResult, const Right(tPayout));

      final updateResult = await updateUseCase(tPayout);
      expect(updateResult, const Right(tPayout));
    });

    test('UpdateVehicleUseCase updates rider vehicle details', () async {
      final useCase = UpdateVehicleUseCase(mockProfileRepository);
      when(() => mockProfileRepository.updateVehicle(tVehicle)).thenAnswer((_) async => const Right(tVehicle));

      final result = await useCase(tVehicle);
      expect(result, const Right(tVehicle));
      verify(() => mockProfileRepository.updateVehicle(tVehicle)).called(1);
    });
  });
}
