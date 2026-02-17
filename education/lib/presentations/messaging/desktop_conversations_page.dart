import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/messaging/messaging_state.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/messaging/messaging_sections.dart';

class DesktopConversationsPage extends StatefulWidget {
  const DesktopConversationsPage({super.key});

  @override
  State<DesktopConversationsPage> createState() => _DesktopConversationsPageState();
}

class _DesktopConversationsPageState extends State<DesktopConversationsPage> {
  String? _selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = sl<CurrentUserService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              SizedBox(
                width: 360,
                child: BlocBuilder<MessagingBloc, MessagingState>(
                  builder: (context, state) {
                    if (state is RoomsLoaded) {
                      return ListView.separated(
                        itemCount: state.rooms.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final room = state.rooms[index];
                          return RoomTile(
                            room: room,
                            currentUserId: currentUser.userId,
                            theme: theme,
                            onTap: () {
                              setState(() => _selectedRoomId = room.roomId);
                              context.read<MessagingBloc>().add(LoadMessages(room.roomId));
                              context.read<MessagingBloc>().add(MarkRoomRead(room.roomId));
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _selectedRoomId == null
                    ? const Center(child: Text('Select a conversation'))
                    : Column(
                        children: [
                          Expanded(
                            child: BlocBuilder<MessagingBloc, MessagingState>(
                              builder: (context, state) {
                                if (state is MessagesLoaded) {
                                  return ListView.builder(
                                    reverse: true,
                                    itemCount: state.messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = state.messages[state.messages.length - 1 - index];
                                      return ChatBubble(message: msg, isMine: msg.senderId == currentUser.userId, theme: theme);
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          MessageInput(
                            onSend: (content) {
                              context.read<MessagingBloc>().add(SendMessage(Message(
                                messageId: const Uuid().v4(),
                                roomId: _selectedRoomId!,
                                senderId: currentUser.userId,
                                content: content,
                                timestamp: DateTime.now(),
                              )));
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
