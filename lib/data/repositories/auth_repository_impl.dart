import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/rider_entity.dart';
import '../../domain/entities/registration_result_entity.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/entities/phone_otp_result_entity.dart';
import '../../domain/entities/reset_password_result_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/rider_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginResponseEntity>> loginWithEmailPassword({
    required String email,
    required String password,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) async {
    try {
      final response = await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
        deviceId: deviceId,
        platform: platform,
        deviceToken: deviceToken,
        userAgent: userAgent,
      );

      await localDataSource.saveToken(response.accessToken);
      await localDataSource.saveRefreshToken(response.refreshToken);
      await localDataSource.saveRider(RiderModel.fromEntity(response.rider));
      await localDataSource.saveUser(UserModel(
        id: response.user.id,
        email: response.user.email,
        name: response.user.name,
        role: response.user.role,
        phone: response.user.phone,
        phoneCountryCode: response.user.phoneCountryCode,
        image: response.user.image,
        isEmailVerified: response.user.isEmailVerified,
        createdAt: response.user.createdAt,
      ));
      await localDataSource.setIsOnline(response.rider.isOnline);
      if (deviceToken.isNotEmpty) {
        await localDataSource.saveDeviceToken(deviceToken);
      }

      return Right(response);
    } on SuspendedException catch (e) {
      return Left(SuspendedFailure(message: e.message, authStatus: e.authStatus));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendPhoneOtpResultEntity>> sendPhoneOtp(String phone) async {
    try {
      final result = await remoteDataSource.sendPhoneOtp(phone: phone);
      return Right(result);
    } on SuspendedException catch (e) {
      return Left(SuspendedFailure(message: e.message, authStatus: e.authStatus));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) async {
    try {
      final response = await remoteDataSource.verifyPhoneOtp(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        platform: platform,
        deviceToken: deviceToken,
        userAgent: userAgent,
      );

      await localDataSource.saveToken(response.accessToken);
      await localDataSource.saveRefreshToken(response.refreshToken);
      await localDataSource.saveRider(RiderModel.fromEntity(response.rider));
      await localDataSource.saveUser(UserModel(
        id: response.user.id,
        email: response.user.email,
        name: response.user.name,
        role: response.user.role,
        phone: response.user.phone,
        phoneCountryCode: response.user.phoneCountryCode,
        image: response.user.image,
        isEmailVerified: response.user.isEmailVerified,
        createdAt: response.user.createdAt,
      ));
      await localDataSource.setIsOnline(response.rider.isOnline);
      if (deviceToken.isNotEmpty) {
        await localDataSource.saveDeviceToken(deviceToken);
      }

      return Right(response);
    } on SuspendedException catch (e) {
      return Left(SuspendedFailure(message: e.message, authStatus: e.authStatus));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> login(String phone) async {
    try {
      final result = await remoteDataSource.login(phone);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> loginWithPassword(String email, String password) async {
    try {
      final data = await remoteDataSource.loginWithPassword(email, password);
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final rider = data['rider'] as RiderModel;

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveRider(rider);
      await localDataSource.setIsOnline(rider.isOnline);

      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendResetOtpResultEntity>> forgotPassword(String identity) async {
    try {
      final result = await remoteDataSource.forgotPassword(identity);
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String identity, String otp, String newPassword) async {
    try {
      final result = await remoteDataSource.resetPassword(identity, otp, newPassword);
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> verifyOtp(String phone, String otp) async {
    try {
      final data = await remoteDataSource.verifyOtp(phone, otp);
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final rider = data['rider'] as RiderModel;

      await localDataSource.saveToken(token);
      await localDataSource.saveRefreshToken(refreshToken);
      await localDataSource.saveRider(rider);
      await localDataSource.setIsOnline(rider.isOnline);

      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> register(Map<String, dynamic> riderData) async {
    try {
      final rider = await remoteDataSource.register(riderData);
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity>> submitOnboarding({
    required List<String> vehicleTypes,
    required String vehicleName,
    required String vehicleNumber,
    required String drivingLicenseNo,
    required List<String> selectedZones,
    required List<String> selectedLocations,
    required Map<String, dynamic> address,
    required Map<String, dynamic> emergencyContact,
    required Map<String, dynamic> payoutInfo,
    String? profileImagePath,
    String? drivingLicenseFrontPath,
    String? drivingLicenseBackPath,
    String? nationalIdPath,
  }) async {
    try {
      final rider = await remoteDataSource.submitOnboarding(
        vehicleTypes: vehicleTypes,
        vehicleName: vehicleName,
        vehicleNumber: vehicleNumber,
        drivingLicenseNo: drivingLicenseNo,
        selectedZones: selectedZones,
        selectedLocations: selectedLocations,
        address: address,
        emergencyContact: emergencyContact,
        payoutInfo: payoutInfo,
        profileImagePath: profileImagePath,
        drivingLicenseFrontPath: drivingLicenseFrontPath,
        drivingLicenseBackPath: drivingLicenseBackPath,
        nationalIdPath: nationalIdPath,
      );
      await localDataSource.saveRider(rider);
      return Right(rider);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegistrationResultEntity>> selfRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String phoneCountryCode,
  }) async {
    try {
      final result = await remoteDataSource.selfRegister(
        name: name,
        email: email,
        password: password,
        phone: phone,
        phoneCountryCode: phoneCountryCode,
      );
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on SuspendedException catch (e) {
      return Left(SuspendedFailure(message: e.message, authStatus: e.authStatus));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyRegistrationResultEntity>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyRegistrationOtp(
        email: email,
        otp: otp,
      );
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResendOtpResultEntity>> resendRegistrationOtp({
    required String email,
  }) async {
    try {
      final result = await remoteDataSource.resendRegistrationOtp(email: email);
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(message: e.message, cooldownSeconds: e.cooldownSeconds));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RiderEntity?>> getSavedRider() async {
    try {
      final rider = localDataSource.getSavedRider();
      return Right(rider);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuth();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearAuth();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final currentRefresh = localDataSource.getRefreshToken();
      if (currentRefresh == null) {
        return const Left(AuthFailure(message: 'No refresh token stored'));
      }
      final newToken = await remoteDataSource.refreshToken(currentRefresh);
      await localDataSource.saveToken(newToken);
      return Right(newToken);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerDeviceToken({
    required String token,
    required String deviceId,
    required String platform,
    String? deviceModel,
    String? appVersion,
  }) async {
    try {
      final result = await remoteDataSource.registerDeviceToken(
        token: token,
        deviceId: deviceId,
        platform: platform,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );
      if (token.isNotEmpty) {
        await localDataSource.saveDeviceToken(token);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unregisterDeviceToken({
    required String deviceId,
  }) async {
    try {
      final result = await remoteDataSource.unregisterDeviceToken(deviceId: deviceId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
