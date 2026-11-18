import 'package:equatable/equatable.dart';
import 'exceptions.dart';

/// Failure base class for functional error handling with `Either<Failure, T>`.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Changes queued offline.'});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class SuspendedFailure extends Failure {
  final String? authStatus;
  const SuspendedFailure({
    super.message = 'Your rider account has been suspended. Please contact support.',
    super.statusCode = 403,
    this.authStatus = 'SUSPENDED',
  });

  @override
  List<Object?> get props => [message, statusCode, authStatus];
}

class RateLimitFailure extends Failure {
  final int cooldownSeconds;
  final int? retryAfter;
  final RateLimitType type;

  const RateLimitFailure({
    required super.message,
    this.cooldownSeconds = 60,
    this.retryAfter,
    this.type = RateLimitType.generic,
    super.statusCode = 429,
  });

  bool get isDailyLimit => type == RateLimitType.dailyOtpLimit;
  bool get isOtpLockout => type == RateLimitType.otpLockout;

  @override
  List<Object?> get props => [message, statusCode, cooldownSeconds, retryAfter, type];
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class UnverifiedAccountFailure extends Failure {
  final String? phone;
  final String? email;
  final String? verifyUrl;

  const UnverifiedAccountFailure({
    required super.message,
    this.phone,
    this.email,
    this.verifyUrl,
    super.statusCode = 403,
  });

  @override
  List<Object?> get props => [message, statusCode, phone, email, verifyUrl];
}

class PendingApprovalFailure extends Failure {
  final String approvalStatus;

  const PendingApprovalFailure({
    super.message = 'Your rider account is pending admin approval.',
    this.approvalStatus = 'PENDING',
    super.statusCode = 403,
  });

  @override
  List<Object?> get props => [message, statusCode, approvalStatus];
}

class TwoFactorSessionExpiredFailure extends Failure {
  final bool sessionExpired;

  const TwoFactorSessionExpiredFailure({
    super.message = 'Verification session has expired. Please log in again.',
    super.statusCode = 400,
    this.sessionExpired = true,
  });

  @override
  List<Object?> get props => [message, statusCode, sessionExpired];
}

class TwoFactorCodeExpiredFailure extends Failure {
  final bool codeExpired;

  const TwoFactorCodeExpiredFailure({
    super.message = 'Verification code has expired. Please request a new one.',
    super.statusCode = 400,
    this.codeExpired = true,
  });

  @override
  List<Object?> get props => [message, statusCode, codeExpired];
}

