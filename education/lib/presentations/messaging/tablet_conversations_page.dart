import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/messaging/messaging_state.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/messaging/messaging_sections.dart';

class TabletConversationsPage extends StatefulWidget {
  const TabletConversationsPage({super.key});

  @override
  State<TabletConversationsPage> createState() => _TabletConversationsPageState();
}

class _TabletConversationsPageState extends State<TabletConversationsPage> {
  String? _selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = sl<CurrentUserService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Row(
        children: [
          SizedBox(
            width: 320,
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
    );
  }
}
