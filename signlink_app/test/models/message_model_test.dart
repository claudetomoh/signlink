import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/message_model.dart';

void main() {
  // API JSON for a single message (from list.php).
  const _msgJson = <String, dynamic>{
    'id': 'msg-1',
    'senderId': 'usr-1',
    'conversationId': 'conv-1',
    'text': 'Hello there!',
    'isRead': false,
    'isMe': true,
    'createdAt': '2026-04-10T10:00:00.000',
  };

  // Local DB map fixture.
  const _msgMap = <String, dynamic>{
    'id': 'msg-2',
    'sender_id': 'usr-2',
    'receiver_id': 'usr-1',
    'conversation_id': 'conv-1',
    'message_body': 'Hi back!',
    'sent_at': '2026-04-10T10:01:00.000',
    'is_read': true,
  };

  // API JSON for a conversation (from conversations.php).
  const _convJson = <String, dynamic>{
    'id': 'conv-1',
    'otherUser': {
      'id': 'usr-2',
      'name': 'Bob Jones',
      'role': 'interpreter',
      'avatarUrl': 'https://example.com/bob.jpg',
    },
    'lastMessage': 'See you tomorrow',
    'lastMessageAt': '2026-04-10T09:00:00.000',
    'unreadCount': 3,
  };

  group('MessageModel.fromJson', () {
    test('parses all fields from API JSON', () {
      final m = MessageModel.fromJson(_msgJson);
      expect(m.id, 'msg-1');
      expect(m.senderId, 'usr-1');
      expect(m.conversationId, 'conv-1');
      expect(m.messageBody, 'Hello there!');
      expect(m.isRead, false);
      expect(m.sentAt, DateTime.parse('2026-04-10T10:00:00.000'));
    });

    test("maps API field 'text' to messageBody", () {
      expect(MessageModel.fromJson(_msgJson).messageBody, 'Hello there!');
    });

    test("maps API field 'createdAt' to sentAt", () {
      expect(MessageModel.fromJson(_msgJson).sentAt,
          DateTime.parse('2026-04-10T10:00:00.000'));
    });

    test('receiverId defaults to empty string (not returned by API)', () {
      expect(MessageModel.fromJson(_msgJson).receiverId, '');
    });

    test('isRead defaults to false when absent', () {
      final j = Map<String, dynamic>.from(_msgJson)..remove('isRead');
      expect(MessageModel.fromJson(j).isRead, false);
    });

    test('parses isRead true', () {
      final j = Map<String, dynamic>.from(_msgJson)..['isRead'] = true;
      expect(MessageModel.fromJson(j).isRead, true);
    });
  });

  group('MessageModel.fromMap', () {
    test('parses snake_case DB map fields', () {
      final m = MessageModel.fromMap(_msgMap);
      expect(m.id, 'msg-2');
      expect(m.senderId, 'usr-2');
      expect(m.receiverId, 'usr-1');
      expect(m.conversationId, 'conv-1');
      expect(m.messageBody, 'Hi back!');
      expect(m.isRead, true);
      expect(m.sentAt, DateTime.parse('2026-04-10T10:01:00.000'));
    });

    test('isRead defaults to false when absent', () {
      final m = Map<String, dynamic>.from(_msgMap)..remove('is_read');
      expect(MessageModel.fromMap(m).isRead, false);
    });
  });

  group('MessageModel.toMap', () {
    test('encodes back with snake_case keys', () {
      final m = MessageModel.fromMap(_msgMap);
      final map = m.toMap();
      expect(map['id'], 'msg-2');
      expect(map['sender_id'], 'usr-2');
      expect(map['receiver_id'], 'usr-1');
      expect(map['conversation_id'], 'conv-1');
      expect(map['message_body'], 'Hi back!');
      expect(map['is_read'], true);
    });
  });

  group('MessageModel.isSentBy', () {
    test('returns true when senderId matches', () {
      final m = MessageModel.fromJson(_msgJson);
      expect(m.isSentBy('usr-1'), true);
    });

    test('returns false when senderId does not match', () {
      final m = MessageModel.fromJson(_msgJson);
      expect(m.isSentBy('usr-2'), false);
    });
  });

  group('ConversationModel.fromJson', () {
    test('parses all top-level fields', () {
      final c = ConversationModel.fromJson(_convJson);
      expect(c.id, 'conv-1');
      expect(c.lastMessage, 'See you tomorrow');
      expect(c.unreadCount, 3);
      expect(c.lastMessageAt, DateTime.parse('2026-04-10T09:00:00.000'));
    });

    test('extracts nested otherUser fields', () {
      final c = ConversationModel.fromJson(_convJson);
      expect(c.participantId, 'usr-2');
      expect(c.participantName, 'Bob Jones');
      expect(c.participantRole, 'interpreter');
      expect(c.participantPhoto, 'https://example.com/bob.jpg');
    });

    test('participantPhoto is null when avatarUrl absent', () {
      final j = <String, dynamic>{
        ...(_convJson),
        'otherUser': {
          'id': 'usr-3',
          'name': 'No Photo',
          'role': 'student',
          // no avatarUrl
        },
      };
      expect(ConversationModel.fromJson(j).participantPhoto, isNull);
    });

    test('lastMessage defaults to empty string when absent', () {
      final j = Map<String, dynamic>.from(_convJson)..remove('lastMessage');
      expect(ConversationModel.fromJson(j).lastMessage, '');
    });

    test('unreadCount defaults to 0 when absent', () {
      final j = Map<String, dynamic>.from(_convJson)..remove('unreadCount');
      expect(ConversationModel.fromJson(j).unreadCount, 0);
    });
  });
}
