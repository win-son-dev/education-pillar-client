import 'package:centralized_library/centralized_library.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  const MarkNotificationRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsRead extends NotificationEvent {}
