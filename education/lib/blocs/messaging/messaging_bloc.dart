import 'dart:async';

import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/messaging/messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessageRepository _messageRepository;
  final CurrentUserService _currentUserService;
  StreamSubscription<dynamic>? _messageSubscription;

  MessagingBloc({
    required MessageRepository messageRepository,
    required CurrentUserService currentUserService,
  })  : _messageRepository = messageRepository,
        _currentUserService = currentUserService,
        super(MessagingInitial()) {
    on<LoadRooms>(_onLoadRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkRoomRead>(_onMarkRoomRead);
    on<MessagesUpdated>(_onMessagesUpdated);
  }

  Future<void> _onLoadRooms(LoadRooms event, Emitter<MessagingState> emit) async {
    emit(MessagingLoading());
    try {
      final rooms = await _messageRepository.getRooms(_currentUserService.userId);
      emit(RoomsLoaded(rooms));
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessagingState> emit) async {
    emit(MessagingLoading());
    try {
      final messages = await _messageRepository.getMessages(event.roomId);
      emit(MessagesLoaded(messages: messages, roomId: event.roomId));

      _messageSubscription?.cancel();
      _messageSubscription = _messageRepository.watchMessages(event.roomId).listen(
        (messages) => add(MessagesUpdated(messages)),
      );
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessagingState> emit) async {
    try {
      await _messageRepository.sendMessage(event.message);
      final messages = await _messageRepository.getMessages(event.message.roomId);
      emit(MessagesLoaded(messages: messages, roomId: event.message.roomId));
    } catch (e) {
      emit(MessagingError(e.toString()));
    }
  }

  Future<void> _onMarkRoomRead(MarkRoomRead event, Emitter<MessagingState> emit) async {
    try {
      await _messageRepository.markAsRead(event.roomId, _currentUserService.userId);
    } catch (_) {}
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<MessagingState> emit) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(MessagesLoaded(messages: event.messages, roomId: currentState.roomId));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
