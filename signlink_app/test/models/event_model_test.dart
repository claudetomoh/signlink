import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/event_model.dart';

void main() {
  const _baseJson = <String, dynamic>{
    'id': 'evt-1',
    'title': 'Tech Talk',
    'description': 'A great tech talk',
    'date': '2026-06-15T09:00:00.000',
    'location': 'Hall A',
    'imageUrl': 'https://example.com/img.jpg',
    'capacity': 100,
    'signedUpCount': 40,
    'createdBy': 'admin-1',
    'isPast': false,
    'isSignedUp': true,
  };

  group('EventModel.fromJson', () {
    test('parses all required and optional fields', () {
      final e = EventModel.fromJson(_baseJson);
      expect(e.id, 'evt-1');
      expect(e.title, 'Tech Talk');
      expect(e.description, 'A great tech talk');
      expect(e.location, 'Hall A');
      expect(e.capacity, 100);
      expect(e.signedUpCount, 40);
      expect(e.createdBy, 'admin-1');
      expect(e.imageUrl, 'https://example.com/img.jpg');
      expect(e.isPast, false);
      expect(e.isSignedUp, true);
      expect(e.date, DateTime.parse('2026-06-15T09:00:00.000'));
    });

    test('defaults isPast and isSignedUp to false when absent', () {
      final j = Map<String, dynamic>.from(_baseJson)
        ..remove('isPast')
        ..remove('isSignedUp');
      final e = EventModel.fromJson(j);
      expect(e.isPast, false);
      expect(e.isSignedUp, false);
    });

    test('imageUrl is null when absent', () {
      final j = Map<String, dynamic>.from(_baseJson)..remove('imageUrl');
      expect(EventModel.fromJson(j).imageUrl, isNull);
    });

    test('capacity and signedUpCount are null when absent', () {
      final j = Map<String, dynamic>.from(_baseJson)
        ..remove('capacity')
        ..remove('signedUpCount');
      final e = EventModel.fromJson(j);
      expect(e.capacity, isNull);
      expect(e.signedUpCount, isNull);
    });

    test('description defaults to empty string when absent', () {
      final j = Map<String, dynamic>.from(_baseJson)..remove('description');
      expect(EventModel.fromJson(j).description, '');
    });

    test('createdBy defaults to empty string when absent', () {
      final j = Map<String, dynamic>.from(_baseJson)..remove('createdBy');
      expect(EventModel.fromJson(j).createdBy, '');
    });
  });

  group('EventModel.fromMap', () {
    test('parses snake_case map fields', () {
      final map = <String, dynamic>{
        'id': 'evt-2',
        'title': 'Workshop',
        'description': 'Hands-on',
        'date': '2026-07-01T10:00:00.000',
        'location': 'Lab 2',
        'capacity': 30,
        'signed_up_count': 10,
        'created_by': 'admin-2',
        'is_past': false,
      };
      final e = EventModel.fromMap(map);
      expect(e.id, 'evt-2');
      expect(e.title, 'Workshop');
      expect(e.capacity, 30);
      expect(e.signedUpCount, 10);
      expect(e.createdBy, 'admin-2');
      expect(e.isPast, false);
    });

    test('defaults isPast to false when absent', () {
      final map = <String, dynamic>{
        'id': 'e3',
        'title': 'T',
        'description': '',
        'date': '2026-01-01T00:00:00.000',
        'location': 'L',
        'created_by': 'a',
      };
      expect(EventModel.fromMap(map).isPast, false);
    });
  });

  group('EventModel.toMap', () {
    test('encodes back to map with expected keys', () {
      final e = EventModel.fromJson(_baseJson);
      final m = e.toMap();
      expect(m['id'], 'evt-1');
      expect(m['title'], 'Tech Talk');
      expect(m['location'], 'Hall A');
      expect(m['capacity'], 100);
      expect(m['signed_up_count'], 40);
      expect(m['created_by'], 'admin-1');
      expect(m['is_past'], false);
      expect(m['image_url'], 'https://example.com/img.jpg');
    });
  });

  group('EventModel.capacityPercent', () {
    EventModel _make({int? capacity, int? signedUpCount}) => EventModel(
          id: '1',
          title: 'T',
          description: '',
          date: DateTime.now(),
          location: 'L',
          createdBy: 'a',
          capacity: capacity,
          signedUpCount: signedUpCount,
        );

    test('returns 0.0 when capacity is null', () {
      expect(_make().capacityPercent, 0.0);
    });

    test('returns 0.0 when capacity is 0', () {
      expect(_make(capacity: 0).capacityPercent, 0.0);
    });

    test('returns 0.0 when signedUpCount is null', () {
      expect(_make(capacity: 100).capacityPercent, 0.0);
    });

    test('calculates correct fraction', () {
      expect(_make(capacity: 100, signedUpCount: 50).capacityPercent, 0.5);
    });

    test('calculates fraction for full capacity', () {
      expect(_make(capacity: 100, signedUpCount: 100).capacityPercent, 1.0);
    });

    test('clamps to 1.0 when over capacity', () {
      expect(_make(capacity: 10, signedUpCount: 15).capacityPercent, 1.0);
    });

    test('handles single slot capacity', () {
      expect(_make(capacity: 1, signedUpCount: 1).capacityPercent, 1.0);
    });
  });
}
