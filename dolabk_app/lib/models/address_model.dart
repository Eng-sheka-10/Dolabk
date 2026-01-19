// lib/models/address_model.dart
class Address {
  final int id;
  final int userId;
  final String? fullName;
  final String? phoneNumber;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.userId,
    this.fullName,
    this.phoneNumber,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    required this.isDefault,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
