import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/notifications/notification_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/blocs/notification/notification_event.dart';
import 'package:education/blocs/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  final CurrentUserService _currentUserService;

  NotificationBloc({
    required NotificationRepository notificationRepository,
    required CurrentUserService currentUserService,
  })  : _notificationRepository = notificationRepository,
        _currentUserService = currentUserService,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final notifications = await _notificationRepository.getNotifications(_currentUserService.userId);
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    try {
      await _notificationRepository.markAsRead(event.notificationId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    try {
      await _notificationRepository.markAllAsRead(_currentUserService.userId);
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
