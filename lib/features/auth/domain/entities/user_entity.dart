import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String? refreshToken;
  final String? deviceId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.refreshToken,
    this.deviceId,
  });

  @override
  List<Object?> get props => [id, name, email, role, token, refreshToken, deviceId];
}
