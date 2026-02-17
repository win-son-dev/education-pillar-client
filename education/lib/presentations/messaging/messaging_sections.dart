import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/data/messages/room.dart';

class RoomTile extends StatelessWidget {
  final Room room;
  final String currentUserId;
  final VoidCallback? onTap;
  final ThemeData theme;

  const RoomTile({
    super.key,
    required this.room,
    required this.currentUserId,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final name = room.displayName(currentUserId);
    final imageUrl = room.displayImageUrl(currentUserId);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: ClipOval(
          child: imageUrl != null
              ? NetworkImageCard(imageUrl: imageUrl, width: 40, height: 40, fit: BoxFit.cover)
              : Text(name[0]),
        ),
      ),
      title: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: room.lastMessage != null
          ? Text(room.lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall)
          : null,
      trailing: room.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              child: Text(
                '${room.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
              ),
            )
          : null,
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMine;
  final ThemeData theme;

  const ChatBubble({super.key, required this.message, required this.isMine, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMine ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.content, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 8, top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -1))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: _send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => _send(_controller.text),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    widget.onSend(text.trim());
    _controller.clear();
  }
}
