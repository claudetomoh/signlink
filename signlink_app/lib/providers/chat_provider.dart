import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  String? _activeConversationId;
  bool _isLoading = false;

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);
  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get activeConversationId => _activeConversationId;

  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  final ChatService _service;
  ChatProvider({ChatService? service}) : _service = service ?? ChatService();

  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _conversations = await _service.getConversations(userId);
    } catch (_) {
      _conversations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _activeConversationId = conversationId;
    notifyListeners();
    try {
      _messages = await _service.getMessages(conversationId);
    } catch (_) {
      _messages = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required String messageBody,
  }) async {
    final msg = await _service.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      conversationId: conversationId,
      messageBody: messageBody,
    );
    if (msg != null) {
      _messages = [..._messages, msg];
      notifyListeners();
    }
  }

  Future<void> markRead(String conversationId, String userId) async {
    await _service.markAsRead(conversationId, userId);
    _conversations = _conversations.map((c) {
      if (c.id == conversationId) {
        return ConversationModel(
          id: c.id,
          participantId: c.participantId,
          participantName: c.participantName,
          participantPhoto: c.participantPhoto,
          participantRole: c.participantRole,
          lastMessage: c.lastMessage,
          lastMessageAt: c.lastMessageAt,
          unreadCount: 0,
          isOnline: c.isOnline,
        );
      }
      return c;
    }).toList();
    notifyListeners();
  }
}
