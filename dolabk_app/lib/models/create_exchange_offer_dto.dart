// lib/models/create_exchange_offer_dto.dart
class CreateExchangeOfferDto {
  final int requestedProductId;
  final int offeredProductId;
  final String? message;
  final bool requiresDelivery;
  final double? meetingLatitude;
  final double? meetingLongitude;
  final String? meetingLocation;

  CreateExchangeOfferDto({
    required this.requestedProductId,
    required this.offeredProductId,
    this.message,
    this.requiresDelivery = false,
    this.meetingLatitude,
    this.meetingLongitude,
    this.meetingLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestedProductId': requestedProductId,
      'offeredProductId': offeredProductId,
      'message': message,
      'requiresDelivery': requiresDelivery,
      'meetingLatitude': meetingLatitude,
      'meetingLongitude': meetingLongitude,
      'meetingLocation': meetingLocation,
    };
  }
}
