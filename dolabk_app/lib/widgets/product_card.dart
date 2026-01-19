// lib/widgets/product_card.dart
import 'package:dolabk_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final double price;
  final String? imageUrl;
  final String? condition;
  final String type;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.condition,
    required this.type,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.softGray,
                        child: const Icon(Icons.image, size: 50),
                      ),
                    )
                  : Container(
                      color: AppTheme.softGray,
                      child: const Icon(Icons.image, size: 50),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price
                  if (type != 'Exchange')
                    Text(
                      type == 'Rent'
                          ? '\$${price.toStringAsFixed(2)}/day'
                          : '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  if (type == 'Exchange')
                    const Text(
                      'For Exchange',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Badges
                  Row(
                    children: [
                      if (condition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.softGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            condition!,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      const SizedBox(width: 4),
                      StatusBadge(type: type, small: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
