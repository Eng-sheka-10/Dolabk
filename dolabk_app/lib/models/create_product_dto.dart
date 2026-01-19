// lib/models/create_product_dto.dart
import 'package:dolabk_app/models/enums.dart';

class CreateProductDto {
  final String name;
  final String description;
  final double price;
  final double? rentPricePerDay;
  final ProductType type;
  final ProductCondition condition;
  final String category;
  final List<String>? imageUrls;

  CreateProductDto({
    required this.name,
    required this.description,
    required this.price,
    this.rentPricePerDay,
    required this.type,
    required this.condition,
    required this.category,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'rentPricePerDay': rentPricePerDay,
      'type': type.toString().split('.').last,
      'condition': condition.toString().split('.').last,
      'category': category,
      'imageUrls': imageUrls,
    };
  }
}
