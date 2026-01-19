// lib/models/delivery_model.dart
import 'package:dolabk_app/models/enums.dart';

class Delivery {
  final int id;
  final int orderId;
  final String? trackingNumber;
  final DeliveryStatus status;
  final String? courierName;
  final String? courierPhone;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? deliveryNotes;
  final DateTime createdAt;

  Delivery({
    required this.id,
    required this.orderId,
    this.trackingNumber,
    required this.status,
    this.courierName,
    this.courierPhone,
    this.pickedUpAt,
    this.deliveredAt,
    this.deliveryNotes,
    required this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      orderId: json['orderId'],
      trackingNumber: json['trackingNumber'],
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DeliveryStatus.Pending,
      ),
      courierName: json['courierName'],
      courierPhone: json['courierPhone'],
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      deliveryNotes: json['deliveryNotes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
