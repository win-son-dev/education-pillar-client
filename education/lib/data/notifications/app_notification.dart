import 'package:centralized_library/centralized_library.dart';

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  scheduleChanged,
  newMessage,
  newReview,
}

class AppNotification extends Equatable {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? referenceId;
  final DateTime timestamp;
  final bool isRead;

  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    notificationId,
    userId,
    type,
    title,
    body,
    referenceId,
    timestamp,
    isRead,
  ];

  AppNotification copyWith({
    String? title,
    String? body,
    bool? isRead,
  }) {
    return AppNotification(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
