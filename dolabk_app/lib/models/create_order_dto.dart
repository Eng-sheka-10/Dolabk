// lib/models/create_order_dto.dart
import 'package:dolabk_app/models/enums.dart';
import 'package:dolabk_app/models/order_item_dto.dart';

class CreateOrderDto {
  final List<OrderItemDto> items;
  final int? addressId;
  final double shippingCost;
  final PaymentMethod paymentMethod;
  final String? notes;

  CreateOrderDto({
    required this.items,
    this.addressId,
    required this.shippingCost,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'addressId': addressId,
      'shippingCost': shippingCost,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'notes': notes,
    };
  }
}
