import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/message_model.dart';
import 'package:signlink_app/providers/chat_provider.dart';
import 'package:signlink_app/services/chat_service.dart';

// ── Fake service ─────────────────────────────────────────────────────────────

class _FakeChatService implements ChatService {
  List<ConversationModel> _conversations;
  List<MessageModel> _messages;
  MessageModel? _sentMessage;

  _FakeChatService({
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    MessageModel? sentMessage,
  })  : _conversations = conversations ?? [],
        _messages = messages ?? [],
        _sentMessage = sentMessage;

  @override
  Future<List<ConversationModel>> getConversations(String userId) async =>
      _conversations;

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async =>
      _messages;

  @override
  Future<MessageModel?> sendMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required String messageBody,
  }) async =>
      _sentMessage;

  @override
  Future<void> markAsRead(String conversationId, String userId) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ConversationModel _makeConv({
  String id = 'conv-1',
  int unreadCount = 0,
}) =>
    ConversationModel(
      id: id,
      participantId: 'usr-2',
      participantName: 'Bob',
      participantRole: 'interpreter',
      lastMessage: 'Hi',
      lastMessageAt: DateTime(2026, 4, 1),
      unreadCount: unreadCount,
    );

MessageModel _makeMsg({String id = 'msg-1', String senderId = 'usr-1'}) =>
    MessageModel(
      id: id,
      senderId: senderId,
      receiverId: 'usr-2',
      conversationId: 'conv-1',
      messageBody: 'Test message',
      sentAt: DateTime(2026, 4, 1, 10),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ChatProvider — initial state', () {
    test('starts empty with no loading', () {
      final p = ChatProvider(service: _FakeChatService());
      expect(p.conversations, isEmpty);
      expect(p.messages, isEmpty);
      expect(p.isLoading, false);
      expect(p.totalUnread, 0);
      expect(p.activeConversationId, isNull);
    });
  });

  group('ChatProvider.loadConversations', () {
    test('populates conversations on success', () async {
      final convs = [_makeConv(id: 'c1'), _makeConv(id: 'c2')];
      final p = ChatProvider(service: _FakeChatService(conversations: convs));

      await p.loadConversations('usr-1');

      expect(p.conversations.length, 2);
      expect(p.isLoading, false);
    });

    test('results in empty list and no error message on failure', () async {
      final broken = _FakeChatServiceThatThrows();
      final p = ChatProvider(service: broken);

      await p.loadConversations('usr-1');

      expect(p.conversations, isEmpty);
      expect(p.isLoading, false);
    });

    test('calculates totalUnread as sum of all conversation unread counts', () async {
      final convs = [
        _makeConv(id: 'c1', unreadCount: 5),
        _makeConv(id: 'c2', unreadCount: 3),
      ];
      final p = ChatProvider(service: _FakeChatService(conversations: convs));
      await p.loadConversations('usr-1');

      expect(p.totalUnread, 8);
    });
  });

  group('ChatProvider.loadMessages', () {
    test('populates messages and sets activeConversationId', () async {
      final msgs = [_makeMsg(id: 'm1'), _makeMsg(id: 'm2')];
      final p = ChatProvider(service: _FakeChatService(messages: msgs));

      await p.loadMessages('conv-1');

      expect(p.messages.length, 2);
      expect(p.activeConversationId, 'conv-1');
      expect(p.isLoading, false);
    });

    test('results in empty messages on failure', () async {
      final p = ChatProvider(service: _FakeChatServiceThatThrows());
      await p.loadMessages('conv-1');
      expect(p.messages, isEmpty);
    });
  });

  group('ChatProvider.sendMessage', () {
    test('appends new message to messages list', () async {
      final sentMsg = _makeMsg(id: 'new-msg');
      final p = ChatProvider(
          service: _FakeChatService(
        messages: [_makeMsg(id: 'existing')],
        sentMessage: sentMsg,
      ));
      await p.loadMessages('conv-1');

      await p.sendMessage(
        senderId: 'usr-1',
        receiverId: 'usr-2',
        conversationId: 'conv-1',
        messageBody: 'Hello!',
      );

      expect(p.messages.length, 2);
      expect(p.messages.last.id, 'new-msg');
    });

    test('does not append when service returns null', () async {
      final p = ChatProvider(
        service: _FakeChatService(
          messages: [_makeMsg()],
          sentMessage: null, // service returned null
        ),
      );
      await p.loadMessages('conv-1');

      await p.sendMessage(
        senderId: 'usr-1',
        receiverId: 'usr-2',
        conversationId: 'conv-1',
        messageBody: 'Hi',
      );

      expect(p.messages.length, 1); // unchanged
    });
  });

  group('ChatProvider.markRead', () {
    test('zeros the unread count for the target conversation', () async {
      final convs = [
        _makeConv(id: 'c1', unreadCount: 4),
        _makeConv(id: 'c2', unreadCount: 2),
      ];
      final p = ChatProvider(service: _FakeChatService(conversations: convs));
      await p.loadConversations('usr-1');

      await p.markRead('c1', 'usr-1');

      expect(p.conversations.firstWhere((c) => c.id == 'c1').unreadCount, 0);
      expect(p.conversations.firstWhere((c) => c.id == 'c2').unreadCount, 2);
    });

    test('totalUnread decreases after markRead', () async {
      final convs = [_makeConv(id: 'c1', unreadCount: 5)];
      final p = ChatProvider(service: _FakeChatService(conversations: convs));
      await p.loadConversations('usr-1');

      await p.markRead('c1', 'usr-1');

      expect(p.totalUnread, 0);
    });
  });
}

// A fake that throws on all calls (simulates network failure).
class _FakeChatServiceThatThrows implements ChatService {
  @override
  Future<List<ConversationModel>> getConversations(String userId) async =>
      throw Exception('Network error');

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async =>
      throw Exception('Network error');

  @override
  Future<MessageModel?> sendMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required String messageBody,
  }) async =>
      throw Exception('Network error');

  @override
  Future<void> markAsRead(String conversationId, String userId) async =>
      throw Exception('Network error');
}
