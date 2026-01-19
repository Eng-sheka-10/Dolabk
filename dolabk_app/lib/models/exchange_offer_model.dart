// lib/models/exchange_offer_model.dart
import 'package:dolabk_app/models/enums.dart';
import 'package:dolabk_app/models/product_model.dart';
import 'package:dolabk_app/models/user_model.dart';

class ExchangeOffer {
  final int id;
  final int senderId;
  final int receiverId;
  final int requestedProductId;
  final int offeredProductId;
  final ExchangeStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final bool requiresDelivery;
  final double? meetingLatitude;
  final double? meetingLongitude;
  final String? meetingLocation;
  final User? sender;
  final User? receiver;
  final Product? requestedProduct;
  final Product? offeredProduct;

  ExchangeOffer({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.requestedProductId,
    required this.offeredProductId,
    required this.status,
    this.message,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    required this.requiresDelivery,
    this.meetingLatitude,
    this.meetingLongitude,
    this.meetingLocation,
    this.sender,
    this.receiver,
    this.requestedProduct,
    this.offeredProduct,
  });

  factory ExchangeOffer.fromJson(Map<String, dynamic> json) {
    return ExchangeOffer(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      requestedProductId: json['requestedProductId'],
      offeredProductId: json['offeredProductId'],
      status: ExchangeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ExchangeStatus.Pending,
      ),
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      requiresDelivery: json['requiresDelivery'] ?? false,
      meetingLatitude: json['meetingLatitude']?.toDouble(),
      meetingLongitude: json['meetingLongitude']?.toDouble(),
      meetingLocation: json['meetingLocation'],
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null
          ? User.fromJson(json['receiver'])
          : null,
      requestedProduct: json['requestedProduct'] != null
          ? Product.fromJson(json['requestedProduct'])
          : null,
      offeredProduct: json['offeredProduct'] != null
          ? Product.fromJson(json['offeredProduct'])
          : null,
    );
  }
}
