import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/rider_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String phone);
  Future<Map<String, dynamic>> loginWithPassword(String email, String password);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  Future<RiderModel> register(Map<String, dynamic> riderData);
  Future<bool> forgotPassword(String identity);
  Future<bool> resetPassword(String identity, String otp, String newPassword);
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

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
        message: e.response?.data?['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> forgotPassword(String identity) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'identity': identity},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to process password reset request',
        statusCode: e.response?.statusCode,
      );
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
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to reset password',
        statusCode: e.response?.statusCode,
      );
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
