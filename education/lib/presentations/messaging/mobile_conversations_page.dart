import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_state.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/messaging/messaging_sections.dart';

class MobileConversationsPage extends StatelessWidget {
  const MobileConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = sl<CurrentUserService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        builder: (context, state) {
          if (state is MessagingLoading) return const Center(child: CircularProgressIndicator());
          if (state is RoomsLoaded) {
            if (state.rooms.isEmpty) return const Center(child: Text('No conversations'));
            return ListView.separated(
              itemCount: state.rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return RoomTile(
                  room: room,
                  currentUserId: currentUser.userId,
                  theme: theme,
                  onTap: () => context.push('/chat/${room.roomId}'),
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
