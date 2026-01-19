// lib/models/update_product_dto.dart
import 'package:dolabk_app/models/enums.dart';

class UpdateProductDto {
  final String? name;
  final String? description;
  final double? price;
  final double? rentPricePerDay;
  final ProductCondition? condition;
  final String? category;
  final bool? isAvailable;

  UpdateProductDto({
    this.name,
    this.description,
    this.price,
    this.rentPricePerDay,
    this.condition,
    this.category,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (rentPricePerDay != null) data['rentPricePerDay'] = rentPricePerDay;
    if (condition != null)
      data['condition'] = condition.toString().split('.').last;
    if (category != null) data['category'] = category;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    return data;
  }
}
