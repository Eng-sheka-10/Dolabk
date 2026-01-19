// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/notification_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = getIt<NotificationService>();

  bool _isLoading = true;
  String? _error;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _notificationService.getNotifications(
        isRead: null,
        page: 1,
        pageSize: 50,
      );

      if (response.success) {
        setState(() {
          _notifications = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(int.parse(notificationId));
      _loadNotifications();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'exchange':
        return Icons.swap_horiz;
      case 'order':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      case 'message':
        return Icons.chat_bubble;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.isRead == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading notifications...')
          : _error != null
          ? ErrorState(message: _error!, onRetry: _loadNotifications)
          : _notifications.isEmpty
          ? const EmptyState(
              message: 'No notifications',
              icon: Icons.notifications_none,
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification.isRead ?? false;

                  return Dismissible(
                    key: Key(notification.id ?? '$index'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      // TODO: Delete notification
                    },
                    child: Container(
                      color: isRead
                          ? null
                          : AppTheme.primaryGreen.withOpacity(0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRead
                              ? Colors.grey[300]
                              : AppTheme.primaryGreen,
                          child: Icon(
                            _getNotificationIcon(notification.type ?? ''),
                            color: isRead ? Colors.grey : Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.title ?? 'Notification',
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notification.message != null)
                              Text(notification.message!),
                            const SizedBox(height: 4),
                            Text(
                              notification.createdAt ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(notification.id);
                          }
                          // TODO: Navigate based on notification type
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
