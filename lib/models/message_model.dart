enum MessageType { text, image, video, document, audio }

enum MessageStatus { sending, sent, delivered, read }

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final bool isDeleted;
  final DateTime? editedAt;
  final String? mediaData; // New field for base64 data
  final String? mimeType; // New fi

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    this.mediaUrl,
    this.thumbnailUrl,
    this.metadata,
    this.isDeleted = false,
    this.editedAt,
    this.mediaData,
    this.mimeType, // New field for media type
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
      'isDeleted': isDeleted,
      'editedAt': editedAt?.toIso8601String(),
      'mediaData': mediaData, // New field for base64 data
      'mimeType': mimeType, // New field for media type
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      metadata: json['metadata'],
      isDeleted: json['isDeleted'] ?? false,
      editedAt:
          json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      mediaData: json['mediaData'], // New field for base64 data
      mimeType: json['mimeType'], // New field for media type
    );
  }
}
