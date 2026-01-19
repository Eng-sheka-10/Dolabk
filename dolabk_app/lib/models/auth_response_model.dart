// lib/models/auth_response_model.dart
class AuthResponse {
  final int userId;
  final String? token;
  final String? fullName;
  final String? email;

  AuthResponse({required this.userId, this.token, this.fullName, this.email});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'],
      token: json['token'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'fullName': fullName,
      'email': email,
    };
  }
}
