import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.token,
    super.refreshToken,
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
      refreshToken: data['refresh_token']?.toString() ?? json['refresh_token']?.toString(),
      deviceId: data['device_id']?.toString() ?? data['deviceId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': id, 'name': name, 'email': email, 'role': role},
      'token': token,
      'refresh_token': refreshToken,
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
      refreshToken: refreshToken,
      deviceId: deviceId,
    );
  }
}

