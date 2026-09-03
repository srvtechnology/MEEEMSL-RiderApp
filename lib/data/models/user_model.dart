import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role = 'RIDER',
    required super.phone,
    super.phoneCountryCode = '+232',
    super.image,
    super.isEmailVerified = true,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'] as String);
      } catch (_) {}
    }

    return UserModel(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'RIDER',
      phone: json['phone'] as String? ?? '',
      phoneCountryCode: json['phoneCountryCode'] as String? ?? '+232',
      image: json['image'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
      createdAt: parsedDate,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? phoneCountryCode,
    String? image,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      image: image ?? this.image,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      phone: entity.phone,
      phoneCountryCode: entity.phoneCountryCode,
      image: entity.image,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'phoneCountryCode': phoneCountryCode,
      'image': image,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
