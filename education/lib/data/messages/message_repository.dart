import 'package:education/data/messages/message.dart';
import 'package:education/data/messages/room.dart';

abstract class MessageRepository {
  Future<List<Room>> getRooms(String userId);
  Future<Room> findOrCreateRoom(String currentUserId, String otherUserId);
  Future<List<Message>> getMessages(String roomId);
  Future<Message> sendMessage(Message message);
  Future<void> markAsRead(String roomId, String userId);
  Stream<List<Message>> watchMessages(String roomId);
}
