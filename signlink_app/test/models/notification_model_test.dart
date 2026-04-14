import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/notification_model.dart';

void main() {
  const _apiJson = <String, dynamic>{
    'id': 'notif-1',
    'userId': 'usr-1',
    'title': 'Request Approved',
    'body': 'Your request has been approved.',
    'type': 'request',
    'isRead': false,
    'createdAt': '2026-04-10T12:00:00.000',
  };

  const _dbMap = <String, dynamic>{
    'id': 'notif-2',
    'user_id': 'usr-2',
    'title': 'New Message',
    'content': 'You have a new message.',
    'type': 'message',
    'is_read': false,
    'created_at': '2026-04-11T08:30:00.000',
  };

  group('NotificationModel.fromJson', () {
    test('parses all fields from API JSON', () {
      final n = NotificationModel.fromJson(_apiJson);
      expect(n.id, 'notif-1');
      expect(n.userId, 'usr-1');
      expect(n.title, 'Request Approved');
      expect(n.content, 'Your request has been approved.');
      expect(n.type, 'request');
      expect(n.isRead, false);
      expect(n.createdAt, DateTime.parse('2026-04-10T12:00:00.000'));
    });

    test("maps API field 'body' to model field 'content'", () {
      final n = NotificationModel.fromJson(_apiJson);
      // Verify the body is in content, not a separate field
      expect(n.content, 'Your request has been approved.');
    });

    test('defaults isRead to false when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('isRead');
      expect(NotificationModel.fromJson(j).isRead, false);
    });

    test('parses all supported notification types', () {
      for (final type in ['request', 'schedule', 'event', 'message', 'system']) {
        final j = Map<String, dynamic>.from(_apiJson)..['type'] = type;
        expect(NotificationModel.fromJson(j).type, type);
      }
    });

    test('parses isRead true correctly', () {
      final j = Map<String, dynamic>.from(_apiJson)..['isRead'] = true;
      expect(NotificationModel.fromJson(j).isRead, true);
    });
  });

  group('NotificationModel.fromMap', () {
    test('parses snake_case DB map fields', () {
      final n = NotificationModel.fromMap(_dbMap);
      expect(n.id, 'notif-2');
      expect(n.userId, 'usr-2');
      expect(n.title, 'New Message');
      expect(n.content, 'You have a new message.');
      expect(n.type, 'message');
      expect(n.isRead, false);
      expect(n.createdAt, DateTime.parse('2026-04-11T08:30:00.000'));
    });

    test('isRead defaults to false when absent from map', () {
      final m = Map<String, dynamic>.from(_dbMap)..remove('is_read');
      expect(NotificationModel.fromMap(m).isRead, false);
    });
  });

  group('NotificationModel.toMap', () {
    test('encodes back with snake_case keys', () {
      final n = NotificationModel.fromMap(_dbMap);
      final m = n.toMap();
      expect(m['id'], 'notif-2');
      expect(m['user_id'], 'usr-2');
      expect(m['title'], 'New Message');
      expect(m['content'], 'You have a new message.');
      expect(m['type'], 'message');
      expect(m['is_read'], false);
    });
  });
}
