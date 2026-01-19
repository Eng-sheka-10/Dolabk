// lib/models/message_model.dart
import 'package:dolabk_app/models/user_model.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String? content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final User? sender;
  final User? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null
          ? User.fromJson(json['receiver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }
}
