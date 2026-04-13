import '../models/event_model.dart';
import 'api_service.dart';

/// EventService — backed by the real REST API.
class EventService {
  final _api = ApiService.instance;

  // GET /api/events/list.php
  Future<List<EventModel>> getEvents({String? search, String tab = 'all'}) async {
    final params = <String, String>{'tab': tab};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final data = await _api.get('/events/list.php', params: params);
    final list = data['events'] as List<dynamic>;
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/events/list.php (filter by id client-side — no single-event endpoint)
  Future<EventModel?> getEventById(String id) async {
    final events = await getEvents();
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // POST /api/events/create.php
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    int? capacity,
    required String createdBy,
  }) async {
    await _api.post('/events/create.php', {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      if (capacity != null) 'capacity': capacity,
    });
    return true;
  }

  // POST /api/events/signup.php
  // Returns the new isSignedUp state (true = signed up, false = cancelled).
  Future<bool> signUpForEvent(String eventId) async {
    final data = await _api.post('/events/signup.php', {'event_id': eventId});
    return (data['isSignedUp'] as bool?) ?? true;
  }
}
