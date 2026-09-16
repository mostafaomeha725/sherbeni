import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.token,
    super.deviceId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final user = data['user'] ?? data;

    return UserModel(
      id: user['id']?.toString() ?? data['userId']?.toString() ?? '',
      name: user['name'] ?? data['name'] ?? '',
      email: user['email'] ?? data['email'] ?? '',
      role: user['role'] ?? data['role'] ?? '',
      token: data['token'] ?? json['token'] ?? '',
      deviceId: data['device_id']?.toString() ?? data['deviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': id, 'name': name, 'email': email, 'role': role},
      'token': token,
      'device_id': deviceId,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      token: token,
      deviceId: deviceId,
    );
  }
}
