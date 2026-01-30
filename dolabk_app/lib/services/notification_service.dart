// lib/services/notification_service.dart
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/notification_model.dart';

class NotificationService {
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  // Get all notifications
  Future<ApiResponse<List<Notification>>> getNotifications({
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

      if (isRead != null) {
        queryParams['isRead'] = isRead;
      }

      final response = await _dioClient.get(
        '/api/Notifications',
        queryParameters: queryParams,
      );

      // Parse response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final dataList = (responseData['data'] as List?) ?? [];
        
        final notifications = dataList
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(notifications);
      }

      return ApiResponse.error('Invalid response format');
    } catch (e) {
      print('Error in getNotifications: $e');
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Mark notification as read
  Future<ApiResponse<void>> markAsRead(int id) async {
    try {
      await _dioClient.put('/api/Notifications/$id/mark-read');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      await _dioClient.put('/api/Notifications/mark-all-read');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Delete notification
  Future<ApiResponse<void>> deleteNotification(int id) async {
    try {
      await _dioClient.delete('/api/Notifications/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get unread notifications
  Future<ApiResponse<List<Notification>>> getUnreadNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getNotifications(isRead: false, page: page, pageSize: pageSize);
  }

  // Get read notifications
  Future<ApiResponse<List<Notification>>> getReadNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return getNotifications(isRead: true, page: page, pageSize: pageSize);
  }

  // Get notification count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _dioClient.get(
        '/api/Notifications',
        queryParameters: {'page': 1, 'pageSize': 1},
      );
      
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final unreadCount = (responseData['unreadCount'] as int?) ?? 0;
        return ApiResponse.success(unreadCount);
      }
      
      return ApiResponse.success(0);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }
}