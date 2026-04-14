import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/schedule_model.dart';
import 'package:signlink_app/providers/schedule_provider.dart';
import 'package:signlink_app/services/schedule_service.dart';

// ── Fake service ─────────────────────────────────────────────────────────────

class _FakeScheduleService implements ScheduleService {
  List<ScheduleModel> _schedules;
  bool _updateResult;
  Exception? _error;

  _FakeScheduleService({
    List<ScheduleModel>? schedules,
    bool updateResult = true,
    Exception? error,
  })  : _schedules = schedules ?? [],
        _updateResult = updateResult,
        _error = error;

  @override
  Future<List<ScheduleModel>> getStudentSchedule(String studentId) async {
    if (_error != null) throw _error!;
    return _schedules;
  }

  @override
  Future<List<ScheduleModel>> getInterpreterSchedule(String interpreterId) async {
    if (_error != null) throw _error!;
    return _schedules;
  }

  @override
  Future<bool> updateAssignmentStatus(
    String scheduleId,
    String status, {
    String? interpreterId,
  }) async {
    if (_error != null) throw _error!;
    return _updateResult;
  }

  @override
  Future<bool> submitInterpreterRequest({
    required String studentId,
    required String courseName,
    required String location,
    required DateTime date,
    required DateTime time,
    String requestType = 'class',
    String? notes,
  }) async {
    if (_error != null) throw _error!;
    return true;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ScheduleModel _makeSched({
  String id = 's1',
  String status = 'approved',
  DateTime? scheduleDate,
  String? interpreterId = 'int-1',
  bool isRated = false,
}) =>
    ScheduleModel(
      id: id,
      studentId: 'stu-1',
      courseName: 'Math',
      courseCode: 'MTH101',
      location: 'Room 1',
      scheduleDate: scheduleDate ?? DateTime(2026, 12, 1),
      startTime: (scheduleDate ?? DateTime(2026, 12, 1)).add(const Duration(hours: 8)),
      endTime: (scheduleDate ?? DateTime(2026, 12, 1)).add(const Duration(hours: 9)),
      status: status,
      interpreterId: interpreterId,
      isRated: isRated,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ScheduleProvider — initial state', () {
    test('starts with empty lists, not loading, no error', () {
      final p = ScheduleProvider(service: _FakeScheduleService());
      expect(p.schedules, isEmpty);
      expect(p.isLoading, false);
      expect(p.error, isNull);
    });
  });

  group('ScheduleProvider.loadStudentSchedule', () {
    test('populates schedules on success', () async {
      final schedules = [_makeSched(id: 's1'), _makeSched(id: 's2')];
      final p = ScheduleProvider(service: _FakeScheduleService(schedules: schedules));

      await p.loadStudentSchedule('stu-1');

      expect(p.schedules.length, 2);
      expect(p.error, isNull);
      expect(p.isLoading, false);
    });

    test('sets error on failure', () async {
      final p = ScheduleProvider(
        service: _FakeScheduleService(error: Exception('network error')),
      );
      await p.loadStudentSchedule('stu-1');

      expect(p.error, isNotNull);
      expect(p.isLoading, false);
      expect(p.schedules, isEmpty);
    });
  });

  group('ScheduleProvider.loadInterpreterSchedule', () {
    test('populates schedules on success', () async {
      final schedules = [_makeSched(id: 'i1')];
      final p = ScheduleProvider(service: _FakeScheduleService(schedules: schedules));

      await p.loadInterpreterSchedule('int-1');

      expect(p.schedules.length, 1);
      expect(p.error, isNull);
    });

    test('sets error on failure', () async {
      final p = ScheduleProvider(
        service: _FakeScheduleService(error: Exception('server down')),
      );
      await p.loadInterpreterSchedule('int-1');
      expect(p.error, isNotNull);
    });
  });

  group('ScheduleProvider.updateStatus', () {
    test('updates status in local list when service succeeds', () async {
      final schedules = [_makeSched(id: 's1', status: 'pending')];
      final p = ScheduleProvider(service: _FakeScheduleService(schedules: schedules));
      await p.loadStudentSchedule('stu-1');

      final result = await p.updateStatus('s1', 'approved');

      expect(result, true);
      expect(p.schedules.first.status, 'approved');
    });

    test('does not update list when service returns false', () async {
      final schedules = [_makeSched(id: 's1', status: 'pending')];
      final p = ScheduleProvider(
        service: _FakeScheduleService(schedules: schedules, updateResult: false),
      );
      await p.loadStudentSchedule('stu-1');

      final result = await p.updateStatus('s1', 'approved');

      expect(result, false);
      expect(p.schedules.first.status, 'pending'); // unchanged
    });
  });

  group('ScheduleProvider — computed properties', () {
    test('todaySchedules returns only schedules for today', () async {
      final today = DateTime.now();
      final schedules = [
        _makeSched(id: 'today', scheduleDate: DateTime(today.year, today.month, today.day)),
        _makeSched(id: 'tomorrow', scheduleDate: today.add(const Duration(days: 1))),
        _makeSched(id: 'yesterday', scheduleDate: today.subtract(const Duration(days: 1))),
      ];
      final p = ScheduleProvider(service: _FakeScheduleService(schedules: schedules));
      await p.loadStudentSchedule('stu-1');

      expect(p.todaySchedules.length, 1);
      expect(p.todaySchedules.first.id, 'today');
    });

    test('upcomingSchedules returns future schedules sorted ascending', () async {
      final now = DateTime.now();
      final schedules = [
        _makeSched(id: 'far', scheduleDate: now.add(const Duration(days: 10))),
        _makeSched(id: 'near', scheduleDate: now.add(const Duration(days: 2))),
        _makeSched(id: 'past', scheduleDate: now.subtract(const Duration(days: 1))),
      ];
      final p = ScheduleProvider(service: _FakeScheduleService(schedules: schedules));
      await p.loadStudentSchedule('stu-1');

      final upcoming = p.upcomingSchedules;
      expect(upcoming.length, 2);
      expect(upcoming.first.id, 'near');
      expect(upcoming.last.id, 'far');
    });

    test('todaySchedules is empty when no schedules loaded', () {
      final p = ScheduleProvider(service: _FakeScheduleService());
      expect(p.todaySchedules, isEmpty);
    });
  });
}
