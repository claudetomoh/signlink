class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String type; // 'request' | 'schedule' | 'event' | 'message' | 'system'
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        type: map['type'] as String,
        isRead: (map['is_read'] as bool?) ?? false,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Construct from the REST API JSON response.
  /// API fields: id, userId, title, body, type, relatedId, isRead, createdAt
  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['id'] as String,
        userId: j['userId'] as String,
        title: j['title'] as String,
        content: j['body'] as String,     // API sends 'body', model uses 'content'
        type: j['type'] as String,
        isRead: (j['isRead'] as bool?) ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'type': type,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}
