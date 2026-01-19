// lib/models/user_model.dart
class User {
  final int id;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final String? fullName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final double walletBalance;
  final String? profileImageUrl;

  User({
    required this.id,
    this.userName,
    this.email,
    this.phoneNumber,
    this.fullName,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.walletBalance,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'],
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'walletBalance': walletBalance,
      'profileImageUrl': profileImageUrl,
    };
  }
}
