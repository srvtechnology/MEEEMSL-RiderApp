import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/rider_model.dart';
import '../models/registration_result_model.dart';
import '../models/login_response_model.dart';
import '../models/phone_otp_result_model.dart';
import '../models/reset_password_result_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String phone);
  Future<Map<String, dynamic>> loginWithPassword(String email, String password);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<LoginResponseModel> loginWithEmailPassword({
    required String email,
    required String password,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  });
  Future<SendPhoneOtpResultModel> sendPhoneOtp({
    required String phone,
  });
  Future<LoginResponseModel> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  });
  Future<RiderModel> register(Map<String, dynamic> riderData);
  Future<RegistrationResultModel> selfRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String phoneCountryCode,
  });
  Future<VerifyRegistrationResultModel> verifyRegistrationOtp({
    required String email,
    required String otp,
  });
  Future<ResendOtpResultModel> resendRegistrationOtp({
    required String email,
  });
  Future<SendResetOtpResultModel> forgotPassword(String identity);
  Future<bool> resetPassword(String identity, String otp, String newPassword);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LoginResponseModel> loginWithEmailPassword({
    required String email,
    required String password,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'deviceId': deviceId,
          'platform': platform,
          'deviceToken': deviceToken,
          'userAgent': userAgent,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        return LoginResponseModel.fromJson(data);
      }
      throw const ServerException(message: 'Login failed');
    } on DioException catch (e) {
      final respData = e.response?.data is Map ? e.response!.data as Map : {};
      final isSuspended = respData['isSuspended'] as bool? ?? false;
      final msg = respData['error'] ?? respData['message'] ?? 'Login failed';

      if (e.response?.statusCode == 403 && isSuspended) {
        throw SuspendedException(
          message: msg.toString(),
          authStatus: respData['authStatus']?.toString() ?? 'SUSPENDED',
        );
      }
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<SendPhoneOtpResultModel> sendPhoneOtp({required String phone}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.phoneOtpSend,
        data: {'phone': phone},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SendPhoneOtpResultModel.fromJson(data);
      }
      throw const ServerException(message: 'Failed to send OTP');
    } on DioException catch (e) {
      final respData = e.response?.data is Map ? e.response!.data as Map : {};
      final isSuspended = respData['isSuspended'] as bool? ?? false;
      final msg = respData['error'] ?? respData['message'] ?? 'Failed to send OTP';

      if (e.response?.statusCode == 403 && isSuspended) {
        throw SuspendedException(
          message: msg.toString(),
          authStatus: respData['authStatus']?.toString() ?? 'SUSPENDED',
        );
      }
      if (e.response?.statusCode == 429) {
        throw RateLimitException(message: msg.toString(), cooldownSeconds: 45);
      }
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<LoginResponseModel> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
    required String deviceToken,
    required String userAgent,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.phoneOtpVerify,
        data: {
          'phone': phone,
          'otp': otp,
          'deviceId': deviceId,
          'platform': platform,
          'deviceToken': deviceToken,
          'userAgent': userAgent,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        return LoginResponseModel.fromJson(data);
      }
      throw const ServerException(message: 'Verification failed');
    } on DioException catch (e) {
      final respData = e.response?.data is Map ? e.response!.data as Map : {};
      final msg = respData['error'] ?? respData['message'] ?? 'Invalid OTP code';
      if (e.response?.statusCode == 429) {
        throw RateLimitException(message: msg.toString(), cooldownSeconds: 300);
      }
      throw ServerException(message: msg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<bool> login(String phone) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {'phone': phone},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to send verification code',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithPassword(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.loginWithPassword,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String? ?? 'mock_jwt_token_email';
        final refreshToken = data['refreshToken'] as String? ?? 'mock_refresh_token_email';
        final rider = RiderModel.fromJson(data['rider'] as Map<String, dynamic>);
        return {
          'token': token,
          'refreshToken': refreshToken,
          'rider': rider,
        };
      }
      throw const ServerException(message: 'Invalid email or password');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Invalid credentials',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        final rider = RiderModel.fromJson(data['rider'] as Map<String, dynamic>);
        return {
          'token': token,
          'refreshToken': refreshToken,
          'rider': rider,
        };
      }
      throw const ServerException(message: 'Invalid response from server');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to verify OTP',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<RiderModel> register(Map<String, dynamic> riderData) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: riderData,
      );
      if (response.statusCode == 200 && response.data != null) {
        return RiderModel.fromJson(response.data['rider'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Registration failed');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<RegistrationResultModel> selfRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String phoneCountryCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'phoneCountryCode': phoneCountryCode,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return RegistrationResultModel.fromJson(data);
      }
      throw const ServerException(message: 'Registration failed');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Registration failed';
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<VerifyRegistrationResultModel> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.verifyRegistrationOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return VerifyRegistrationResultModel.fromJson(data);
      }
      throw const ServerException(message: 'Verification failed');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Invalid or expired OTP code.';
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<ResendOtpResultModel> resendRegistrationOtp({
    required String email,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.resendRegistrationOtp,
        data: {'email': email},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ResendOtpResultModel.fromJson(data);
      }
      throw const ServerException(message: 'Failed to resend verification code');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to resend code';
      if (e.response?.statusCode == 429) {
        throw RateLimitException(message: msg, cooldownSeconds: 60);
      }
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<SendResetOtpResultModel> forgotPassword(String identity) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'identity': identity},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        return SendResetOtpResultModel.fromJson(data);
      }
      throw const ServerException(message: 'Failed to send reset code');
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to send reset code';
      if (e.response?.statusCode == 429) {
        throw RateLimitException(message: msg, cooldownSeconds: 45);
      }
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<bool> resetPassword(String identity, String otp, String newPassword) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'identity': identity,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? 'Failed to reset password';
      if (e.response?.statusCode == 429) {
        throw RateLimitException(message: msg, cooldownSeconds: 300);
      }
      throw ServerException(message: msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return response.data['token'] as String;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Session expired',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }
}
