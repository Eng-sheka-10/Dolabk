// lib/models/product_model.dart
import 'package:dolabk_app/models/enums.dart';
import 'package:dolabk_app/models/product_image_model.dart';
import 'package:dolabk_app/models/user_model.dart';

class Product {
  final int id;
  final String? name;
  final String? description;
  final double? price;
  final double? rentPricePerDay;
  final ProductType? type;
  final ProductCondition? condition;
  final String? category;
  final bool isAvailable;
  final int? viewCount;
  final int? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ProductImage>? images;
  final User? user;

  Product({
    required this.id,
    this.name,
    this.description,
    required this.price,
    this.rentPricePerDay,
    required this.type,
    required this.condition,
    this.category,
    required this.isAvailable,
    required this.viewCount,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.images,
    this.user,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      rentPricePerDay: json['rentPricePerDay']?.toDouble(),
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ProductType.Sale,
      ),
      condition: ProductCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['condition'],
        orElse: () => ProductCondition.Used,
      ),
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      viewCount: json['viewCount'] ?? 0,
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
                .map((i) => ProductImage.fromJson(i))
                .toList()
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'rentPricePerDay': rentPricePerDay,
      'type': type.toString().split('.').last,
      'condition': condition.toString().split('.').last,
      'category': category,
      'isAvailable': isAvailable,
      'viewCount': viewCount,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'images': images?.map((i) => i.toJson()).toList(),
      'user': user?.toJson(),
    };
  }
}
