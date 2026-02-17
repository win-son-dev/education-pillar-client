import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/messaging/messaging_state.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/messaging/messaging_sections.dart';

class ChatPage extends StatelessWidget {
  final String roomId;

  const ChatPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = sl<CurrentUserService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessagingBloc, MessagingState>(
              builder: (context, state) {
                if (state is MessagingLoading) return const Center(child: CircularProgressIndicator());
                if (state is MessagesLoaded) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[state.messages.length - 1 - index];
                      return ChatBubble(
                        message: message,
                        isMine: message.senderId == currentUser.userId,
                        theme: theme,
                      );
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
                roomId: roomId,
                senderId: currentUser.userId,
                content: content,
                timestamp: DateTime.now(),
              )));
            },
          ),
        ],
      ),
    );
  }
}
