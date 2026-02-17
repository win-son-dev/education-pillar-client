import 'package:centralized_library/centralized_library.dart';

class Message extends Equatable {
  final String messageId;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    messageId,
    roomId,
    senderId,
    content,
    timestamp,
    isRead,
  ];

  Message copyWith({
    String? content,
    bool? isRead,
  }) {
    return Message(
      messageId: messageId,
      roomId: roomId,
      senderId: senderId,
      content: content ?? this.content,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
