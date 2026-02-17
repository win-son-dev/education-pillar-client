import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/data/messages/room.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();
  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {}

class MessagingLoading extends MessagingState {}

class RoomsLoaded extends MessagingState {
  final List<Room> rooms;
  const RoomsLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class MessagesLoaded extends MessagingState {
  final List<Message> messages;
  final String roomId;
  const MessagesLoaded({required this.messages, required this.roomId});
  @override
  List<Object?> get props => [messages, roomId];
}

class MessagingError extends MessagingState {
  final String message;
  const MessagingError(this.message);
  @override
  List<Object?> get props => [message];
}
