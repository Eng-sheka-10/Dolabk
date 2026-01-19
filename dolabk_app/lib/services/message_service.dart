// lib/services/message_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/message_model.dart';
import '../models/send_message_dto.dart';

class MessageService {
  final DioClient _dioClient;

  MessageService(this._dioClient);

  // Send message
  Future<ApiResponse<Message>> sendMessage(SendMessageDto messageDto) async {
    try {
      final response = await _dioClient.post(
        '/api/Messages',
        data: messageDto.toJson(),
      );

      final message = Message.fromJson(response.data);
      return ApiResponse.success(message);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get message by ID
  Future<ApiResponse<Message>> getMessageById(int id) async {
    try {
      final response = await _dioClient.get('/api/Messages/$id');
      final message = Message.fromJson(response.data);
      return ApiResponse.success(message);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get conversation with another user
  Future<ApiResponse<List<Message>>> getConversation(int otherUserId) async {
    try {
      final response = await _dioClient.get(
        '/api/Messages/conversation/$otherUserId',
      );

      // FIX: Handle both list and paginated responses
      List<Message> messages;
      if (response.data is List) {
        messages = (response.data as List)
            .map((json) => Message.fromJson(json))
            .toList();
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final items = data['items'] ?? data['data'] ?? data['messages'] ?? [];
        messages = (items as List)
            .map((json) => Message.fromJson(json))
            .toList();
      } else {
        messages = [];
      }

      return ApiResponse.success(messages);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get all conversations
  Future<ApiResponse<List<Map<String, dynamic>>>> getConversations() async {
    try {
      final response = await _dioClient.get('/api/Messages/conversations');

      // FIX: Properly handle the response data structure
      List<Map<String, dynamic>> conversations;

      if (response.data is List) {
        // Convert to List<Map<String, dynamic>>
        conversations = (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final items =
            data['items'] ?? data['data'] ?? data['conversations'] ?? [];
        conversations = (items as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        conversations = [];
      }

      return ApiResponse.success(conversations);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Quick send message
  Future<ApiResponse<Message>> quickSendMessage(
    int receiverId,
    String content,
  ) async {
    final messageDto = SendMessageDto(receiverId: receiverId, content: content);
    return sendMessage(messageDto);
  }
}
