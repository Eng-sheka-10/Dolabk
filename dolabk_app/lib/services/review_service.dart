// lib/services/review_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/review_model.dart';
import '../models/create_review_dto.dart';

class ReviewService {
  final DioClient _dioClient;

  ReviewService(this._dioClient);

  // Create review
  Future<ApiResponse<Review>> createReview(CreateReviewDto reviewDto) async {
    try {
      final response = await _dioClient.post(
        '/api/Reviews',
        data: reviewDto.toJson(),
      );

      final review = Review.fromJson(response.data);
      return ApiResponse.success(review);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get review by ID
  Future<ApiResponse<Review>> getReviewById(int id) async {
    try {
      final response = await _dioClient.get('/api/Reviews/$id');
      final review = Review.fromJson(response.data);
      return ApiResponse.success(review);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get reviews for a user
  Future<ApiResponse<List<Review>>> getUserReviews(int userId) async {
    try {
      final response = await _dioClient.get('/api/Reviews/user/$userId');

      final reviews = (response.data as List)
          .map((json) => Review.fromJson(json))
          .toList();

      return ApiResponse.success(reviews);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Quick create review
  Future<ApiResponse<Review>> quickCreateReview(
    int reviewedUserId,
    int rating,
    String comment, {
    int? orderId,
  }) async {
    final reviewDto = CreateReviewDto(
      reviewedUserId: reviewedUserId,
      rating: rating,
      comment: comment,
      orderId: orderId,
    );
    return createReview(reviewDto);
  }

  // Calculate average rating for a user
  Future<ApiResponse<double>> getUserAverageRating(int userId) async {
    try {
      final response = await getUserReviews(userId);
      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        final reviews = response.data!;
        final totalRating = reviews.fold<int>(
          0,
          (sum, review) => sum + review.rating,
        );
        final average = totalRating / reviews.length;
        return ApiResponse.success(average);
      }
      return ApiResponse.success(0.0);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }
}
