import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/submit_onboarding_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SubmitOnboardingUseCase submitOnboardingUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    submitOnboardingUseCase = SubmitOnboardingUseCase(mockRepository);
  });

  const tRider = RiderEntity(
    id: 'cm7rider0001',
    name: 'Samuel Taylor',
    phone: '76145892',
    email: 'hadane3655@fanzher.com',
    avatar: '',
    rating: 5.0,
    totalTrips: 0,
    isOnline: false,
    walletBalance: 0.0,
    approvalStatus: 'APPROVED',
    isApproved: true,
    status: 'APPROVED',
    onboardingCompleted: true,
    isFirstLogin: false,
    vehicleType: '2_WHEELER',
    vehicleTypes: ['2_WHEELER'],
    vehicleName: 'Honda CB Shine 125',
    vehicleNumber: 'SL-AA-9988',
    drivingLicenseNo: 'DL-10928374',
    drivingLicenseDoc: 'https://s3.amazonaws.com/meeem/docs/dl.png',
    nationalIdDoc: 'https://s3.amazonaws.com/meeem/docs/id.png',
    vehicleInsuranceDoc: 'https://s3.amazonaws.com/meeem/docs/ins.png',
    selectedZones: ['ZONE 1', 'ZONE 2'],
    selectedLocations: ['NO 2 RIVER', 'BAW BAW'],
  );

  test('SubmitOnboardingUseCase should forward all Section 5 parameters to AuthRepository', () async {
    when(() => mockRepository.submitOnboarding(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          phoneCountryCode: any(named: 'phoneCountryCode'),
          newPassword: any(named: 'newPassword'),
          vehicleType: any(named: 'vehicleType'),
          vehicleTypes: any(named: 'vehicleTypes'),
          vehicleName: any(named: 'vehicleName'),
          vehicleNumber: any(named: 'vehicleNumber'),
          drivingLicenseNo: any(named: 'drivingLicenseNo'),
          selectedZones: any(named: 'selectedZones'),
          selectedLocations: any(named: 'selectedLocations'),
          address: any(named: 'address'),
          emergencyContact: any(named: 'emergencyContact'),
          payoutInfo: any(named: 'payoutInfo'),
          profileImagePath: any(named: 'profileImagePath'),
          drivingLicenseDocPath: any(named: 'drivingLicenseDocPath'),
          nationalIdDocPath: any(named: 'nationalIdDocPath'),
          vehicleInsuranceDocPath: any(named: 'vehicleInsuranceDocPath'),
          drivingLicenseFrontPath: any(named: 'drivingLicenseFrontPath'),
          drivingLicenseBackPath: any(named: 'drivingLicenseBackPath'),
          nationalIdPath: any(named: 'nationalIdPath'),
        )).thenAnswer((_) async => const Right(tRider));

    final result = await submitOnboardingUseCase(
      name: 'Samuel Taylor',
      phone: '76145892',
      phoneCountryCode: '+232',
      vehicleType: '2_WHEELER',
      vehicleTypes: ['2_WHEELER'],
      vehicleName: 'Honda CB Shine 125',
      vehicleNumber: 'SL-AA-9988',
      drivingLicenseNo: 'DL-10928374',
      selectedZones: ['ZONE 1', 'ZONE 2'],
      selectedLocations: ['NO 2 RIVER', 'BAW BAW'],
      drivingLicenseDocPath: '/dummy/path/dl.jpg',
      nationalIdDocPath: '/dummy/path/id.jpg',
      vehicleInsuranceDocPath: '/dummy/path/insurance.jpg',
      profileImagePath: '/dummy/path/profile.jpg',
    );

    expect(result, const Right(tRider));
    verify(() => mockRepository.submitOnboarding(
          name: 'Samuel Taylor',
          phone: '76145892',
          phoneCountryCode: '+232',
          vehicleType: '2_WHEELER',
          vehicleTypes: ['2_WHEELER'],
          vehicleName: 'Honda CB Shine 125',
          vehicleNumber: 'SL-AA-9988',
          drivingLicenseNo: 'DL-10928374',
          selectedZones: ['ZONE 1', 'ZONE 2'],
          selectedLocations: ['NO 2 RIVER', 'BAW BAW'],
          drivingLicenseDocPath: '/dummy/path/dl.jpg',
          nationalIdDocPath: '/dummy/path/id.jpg',
          vehicleInsuranceDocPath: '/dummy/path/insurance.jpg',
          profileImagePath: '/dummy/path/profile.jpg',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
