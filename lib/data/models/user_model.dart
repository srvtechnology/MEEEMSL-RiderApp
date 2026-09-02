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
