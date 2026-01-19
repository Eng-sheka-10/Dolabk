// lib/models/create_address_dto.dart
class CreateAddressDto {
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  CreateAddressDto({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}
