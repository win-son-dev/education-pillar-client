import 'package:centralized_library/centralized_library.dart';

enum RoomType { private, group }

class RoomMember extends Equatable {
  final String userId;
  final String name;
  final String? imageUrl;

  const RoomMember({
    required this.userId,
    required this.name,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userId, name, imageUrl];
}

class Room extends Equatable {
  final String roomId;
  final RoomType type;
  final List<RoomMember> members;
  final String? name;
  final String? lastMessage;
  final int unreadCount;

  const Room({
    required this.roomId,
    required this.type,
    required this.members,
    this.name,
    this.lastMessage,
    this.unreadCount = 0,
  });

  /// Returns the display name for this room.
  /// For private rooms, returns the other member's name.
  /// For group rooms, returns the room name or a comma-separated list of member names.
  String displayName(String currentUserId) {
    if (name != null) return name!;
    if (type == RoomType.private) {
      final other = members.where((m) => m.userId != currentUserId).firstOrNull;
      return other?.name ?? 'Unknown';
    }
    return members.map((m) => m.name).join(', ');
  }

  /// Returns the display image URL for this room.
  /// For private rooms, returns the other member's image URL.
  String? displayImageUrl(String currentUserId) {
    if (type == RoomType.private) {
      final other = members.where((m) => m.userId != currentUserId).firstOrNull;
      return other?.imageUrl;
    }
    return null;
  }

  @override
  List<Object?> get props => [roomId, type, members, name, lastMessage, unreadCount];

  Room copyWith({
    String? name,
    String? lastMessage,
    int? unreadCount,
  }) {
    return Room(
      roomId: roomId,
      type: type,
      members: members,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
