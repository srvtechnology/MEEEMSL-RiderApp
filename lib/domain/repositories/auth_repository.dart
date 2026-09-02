import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/rider_entity.dart';
import '../entities/registration_result_entity.dart';
import '../entities/login_response_entity.dart';
import '../entities/phone_otp_result_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> login(String phone);
  Future<Either<Failure, RiderEntity>> loginWithPassword(String email, String password);
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp);

  // Section 3: Rider Login & Session Lifecycle
  Future<Either<Failure, LoginResponseEntity>> loginWithEmailPassword({
    required String email,
    required String password,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  });
  Future<Either<Failure, SendPhoneOtpResultEntity>> sendPhoneOtp(String phone);
  Future<Either<Failure, LoginResponseEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  });
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData);
  Future<Either<Failure, RegistrationResultEntity>> selfRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String phoneCountryCode,
  });
  Future<Either<Failure, VerifyRegistrationResultEntity>> verifyRegistrationOtp({
    required String email,
    required String otp,
  });
  Future<Either<Failure, ResendOtpResultEntity>> resendRegistrationOtp({
    required String email,
  });
  Future<Either<Failure, bool>> forgotPassword(String identity);
  Future<Either<Failure, bool>> resetPassword(String identity, String otp, String newPassword);
  Future<Either<Failure, RiderEntity?>> getSavedRider();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, String>> refreshToken();
}

