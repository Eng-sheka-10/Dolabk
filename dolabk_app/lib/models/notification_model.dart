// lib/models/notification_model.dart
import 'package:dolabk_app/models/enums.dart';

class Notification {
  final int id;
  final int userId;
  final NotificationType type;
  final String? title;
  final String? message;
  final bool isRead;
  final int? relatedEntityId;
  final String? actionUrl;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    this.title,
    this.message,
    required this.isRead,
    this.relatedEntityId,
    this.actionUrl,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['userId'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.System,
      ),
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      relatedEntityId: json['relatedEntityId'],
      actionUrl: json['actionUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
