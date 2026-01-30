// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart' as models;
import '../../models/enums.dart';
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
  List<models.Notification> _notifications = [];

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
        page: 1,
        pageSize: 50,
      );

      if (response.success && response.data != null) {
        setState(() {
          _notifications = response.data!;
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

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await _notificationService.markAsRead(notificationId);
      if (response.success) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            _notifications[index] = models.Notification(
              id: _notifications[index].id,
              userId: _notifications[index].userId,
              type: _notifications[index].type,
              title: _notifications[index].title,
              message: _notifications[index].message,
              isRead: true,
              relatedEntityId: _notifications[index].relatedEntityId,
              actionUrl: _notifications[index].actionUrl,
              createdAt: _notifications[index].createdAt,
            );
          }
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _notificationService.markAllAsRead();
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All notifications marked as read'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final response = await _notificationService.deleteNotification(notificationId);
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification deleted'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting notification'),
            backgroundColor: Colors.red,
          ),
        );
        _loadNotifications();
      }
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.ExchangeOffer:
        return Icons.swap_horiz;
      case NotificationType.OrderUpdate:
        return Icons.shopping_bag;
      case NotificationType.DeliveryUpdate:
        return Icons.local_shipping;
      case NotificationType.Message:
        return Icons.chat_bubble;
      case NotificationType.Review:
        return Icons.star;
      case NotificationType.System:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.ExchangeOffer:
        return Colors.blue;
      case NotificationType.OrderUpdate:
        return Colors.orange;
      case NotificationType.DeliveryUpdate:
        return Colors.purple;
      case NotificationType.Message:
        return AppTheme.primaryGreen;
      case NotificationType.Review:
        return Colors.amber;
      case NotificationType.System:
        return Colors.grey;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.ExchangeOffer:
        return 'Exchange Offer';
      case NotificationType.OrderUpdate:
        return 'Order Update';
      case NotificationType.DeliveryUpdate:
        return 'Delivery Update';
      case NotificationType.Message:
        return 'Message';
      case NotificationType.Review:
        return 'Review';
      case NotificationType.System:
        return 'System';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(models.Notification notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.Message:
        // Navigate to messages/chat
        // Navigator.pushNamed(context, '/chat', arguments: notification.relatedEntityId);
        break;
      case NotificationType.OrderUpdate:
        // Navigate to order details
        // Navigator.pushNamed(context, '/order-details', arguments: notification.relatedEntityId);
        break;
      case NotificationType.ExchangeOffer:
        // Navigate to exchange details
        // Navigator.pushNamed(context, '/exchange-details', arguments: notification.relatedEntityId);
        break;
      case NotificationType.DeliveryUpdate:
        // Navigate to delivery tracking
        // Navigator.pushNamed(context, '/delivery-tracking', arguments: notification.relatedEntityId);
        break;
      case NotificationType.Review:
        // Navigate to reviews
        // Navigator.pushNamed(context, '/reviews', arguments: notification.relatedEntityId);
        break;
      case NotificationType.System:
        // Show dialog or default action
        if (notification.actionUrl != null) {
          // Handle action URL
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading notifications...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadNotifications)
              : _notifications.isEmpty
                  ? const EmptyState(
                      message: 'No notifications yet',
                      icon: Icons.notifications_none,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppTheme.primaryGreen,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 72,
                        ),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final isRead = notification.isRead;

                          return Dismissible(
                            key: Key('notification_${notification.id}'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Notification'),
                                    content: const Text(
                                      'Are you sure you want to delete this notification?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              _deleteNotification(notification.id);
                              setState(() {
                                _notifications.removeAt(index);
                              });
                            },
                            child: Container(
                              color: isRead
                                  ? null
                                  : _getNotificationColor(notification.type)
                                      .withOpacity(0.05),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? Colors.grey[300]
                                        : _getNotificationColor(notification.type)
                                            .withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(notification.type),
                                    color: isRead
                                        ? Colors.grey[600]
                                        : _getNotificationColor(notification.type),
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title ?? 'Notification',
                                        style: TextStyle(
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getNotificationColor(
                                              notification.type),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (notification.message != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.message!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getNotificationColor(
                                                    notification.type)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getNotificationTypeLabel(
                                                notification.type),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: _getNotificationColor(
                                                  notification.type),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatDate(notification.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: notification.message != null,
                                onTap: () => _handleNotificationTap(notification),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}