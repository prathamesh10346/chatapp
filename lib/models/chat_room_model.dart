import 'package:chatapp/models/message_model.dart';

class ChatRoomModel {
  final String roomId;
  final List<String> participants;
  final DateTime lastMessageTime;
  final String? lastMessage;
  final MessageType? lastMessageType;
  final Map<String, int> unreadCount;
  final Map<String, DateTime> lastSeen;

  ChatRoomModel({
    required this.roomId,
    required this.participants,
    required this.lastMessageTime,
    this.lastMessage,
    this.lastMessageType,
    required this.unreadCount,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'participants': participants,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType?.toString(),
      'unreadCount': unreadCount,
      'lastSeen': lastSeen.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      roomId: json['roomId'],
      participants: List<String>.from(json['participants']),
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      lastMessage: json['lastMessage'],
      lastMessageType: json['lastMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) => e.toString() == json['lastMessageType'],
            )
          : null,
      unreadCount: Map<String, int>.from(json['unreadCount']),
      lastSeen: Map<String, DateTime>.from(
        json['lastSeen'].map(
          (key, value) => MapEntry(key, DateTime.parse(value)),
        ),
      ),
    );
  }
}