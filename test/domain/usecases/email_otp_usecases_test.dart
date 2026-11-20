import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meeem_rider/domain/entities/email_otp_result_entity.dart';
import 'package:meeem_rider/domain/entities/login_response_entity.dart';
import 'package:meeem_rider/domain/entities/user_entity.dart';
import 'package:meeem_rider/domain/entities/rider_entity.dart';
import 'package:meeem_rider/domain/entities/auth_tokens_entity.dart';
import 'package:meeem_rider/domain/repositories/auth_repository.dart';
import 'package:meeem_rider/domain/usecases/auth/send_email_otp_usecase.dart';
import 'package:meeem_rider/domain/usecases/auth/verify_email_otp_usecase.dart';
import 'package:meeem_rider/data/models/order_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SendEmailOtpUseCase sendEmailOtpUseCase;
  late VerifyEmailOtpUseCase verifyEmailOtpUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    sendEmailOtpUseCase = SendEmailOtpUseCase(mockRepository);
    verifyEmailOtpUseCase = VerifyEmailOtpUseCase(mockRepository);
  });

  const tEmail = 'rider@example.com';
  const tOtp = '123456';
  const tSendResult = SendEmailOtpResultEntity(
    email: tEmail,
    expiresIn: 600,
    resendCooldown: 60,
  );

  final tLoginResponse = LoginResponseEntity(
    message: 'Login successful',
    user: const UserEntity(
      id: 'user_1',
      name: 'Ibrahim',
      email: tEmail,
      phone: '+23276123456',
    ),
    rider: const RiderEntity(
      id: 'rider_1',
      name: 'Ibrahim',
      phone: '+23276123456',
      email: tEmail,
      approvalStatus: 'approved',
    ),
    tokens: const AuthTokensEntity(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_123',
      expiresIn: 604800,
    ),
  );

  test('SendEmailOtpUseCase calls repository.sendEmailOtp', () async {
    when(() => mockRepository.sendEmailOtp(any()))
        .thenAnswer((_) async => const Right(tSendResult));

    final result = await sendEmailOtpUseCase(tEmail);

    expect(result, const Right(tSendResult));
    verify(() => mockRepository.sendEmailOtp(tEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('VerifyEmailOtpUseCase calls repository.verifyEmailOtp with device info', () async {
    when(() => mockRepository.verifyEmailOtp(
          email: any(named: 'email'),
          otp: any(named: 'otp'),
          deviceId: any(named: 'deviceId'),
          platform: any(named: 'platform'),
          deviceToken: any(named: 'deviceToken'),
          userAgent: any(named: 'userAgent'),
        )).thenAnswer((_) async => Right(tLoginResponse));

    final result = await verifyEmailOtpUseCase(
      email: tEmail,
      otp: tOtp,
      deviceId: 'dev_123',
      platform: 'android',
      deviceToken: 'token_123',
      userAgent: 'RiderApp/1.0',
    );

    expect(result, Right(tLoginResponse));
    verify(() => mockRepository.verifyEmailOtp(
          email: tEmail,
          otp: tOtp,
          deviceId: 'dev_123',
          platform: 'android',
          deviceToken: 'token_123',
          userAgent: 'RiderApp/1.0',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('OrderModel parses enriched pickupLocation and dropoffLocation objects from backend handoff', () {
    final backendJson = {
      "id": "cuid_assignment_id",
      "orderId": "cuid_order_id",
      "status": "ACCEPTED",
      "distanceKm": 2.4,
      "sellerLatitude": 8.484245,
      "sellerLongitude": -13.234125,
      "dropoffLatitude": 8.463210,
      "dropoffLongitude": -13.277840,
      "pickupLocation": {
        "name": "Apex Electronics",
        "address": "124 Siaka Stevens Street, Freetown",
        "latitude": 8.484245,
        "longitude": -13.234125,
        "phone": "+23277987654"
      },
      "dropoffLocation": {
        "name": "John Doe",
        "address": "14 Lumley Beach Road, Freetown",
        "latitude": 8.463210,
        "longitude": -13.277840,
        "phone": "+23278999111"
      },
      "order": {
        "orderNumber": "meeem00000103"
      }
    };

    final order = OrderModel.fromJson(backendJson);

    expect(order.orderNumber, 'meeem00000103');
    expect(order.pickupName, 'Apex Electronics');
    expect(order.pickupAddress, '124 Siaka Stevens Street, Freetown');
    expect(order.pickupPhone, '+23277987654');
    expect(order.pickupLatitude, 8.484245);
    expect(order.pickupLongitude, -13.234125);

    expect(order.customerName, 'John Doe');
    expect(order.dropoffAddress, '14 Lumley Beach Road, Freetown');
    expect(order.customerPhone, '+23278999111');
    expect(order.dropoffLatitude, 8.463210);
    expect(order.dropoffLongitude, -13.277840);
  });

  test('OrderModel parses rural or text address without crashing when coordinates are null', () {
    final ruralJson = {
      "id": "cuid_assignment_rural",
      "orderId": "cuid_order_rural",
      "status": "ACCEPTED",
      "pickupLocation": {
        "name": "Rural Trader",
        "address": "Bo Town Center, Sierra Leone",
        "phone": "+23277000000"
      },
      "dropoffLocation": {
        "name": "Rural Receiver",
        "address": "Kenema Highway",
        "phone": "+23277111111"
      },
      "order": {
        "orderNumber": "meeem00000999"
      }
    };

    final order = OrderModel.fromJson(ruralJson);

    expect(order.orderNumber, 'meeem00000999');
    expect(order.pickupName, 'Rural Trader');
    expect(order.customerName, 'Rural Receiver');
    expect(order.pickupLatitude, isNotNull);
    expect(order.pickupLongitude, isNotNull);
    expect(order.dropoffLatitude, isNotNull);
    expect(order.dropoffLongitude, isNotNull);
  });
    expect(order.dropoffLongitude, -13.277840);
  });
}
