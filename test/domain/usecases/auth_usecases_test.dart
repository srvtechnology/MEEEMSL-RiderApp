import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/login_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late VerifyOtpUseCase verifyOtpUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    verifyOtpUseCase = VerifyOtpUseCase(mockRepository);
  });

  const tPhone = '+1 555 234 5678';
  const tOtp = '123456';
  const tRider = RiderEntity(
    id: 'rider_1',
    name: 'Alex Johnson',
    phone: tPhone,
    email: 'alex@example.com',
    avatar: '',
    rating: 4.9,
    totalTrips: 100,
    isOnline: true,
    walletBalance: 150.0,
    approvalStatus: 'approved',
  );

  test('LoginUseCase should call repository.login with phone number', () async {
    when(() => mockRepository.login(any())).thenAnswer((_) async => const Right(true));

    final result = await loginUseCase(tPhone);

    expect(result, const Right(true));
    verify(() => mockRepository.login(tPhone)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('VerifyOtpUseCase should call repository.verifyOtp and return RiderEntity', () async {
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => const Right(tRider));

    final result = await verifyOtpUseCase(tPhone, tOtp);

    expect(result, const Right(tRider));
    verify(() => mockRepository.verifyOtp(tPhone, tOtp)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
