import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';
import '../services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  List<RequestModel> _requests = [];
  bool _isLoading = false;
  String? _error;

  final _api = ApiService.instance;

  List<ScheduleModel> get schedules => List.unmodifiable(_schedules);
  List<ScheduleModel> get studentSchedules => List.unmodifiable(_schedules);
  List<ScheduleModel> get interpreterSchedules => List.unmodifiable(_schedules);
  List<RequestModel> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ScheduleModel> get todaySchedules {
    final today = DateTime.now();
    return _schedules.where((s) {
      return s.scheduleDate.year == today.year &&
          s.scheduleDate.month == today.month &&
          s.scheduleDate.day == today.day;
    }).toList();
  }

  List<ScheduleModel> get upcomingSchedules {
    final today = DateTime.now();
    return _schedules.where((s) => s.scheduleDate.isAfter(today)).toList()
      ..sort((a, b) => a.scheduleDate.compareTo(b.scheduleDate));
  }

  final _service = ScheduleService();

  Future<void> loadStudentSchedule(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _schedules = await _service.getStudentSchedule(studentId);
    } catch (e) {
      _error = 'Failed to load schedule.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.get('/requests/list.php');
      final list = data['requests'] as List<dynamic>;
      _requests = list
          .map((r) => RequestModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to load requests.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadInterpreterSchedule(String interpreterId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _schedules = await _service.getInterpreterSchedule(interpreterId);
    } catch (e) {
      _error = 'Failed to load schedule.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitRequest({
    required String studentId,
    required String courseName,
    required String location,
    required DateTime date,
    required DateTime time,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await _service.submitInterpreterRequest(
      studentId: studentId,
      courseName: courseName,
      location: location,
      date: date,
      time: time,
      notes: notes,
    );
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> updateStatus(String scheduleId, String status) async {
    final result = await _service.updateAssignmentStatus(scheduleId, status);
    if (result) {
      final idx = _schedules.indexWhere((s) => s.id == scheduleId);
      if (idx != -1) {
        // Update local state optimistically
        notifyListeners();
      }
    }
    return result;
  }

  /// Updates the status of a [RequestModel] in the local list and notifies listeners.
  Future<bool> updateRequestStatus(String id, String status, {String? interpreterId}) async {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx == -1) return false;
    try {
      await _service.updateAssignmentStatus(id, status, interpreterId: interpreterId);
    } catch (_) {
      return false;
    }
    _requests = List.from(_requests)..[idx] = _requests[idx].copyWith(status: status);
    notifyListeners();
    return true;
  }

  /// Submit a 1–5 rating for an interpreter after a completed assignment.
  Future<bool> rateInterpreter(String requestId, String interpreterId, double rating) async {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    try {
      await _api.post('/users/rate.php', {
        'interpreter_id': interpreterId,
        'rating': rating,
        'request_id': requestId,
      });
    } on ApiException {
      return false;
    }
    if (idx != -1) {
      _requests = List.from(_requests)..[idx] = _requests[idx].copyWith(isRated: true);
      notifyListeners();
    }
    return true;
  }

  /// Submit a 1–5 rating via a ScheduleModel entry (student timetable screen).
  Future<bool> rateSchedule(String scheduleId, String interpreterId, int rating) async {
    final idx = _schedules.indexWhere((s) => s.id == scheduleId);
    try {
      await _api.post('/users/rate.php', {
        'interpreter_id': interpreterId,
        'rating': rating,
        'request_id': scheduleId,
      });
    } on ApiException {
      return false;
    }
    if (idx != -1) {
      _schedules = List.from(_schedules)..[idx] = _schedules[idx].copyWith(isRated: true);
      notifyListeners();
    }
    return true;
  }
}
