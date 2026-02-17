import 'package:education/data/notifications/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Stream<List<AppNotification>> watchNotifications(String userId);
}
