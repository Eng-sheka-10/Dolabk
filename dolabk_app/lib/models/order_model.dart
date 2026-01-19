// lib/models/order_model.dart
import 'package:dolabk_app/models/address_model.dart';
import 'package:dolabk_app/models/delivery_model.dart';
import 'package:dolabk_app/models/enums.dart';
import 'package:dolabk_app/models/order_item_model.dart';
import 'package:dolabk_app/models/payment_model.dart';

class Order {
  final int id;
  final int userId;
  final int? addressId;
  final String? orderNumber;
  final double totalAmount;
  final double shippingCost;
  final double taxAmount;
  final double discountAmount;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final List<OrderItem>? orderItems;
  final Address? address;
  final Payment? payment;
  final Delivery? delivery;

  Order({
    required this.id,
    required this.userId,
    this.addressId,
    this.orderNumber,
    required this.totalAmount,
    required this.shippingCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.status,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.orderItems,
    this.address,
    this.payment,
    this.delivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      addressId: json['addressId'],
      orderNumber: json['orderNumber'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.Pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.CashOnDelivery,
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
                .map((i) => OrderItem.fromJson(i))
                .toList()
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      delivery: json['delivery'] != null
          ? Delivery.fromJson(json['delivery'])
          : null,
    );
  }
}
