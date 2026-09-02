import 'package:equatable/equatable.dart';

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
  const RateLimitFailure({
    required super.message,
    this.cooldownSeconds = 60,
    super.statusCode = 429,
  });

  @override
  List<Object?> get props => [message, statusCode, cooldownSeconds];
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

