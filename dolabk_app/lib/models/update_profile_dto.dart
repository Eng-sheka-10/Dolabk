// lib/models/update_profile_dto.dart
class UpdateProfileDto {
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;

  UpdateProfileDto({this.fullName, this.phoneNumber, this.profileImageUrl});

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}
