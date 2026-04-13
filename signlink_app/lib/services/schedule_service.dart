import '../models/schedule_model.dart';
import 'api_service.dart';

/// ScheduleService — backed by the real REST API.
/// Schedule data is derived from interpreter_requests (approved/completed).
class ScheduleService {
  final _api = ApiService.instance;

  // GET /api/requests/list.php  (student view)
  Future<List<ScheduleModel>> getStudentSchedule(String studentId) async {
    final data = await _api.get('/requests/list.php');
    final list = data['requests'] as List<dynamic>;
    return list
        .map((r) => ScheduleModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // GET /api/requests/list.php  (interpreter view)
  Future<List<ScheduleModel>> getInterpreterSchedule(String interpreterId) async {
    final data = await _api.get('/requests/list.php');
    final list = data['requests'] as List<dynamic>;
    return list
        .map((r) => ScheduleModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // PUT /api/requests/update.php?id=<id>
  Future<bool> updateAssignmentStatus(String scheduleId, String status, {String? interpreterId}) async {
    await _api.put(
      '/requests/update.php',
      {'status': status, if (interpreterId != null) 'interpreterId': interpreterId},
      params: {'id': scheduleId},
    );
    return true;
  }

  // POST /api/requests/create.php
  Future<bool> submitInterpreterRequest({
    required String studentId,
    required String courseName,
    required String location,
    required DateTime date,
    required DateTime time,
    String requestType = 'class',
    String? notes,
  }) async {
    await _api.post('/requests/create.php', {
      'event_title': courseName,
      'request_type': requestType,
      'location': location,
      'event_date': date.toIso8601String().split('T').first,
      'event_time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      if (notes != null) 'notes': notes,
    });
    return true;
  }
}
