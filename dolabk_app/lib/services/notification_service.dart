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

      final notifications = (response.data as List)
          .map((json) => Notification.fromJson(json))
          .toList();

      return ApiResponse.success(notifications);
    } catch (e) {
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
      final response = await getUnreadNotifications(pageSize: 1000);
      if (response.success && response.data != null) {
        return ApiResponse.success(response.data!.length);
      }
      return ApiResponse.success(0);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }
}
