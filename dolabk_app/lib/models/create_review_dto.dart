// lib/models/create_review_dto.dart
class CreateReviewDto {
  final int reviewedUserId;
  final int? orderId;
  final int rating;
  final String? comment;

  CreateReviewDto({
    required this.reviewedUserId,
    this.orderId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'reviewedUserId': reviewedUserId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}
