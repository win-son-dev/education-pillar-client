import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/messages/message.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();
  @override
  List<Object?> get props => [];
}

class LoadRooms extends MessagingEvent {}

class LoadMessages extends MessagingEvent {
  final String roomId;
  const LoadMessages(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SendMessage extends MessagingEvent {
  final Message message;
  const SendMessage(this.message);
  @override
  List<Object?> get props => [message];
}

class MarkRoomRead extends MessagingEvent {
  final String roomId;
  const MarkRoomRead(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class MessagesUpdated extends MessagingEvent {
  final List<Message> messages;
  const MessagesUpdated(this.messages);
  @override
  List<Object?> get props => [messages];
}
