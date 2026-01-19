// lib/models/update_address_dto.dart
class UpdateAddressDto {
  final String? fullName;
  final String? phoneNumber;
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool? isDefault;
  final double? latitude;
  final double? longitude;

  UpdateAddressDto({
    this.fullName,
    this.phoneNumber,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (street != null) data['street'] = street;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (zipCode != null) data['zipCode'] = zipCode;
    if (country != null) data['country'] = country;
    if (isDefault != null) data['isDefault'] = isDefault;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    return data;
  }
}
