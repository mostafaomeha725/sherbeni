class SignInModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String deviceId;

  SignInModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.deviceId,
  });

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return SignInModel(
      id: user['id']?.toString() ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? '',
      token: json['token'] ?? '',
      deviceId: json['device_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': id, 'name': name, 'email': email, 'role': role},
      'token': token,
      'device_id': deviceId,
    };
  }
}
