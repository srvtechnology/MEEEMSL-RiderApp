/// Custom Exceptions thrown in Data layer
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network connection failure'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

class SuspendedException implements Exception {
  final String message;
  final String authStatus;
  const SuspendedException({
    this.message = 'Your rider account has been suspended. Please contact support.',
    this.authStatus = 'SUSPENDED',
  });

  @override
  String toString() => 'SuspendedException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final int cooldownSeconds;
  const RateLimitException({
    required this.message,
    this.cooldownSeconds = 60,
  });

  @override
  String toString() => 'RateLimitException: $message (cooldown: ${cooldownSeconds}s)';
}

class UnverifiedAccountException implements Exception {
  final String message;
  final String? phone;
  final String? email;
  final String? verifyUrl;

  const UnverifiedAccountException({
    this.message = 'Please verify your mobile number before logging in.',
    this.phone,
    this.email,
    this.verifyUrl,
  });

  @override
  String toString() => 'UnverifiedAccountException: $message (phone: $phone, email: $email)';
}

class PendingApprovalException implements Exception {
  final String message;
  final String approvalStatus;

  const PendingApprovalException({
    this.message = 'Your rider account is pending admin approval.',
    this.approvalStatus = 'PENDING',
  });

  @override
  String toString() => 'PendingApprovalException: $message (status: $approvalStatus)';
}

