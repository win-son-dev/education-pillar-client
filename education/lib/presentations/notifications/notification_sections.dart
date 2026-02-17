import 'package:flutter/material.dart';
import 'package:education/data/notifications/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final ThemeData theme;

  const NotificationTile({super.key, required this.notification, this.onTap, required this.theme});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.bookingCancelled:
        return Icons.cancel_outlined;
      case NotificationType.scheduleChanged:
        return Icons.schedule;
      case NotificationType.newMessage:
        return Icons.message_outlined;
      case NotificationType.newReview:
        return Icons.star_outline;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Colors.green;
      case NotificationType.bookingCancelled:
        return Colors.red;
      case NotificationType.scheduleChanged:
        return Colors.orange;
      case NotificationType.newMessage:
        return Colors.blue;
      case NotificationType.newReview:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _colorForType(notification.type).withValues(alpha: 0.15),
        child: Icon(_iconForType(notification.type), color: _colorForType(notification.type)),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
      trailing: !notification.isRead
          ? Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle))
          : null,
    );
  }
}
