// lib/models/product_image_model.dart
class ProductImage {
  final int id;
  final int productId;
  final String? imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime createdAt;

  ProductImage({
    required this.id,
    required this.productId,
    this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
    required this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      productId: json['productId'],
      imageUrl: json['imageUrl'],
      isPrimary: json['isPrimary'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'isPrimary': isPrimary,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
