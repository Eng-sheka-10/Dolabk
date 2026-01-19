// lib/screens/reviews/reviews_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/review_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/user_avatar.dart';
import '../../core/theme/app_theme.dart';

class ReviewsScreen extends StatefulWidget {
  final String userId;

  const ReviewsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _reviewService = getIt<ReviewService>();

  bool _isLoading = true;
  List<dynamic> _reviews = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      final reviewsResponse = await _reviewService.getUserReviews(
        int.parse(widget.userId),
      );
      final ratingResponse = await _reviewService.getUserAverageRating(
        int.parse(widget.userId),
      );

      if (reviewsResponse.success && ratingResponse.success) {
        setState(() {
          _reviews = reviewsResponse.data ?? [];
          _averageRating = (ratingResponse.data ?? 0).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading reviews...')
          : Column(
              children: [
                // Rating Overview
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppTheme.softGray,
                  child: Column(
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingStars(rating: _averageRating, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '${_reviews.length} reviews',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Reviews List
                Expanded(
                  child: _reviews.isEmpty
                      ? const EmptyState(
                          message: 'No reviews yet',
                          icon: Icons.star_outline,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        UserAvatar(
                                          imageUrl: review
                                              .reviewer
                                              ?.profilePictureUrl,
                                          name: review.reviewer?.fullName,
                                          size: 40,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.reviewer?.fullName ??
                                                    'User',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                review.createdAt ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    RatingStars(
                                      rating: (review.rating ?? 0).toDouble(),
                                    ),
                                    if (review.comment != null &&
                                        review.comment!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(review.comment!),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
