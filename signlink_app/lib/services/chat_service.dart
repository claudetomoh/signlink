import '../models/message_model.dart';
import 'api_service.dart';

/// ChatService — backed by the real REST API.
class ChatService {
  final _api = ApiService.instance;

  // GET /api/messages/conversations.php
  Future<List<ConversationModel>> getConversations(String userId) async {
    final data = await _api.get('/messages/conversations.php');
    final list = data['conversations'] as List<dynamic>;
    return list
        .map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  // GET /api/messages/list.php?conversation_id=<id>
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await _api.get(
      '/messages/list.php',
      params: {'conversation_id': conversationId},
    );
    final list = data['messages'] as List<dynamic>;
    return list
        .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  // POST /api/messages/send.php
  Future<MessageModel?> sendMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required String messageBody,
  }) async {
    final data = await _api.post('/messages/send.php', {
      'conversation_id': conversationId,
      'text': messageBody,
    });
    final msgJson = data['message'] as Map<String, dynamic>?;
    if (msgJson == null) return null;
    return MessageModel.fromJson(msgJson);
  }

  // POST /api/messages/list.php (reading marks messages as read server-side)
  Future<void> markAsRead(String conversationId, String userId) async {
    // Reading the conversation via list.php already marks messages as read.
    // No separate call needed.
  }
}
