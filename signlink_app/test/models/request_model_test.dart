import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/request_model.dart';

void main() {
  const _apiJson = <String, dynamic>{
    'id': 'req-1',
    'studentId': 'stu-1',
    'student': {'name': 'Alice Smith'},
    'requestType': 'class',
    'eventTitle': 'Math 101',
    'location': 'Room 5',
    'eventDate': '2026-06-10',
    'eventTime': '10:00:00',
    'status': 'pending',
    'interpreterId': null,
    'notes': 'Please bring white board',
    'isRated': false,
  };

  const _dbMap = <String, dynamic>{
    'id': 'req-2',
    'student_id': 'stu-2',
    'student_name': 'Bob Jones',
    'request_type': 'event',
    'event_title': 'Science Fair',
    'location': 'Hall B',
    'request_date': '2026-07-01T00:00:00.000',
    'request_time': '1970-01-01T14:00:00.000',
    'status': 'approved',
    'assigned_interpreter_id': 'int-1',
    'notes': null,
  };

  group('RequestModel.fromJson', () {
    test('parses all required fields', () {
      final r = RequestModel.fromJson(_apiJson);
      expect(r.id, 'req-1');
      expect(r.studentId, 'stu-1');
      expect(r.requestType, 'class');
      expect(r.eventTitle, 'Math 101');
      expect(r.location, 'Room 5');
      expect(r.status, 'pending');
      expect(r.isRated, false);
    });

    test('extracts studentName from nested student object', () {
      expect(RequestModel.fromJson(_apiJson).studentName, 'Alice Smith');
    });

    test('studentName defaults to empty string when student absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('student');
      expect(RequestModel.fromJson(j).studentName, '');
    });

    test('notes is preserved', () {
      expect(RequestModel.fromJson(_apiJson).notes, 'Please bring white board');
    });

    test('notes is null when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('notes');
      expect(RequestModel.fromJson(j).notes, isNull);
    });

    test('assignedInterpreterId is null when interpreterId absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('interpreterId');
      expect(RequestModel.fromJson(j).assignedInterpreterId, isNull);
    });

    test('parses eventTime into a DateTime on 1970-01-01', () {
      final r = RequestModel.fromJson(_apiJson);
      expect(r.requestTime.year, 1970);
      expect(r.requestTime.hour, 10);
      expect(r.requestTime.minute, 0);
    });

    test('isRated defaults to false when absent', () {
      final j = Map<String, dynamic>.from(_apiJson)..remove('isRated');
      expect(RequestModel.fromJson(j).isRated, false);
    });
  });

  group('RequestModel.fromMap', () {
    test('parses snake_case map fields', () {
      final r = RequestModel.fromMap(_dbMap);
      expect(r.id, 'req-2');
      expect(r.studentId, 'stu-2');
      expect(r.studentName, 'Bob Jones');
      expect(r.requestType, 'event');
      expect(r.eventTitle, 'Science Fair');
      expect(r.location, 'Hall B');
      expect(r.status, 'approved');
      expect(r.assignedInterpreterId, 'int-1');
      expect(r.notes, isNull);
    });
  });

  group('RequestModel computed properties', () {
    RequestModel _make(String status, {bool isRated = false, String? interpreterId}) =>
        RequestModel(
          id: '1',
          studentId: 's1',
          studentName: 'S',
          requestType: 'class',
          eventTitle: 'T',
          location: 'L',
          requestDate: DateTime(2026),
          requestTime: DateTime(2026),
          status: status,
          assignedInterpreterId: interpreterId,
          isRated: isRated,
        );

    test('isPending is true only for pending status', () {
      expect(_make('pending').isPending, true);
      expect(_make('approved').isPending, false);
      expect(_make('declined').isPending, false);
    });

    test('isApproved is true only for approved status', () {
      expect(_make('approved').isApproved, true);
      expect(_make('pending').isApproved, false);
    });

    test('isCompleted is true only for completed status', () {
      expect(_make('completed').isCompleted, true);
      expect(_make('approved').isCompleted, false);
    });

    test('canRate is true when completed, unrated, with interpreter', () {
      expect(
        _make('completed', isRated: false, interpreterId: 'int-1').canRate,
        true,
      );
    });

    test('canRate is false when not completed', () {
      expect(_make('approved', interpreterId: 'int-1').canRate, false);
    });

    test('canRate is false when already rated', () {
      expect(
        _make('completed', isRated: true, interpreterId: 'int-1').canRate,
        false,
      );
    });

    test('canRate is false when no interpreter assigned', () {
      expect(_make('completed').canRate, false);
    });
  });

  group('RequestModel.copyWith', () {
    test('changes status', () {
      final r = RequestModel.fromJson(_apiJson);
      final updated = r.copyWith(status: 'approved');
      expect(updated.status, 'approved');
      expect(updated.id, r.id); // unchanged
    });

    test('changes isRated', () {
      final r = RequestModel.fromJson(_apiJson);
      final updated = r.copyWith(isRated: true);
      expect(updated.isRated, true);
      expect(updated.status, r.status); // unchanged
    });
  });
}
