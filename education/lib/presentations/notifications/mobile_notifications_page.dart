import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/notification/notification_bloc.dart';
import 'package:education/blocs/notification/notification_event.dart';
import 'package:education/blocs/notification/notification_state.dart';
import 'package:education/presentations/notifications/notification_sections.dart';

class MobileNotificationsPage extends StatelessWidget {
  const MobileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationBloc>().add(MarkAllNotificationsRead()),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) return const Center(child: CircularProgressIndicator());
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) return const Center(child: Text('No notifications'));
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                return NotificationTile(
                  notification: notif,
                  theme: theme,
                  onTap: () {
                    context.read<NotificationBloc>().add(MarkNotificationRead(notif.notificationId));
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
