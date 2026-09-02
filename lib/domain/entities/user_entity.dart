import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String phone;
  final String phoneCountryCode;
  final String? image;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'RIDER',
    required this.phone,
    this.phoneCountryCode = '+232',
    this.image,
    this.isEmailVerified = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        phone,
        phoneCountryCode,
        image,
        isEmailVerified,
        createdAt,
      ];
}
