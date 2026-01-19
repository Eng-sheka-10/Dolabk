// lib/models/order_item_model.dart
import 'package:dolabk_app/models/product_model.dart';

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? rentalDays;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final double? depositAmount;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.rentalDays,
    this.rentalStartDate,
    this.rentalEndDate,
    this.depositAmount,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      rentalDays: json['rentalDays'],
      rentalStartDate: json['rentalStartDate'] != null
          ? DateTime.parse(json['rentalStartDate'])
          : null,
      rentalEndDate: json['rentalEndDate'] != null
          ? DateTime.parse(json['rentalEndDate'])
          : null,
      depositAmount: json['depositAmount']?.toDouble(),
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}
