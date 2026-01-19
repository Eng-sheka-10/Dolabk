// lib/models/order_item_dto.dart
class OrderItemDto {
  final int productId;
  final int quantity;
  final int? rentalDays;
  final DateTime? rentalStartDate;

  OrderItemDto({
    required this.productId,
    required this.quantity,
    this.rentalDays,
    this.rentalStartDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'rentalDays': rentalDays,
      'rentalStartDate': rentalStartDate?.toIso8601String(),
    };
  }
}
