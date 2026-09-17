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
  final bool isPhoneVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    this.email = '',
    required this.name,
    this.role = 'RIDER',
    required this.phone,
    this.phoneCountryCode = '+232',
    this.image,
    this.isEmailVerified = true,
    this.isPhoneVerified = true,
    this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? phoneCountryCode,
    String? image,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      image: image ?? this.image,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
        isPhoneVerified,
        createdAt,
      ];
}
