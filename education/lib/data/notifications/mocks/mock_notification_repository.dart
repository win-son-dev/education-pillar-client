import 'dart:async';

import 'package:education/data/notifications/app_notification.dart';
import 'package:education/data/notifications/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(
      notificationId: 'notif-1',
      userId: 'student-1',
      type: NotificationType.bookingConfirmed,
      title: 'Booking Confirmed',
      body: 'Your lesson with Sarah Johnson on Monday at 9 AM has been confirmed.',
      referenceId: 'booking-1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      notificationId: 'notif-2',
      userId: 'student-1',
      type: NotificationType.newMessage,
      title: 'New Message',
      body: 'Sarah Johnson sent you a message.',
      referenceId: 'conv-1',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      notificationId: 'notif-3',
      userId: 'tutor-1',
      type: NotificationType.newReview,
      title: 'New Review',
      body: 'Alex Rivera left you a 5-star review!',
      referenceId: 'rev-1',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      notificationId: 'notif-4',
      userId: 'student-1',
      type: NotificationType.scheduleChanged,
      title: 'Schedule Updated',
      body: 'Michael Chen updated their availability for next week.',
      referenceId: 'tutor-2',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  final _controller = StreamController<List<AppNotification>>.broadcast();

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _notifyListeners();
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _controller.stream.map(
      (notifications) => notifications.where((n) => n.userId == userId).toList(),
    );
  }

  void _notifyListeners() {
    if (!_controller.isClosed) {
      _controller.add(List.of(_notifications));
    }
  }
}
