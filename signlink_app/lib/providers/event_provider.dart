import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;
  final Set<String> _signedUpEventIds = {};

  List<EventModel> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EventModel> get upcomingEvents =>
      _events.where((e) => !e.isPast).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<EventModel> get pastEvents =>
      _events.where((e) => e.isPast).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  bool isSignedUp(String eventId) => _signedUpEventIds.contains(eventId);

  final _service = EventService();

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await _service.getEvents();
    } catch (e) {
      _error = 'Failed to load events.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp(String eventId) async {
    final result = await _service.signUpForEvent(eventId);
    if (result) {
      _signedUpEventIds.add(eventId);
      notifyListeners();
    }
    return result;
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    int? capacity,
    required String createdBy,
  }) async {
    _isLoading = true;
    notifyListeners();
    final result = await _service.createEvent(
      title: title,
      description: description,
      date: date,
      location: location,
      capacity: capacity,
      createdBy: createdBy,
    );
    if (result) await loadEvents();
    _isLoading = false;
    notifyListeners();
    return result;
  }
}
