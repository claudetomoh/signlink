class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String conversationId;
  final String messageBody;
  final DateTime sentAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.conversationId,
    required this.messageBody,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        receiverId: map['receiver_id'] as String,
        conversationId: map['conversation_id'] as String,
        messageBody: map['message_body'] as String,
        sentAt: DateTime.parse(map['sent_at'] as String),
        isRead: (map['is_read'] as bool?) ?? false,
      );

  /// Construct from the REST API JSON response.
  /// API fields: id, conversationId, senderId, text, isRead, isMe, createdAt
  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        receiverId: '',          // not returned by list endpoint
        conversationId: j['conversationId'] as String,
        messageBody: j['text'] as String,
        sentAt: DateTime.parse(j['createdAt'] as String),
        isRead: (j['isRead'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'conversation_id': conversationId,
        'message_body': messageBody,
        'sent_at': sentAt.toIso8601String(),
        'is_read': isRead,
      };

  bool isSentBy(String userId) => senderId == userId;
}

class ConversationModel {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantPhoto;
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isOnline;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantPhoto,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) => ConversationModel(
        id: map['id'] as String,
        participantId: map['participant_id'] as String,
        participantName: map['participant_name'] as String,
        participantPhoto: map['participant_photo'] as String?,
        participantRole: map['participant_role'] as String,
        lastMessage: map['last_message'] as String,
        lastMessageAt: DateTime.parse(map['last_message_at'] as String),
        unreadCount: (map['unread_count'] as int?) ?? 0,
        isOnline: (map['is_online'] as bool?) ?? false,
      );

  /// Construct from the REST API JSON response.
  /// API shape: { id, otherUser: {id, name, role, avatarUrl},
  ///              lastMessage, lastMessageAt, unreadCount }
  factory ConversationModel.fromJson(Map<String, dynamic> j) {
    final other = j['otherUser'] as Map<String, dynamic>;  
    return ConversationModel(
      id: j['id'] as String,
      participantId: other['id'] as String,
      participantName: other['name'] as String,
      participantPhoto: other['avatarUrl'] as String?,
      participantRole: other['role'] as String,
      lastMessage: (j['lastMessage'] as String?) ?? '',
      lastMessageAt: j['lastMessageAt'] != null
          ? DateTime.parse(j['lastMessageAt'] as String)
          : DateTime.now(),
      unreadCount: (j['unreadCount'] as int?) ?? 0,
    );
  }
}
