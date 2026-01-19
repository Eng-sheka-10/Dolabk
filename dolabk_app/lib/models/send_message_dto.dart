// lib/models/send_message_dto.dart
class SendMessageDto {
  final int receiverId;
  final String content;

  SendMessageDto({required this.receiverId, required this.content});

  Map<String, dynamic> toJson() {
    return {'receiverId': receiverId, 'content': content};
  }
}
