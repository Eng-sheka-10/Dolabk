// lib/models/review_model.dart
import 'package:dolabk_app/models/user_model.dart';

class Review {
  final int id;
  final int reviewerId;
  final int reviewedUserId;
  final int? orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final User? reviewer;
  final User? reviewedUser;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewedUserId,
    this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewer,
    this.reviewedUser,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      reviewerId: json['reviewerId'],
      reviewedUserId: json['reviewedUserId'],
      orderId: json['orderId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      reviewer: json['reviewer'] != null
          ? User.fromJson(json['reviewer'])
          : null,
      reviewedUser: json['reviewedUser'] != null
          ? User.fromJson(json['reviewedUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'reviewer': reviewer?.toJson(),
      'reviewedUser': reviewedUser?.toJson(),
    };
  }
}
