import 'dart:async';

import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/messages/message.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/data/messages/room.dart';

class MockMessageRepository implements MessageRepository {
  final List<Room> _rooms = [
    const Room(
      roomId: 'room-1',
      type: RoomType.private,
      members: [
        RoomMember(
          userId: 'tutor-1',
          name: 'Sarah Johnson',
          imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        ),
        RoomMember(
          userId: 'student-1',
          name: 'Alex Rivera',
          imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
        ),
      ],
      lastMessage: 'See you tomorrow at 9 AM!',
      unreadCount: 1,
    ),
    const Room(
      roomId: 'room-2',
      type: RoomType.private,
      members: [
        RoomMember(
          userId: 'tutor-2',
          name: 'Michael Chen',
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        ),
        RoomMember(
          userId: 'student-1',
          name: 'Alex Rivera',
          imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
        ),
      ],
      lastMessage: 'Great progress on the calculus problems!',
      unreadCount: 0,
    ),
  ];

  final Map<String, List<Message>> _messages = {
    'room-1': [
      Message(
        messageId: 'msg-1',
        roomId: 'room-1',
        senderId: 'student-1',
        content: 'Hi Sarah! I wanted to ask about the IELTS reading section.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      Message(
        messageId: 'msg-2',
        roomId: 'room-1',
        senderId: 'tutor-1',
        content: 'Of course! We can go over some strategies in our next lesson.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Message(
        messageId: 'msg-3',
        roomId: 'room-1',
        senderId: 'tutor-1',
        content: 'See you tomorrow at 9 AM!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
    ],
    'room-2': [
      Message(
        messageId: 'msg-4',
        roomId: 'room-2',
        senderId: 'tutor-2',
        content: 'Great progress on the calculus problems!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ],
  };

  final _messageControllers = <String, StreamController<List<Message>>>{};

  @override
  Future<List<Room>> getRooms(String userId) async {
    return _rooms.where(
      (r) => r.members.any((m) => m.userId == userId),
    ).toList();
  }

  @override
  Future<Room> findOrCreateRoom(String currentUserId, String otherUserId) async {
    // Find existing private room with both members
    final existing = _rooms.where((r) =>
      r.type == RoomType.private &&
      r.members.any((m) => m.userId == currentUserId) &&
      r.members.any((m) => m.userId == otherUserId),
    );
    if (existing.isNotEmpty) return existing.first;

    // Create new room
    final newRoom = Room(
      roomId: const Uuid().v4(),
      type: RoomType.private,
      members: [
        RoomMember(userId: currentUserId, name: currentUserId),
        RoomMember(userId: otherUserId, name: otherUserId),
      ],
    );
    _rooms.add(newRoom);
    return newRoom;
  }

  @override
  Future<List<Message>> getMessages(String roomId) async {
    final messages = _messages[roomId] ?? [];
    return List.of(messages)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<Message> sendMessage(Message message) async {
    _messages.putIfAbsent(message.roomId, () => []);
    _messages[message.roomId]!.add(message);

    // Update room's last message
    final roomIndex = _rooms.indexWhere((r) => r.roomId == message.roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = _rooms[roomIndex].copyWith(
        lastMessage: message.content,
        unreadCount: _rooms[roomIndex].unreadCount + 1,
      );
    }

    // Notify stream listeners
    _notifyMessageListeners(message.roomId);
    return message;
  }

  @override
  Future<void> markAsRead(String roomId, String userId) async {
    final messages = _messages[roomId];
    if (messages == null) return;

    for (var i = 0; i < messages.length; i++) {
      if (messages[i].senderId != userId && !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true);
      }
    }

    final roomIndex = _rooms.indexWhere((r) => r.roomId == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = _rooms[roomIndex].copyWith(unreadCount: 0);
    }
  }

  @override
  Stream<List<Message>> watchMessages(String roomId) {
    _messageControllers.putIfAbsent(
      roomId,
      () => StreamController<List<Message>>.broadcast(),
    );
    return _messageControllers[roomId]!.stream;
  }

  void _notifyMessageListeners(String roomId) {
    final controller = _messageControllers[roomId];
    if (controller != null && !controller.isClosed) {
      final messages = _messages[roomId] ?? [];
      controller.add(List.of(messages)..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
    }
  }
}
