// lib/models/register_dto.dart
class RegisterDto {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;

  RegisterDto({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    };
  }
}
