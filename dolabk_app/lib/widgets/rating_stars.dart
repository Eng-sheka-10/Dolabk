// lib/widgets/rating_stars.dart
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.color,
    this.interactive = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        IconData icon;
        if (index < rating.floor()) {
          icon = Icons.star;
        } else if (index < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Icon(icon, size: size, color: color ?? Colors.amber),
        );
      }),
    );
  }
}
