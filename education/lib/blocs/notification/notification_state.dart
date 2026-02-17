import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/notifications/app_notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<AppNotification> notifications;
  const NotificationsLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}
