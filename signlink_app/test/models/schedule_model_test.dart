import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/schedule_model.dart';

void main() {
  // A typical API "request" JSON that ScheduleModel.fromJson consumes.
  const _json = <String, dynamic>{
    'id': 'req-1',
    'studentId': 'stu-1',
    'interpreterId': 'int-1',
    'eventTitle': 'Math Class',
    'requestType': 'class',
    'location': 'Room 101',
    'eventDate': '2026-05-10',
    'eventTime': '09:00:00',
    'status': 'approved',
    'student': {'name': 'Alice Smith'},
    'interpreter': {'name': 'Bob Jones'},
    'isRated': false,
  };

  // A local map (fromMap) fixture.
  const _map = <String, dynamic>{
    'id': 'sched-1',
    'student_id': 'stu-2',
    'interpreter_id': 'int-2',
    'course_name': 'Physics',
    'course_code': 'PHY101',
    'location': 'Lab 1',
    'schedule_date': '2026-06-01T00:00:00.000',
    'start_time': '2026-06-01T08:00:00.000',
    'end_time': '2026-06-01T09:00:00.000',
    'status': 'pending',
    'interpreter_name': 'Jane Doe',
    'is_rated': 0,
  };

  group('ScheduleModel.fromJson', () {
    test('parses required fields', () {
      final s = ScheduleModel.fromJson(_json);
      expect(s.id, 'req-1');
      expect(s.studentId, 'stu-1');
      expect(s.interpreterId, 'int-1');
      expect(s.courseName, 'Math Class');
      expect(s.courseCode, 'class');
      expect(s.location, 'Room 101');
      expect(s.status, 'approved');
      expect(s.isRated, false);
    });

    test('parses nested student name', () {
      expect(ScheduleModel.fromJson(_json).studentName, 'Alice Smith');
    });

    test('parses nested interpreter name', () {
      expect(ScheduleModel.fromJson(_json).interpreterName, 'Bob Jones');
    });

    test('studentName is null when student object absent', () {
      final j = Map<String, dynamic>.from(_json)..remove('student');
      expect(ScheduleModel.fromJson(j).studentName, isNull);
    });

    test('interpreterName is null when interpreter object absent', () {
      final j = Map<String, dynamic>.from(_json)..remove('interpreter');
      expect(ScheduleModel.fromJson(j).interpreterName, isNull);
    });

    test('combines eventDate + eventTime into startTime', () {
      final s = ScheduleModel.fromJson(_json);
      expect(s.startTime.year, 2026);
      expect(s.startTime.month, 5);
      expect(s.startTime.day, 10);
      expect(s.startTime.hour, 9);
      expect(s.startTime.minute, 0);
    });

    test('endTime is startTime + 1 hour', () {
      final s = ScheduleModel.fromJson(_json);
      expect(s.endTime.difference(s.startTime).inHours, 1);
    });

    test('interpreterId is null when absent', () {
      final j = Map<String, dynamic>.from(_json)..remove('interpreterId');
      expect(ScheduleModel.fromJson(j).interpreterId, isNull);
    });
  });

  group('ScheduleModel.fromMap', () {
    test('parses snake_case fields', () {
      final s = ScheduleModel.fromMap(_map);
      expect(s.id, 'sched-1');
      expect(s.studentId, 'stu-2');
      expect(s.interpreterId, 'int-2');
      expect(s.courseName, 'Physics');
      expect(s.courseCode, 'PHY101');
      expect(s.location, 'Lab 1');
      expect(s.status, 'pending');
      expect(s.interpreterName, 'Jane Doe');
      expect(s.isRated, false); // is_rated: 0 → false
    });

    test('is_rated: 1 maps to isRated true', () {
      final m = Map<String, dynamic>.from(_map)..['is_rated'] = 1;
      expect(ScheduleModel.fromMap(m).isRated, true);
    });
  });

  group('ScheduleModel.copyWith', () {
    test('changes status only', () {
      final s = ScheduleModel.fromMap(_map);
      final updated = s.copyWith(status: 'completed');
      expect(updated.status, 'completed');
      expect(updated.id, s.id); // other fields unchanged
      expect(updated.courseName, s.courseName);
    });

    test('changes isRated only', () {
      final s = ScheduleModel.fromMap(_map);
      final updated = s.copyWith(isRated: true);
      expect(updated.isRated, true);
      expect(updated.status, s.status); // status unchanged
    });
  });

  group('ScheduleModel.hasInterpreter', () {
    test('true when interpreterId is set', () {
      expect(ScheduleModel.fromJson(_json).hasInterpreter, true);
    });

    test('false when interpreterId is null', () {
      final j = Map<String, dynamic>.from(_json)..remove('interpreterId');
      expect(ScheduleModel.fromJson(j).hasInterpreter, false);
    });
  });

  group('ScheduleModel.canRate', () {
    test('true when completed, has interpreter, not rated', () {
      final s = ScheduleModel.fromJson(
        {..._json, 'status': 'completed', 'isRated': false},
      );
      expect(s.canRate, true);
    });

    test('false when not completed', () {
      // Default json has status='approved'
      expect(ScheduleModel.fromJson(_json).canRate, false);
    });

    test('false when already rated', () {
      final s = ScheduleModel.fromJson(
        {..._json, 'status': 'completed', 'isRated': true},
      );
      expect(s.canRate, false);
    });

    test('false when no interpreter', () {
      final s = ScheduleModel.fromJson(
        {..._json, 'status': 'completed', 'isRated': false, 'interpreterId': null},
      );
      expect(s.canRate, false);
    });
  });

  group('ScheduleModel.isToday', () {
    test('false for a past date', () {
      final j = Map<String, dynamic>.from(_json)..['eventDate'] = '2020-01-01';
      expect(ScheduleModel.fromJson(j).isToday, false);
    });

    test('false for a distant future date', () {
      final j = Map<String, dynamic>.from(_json)..['eventDate'] = '2099-12-31';
      expect(ScheduleModel.fromJson(j).isToday, false);
    });

    test('true for today\'s date', () {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final j = Map<String, dynamic>.from(_json)..['eventDate'] = dateStr;
      expect(ScheduleModel.fromJson(j).isToday, true);
    });
  });
}
