import 'package:flutter_test/flutter_test.dart';
import 'package:signlink_app/models/event_model.dart';
import 'package:signlink_app/providers/event_provider.dart';
import 'package:signlink_app/services/event_service.dart';
import 'package:signlink_app/services/api_service.dart';

// ── Fake service implementations ────────────────────────────────────────────

class _FakeEventService implements EventService {
  List<EventModel> _events;
  Exception? _error;
  bool _signUpResult;

  _FakeEventService({
    List<EventModel>? events,
    Exception? error,
    bool signUpResult = true,
  })  : _events = events ?? [],
        _error = error,
        _signUpResult = signUpResult;

  @override
  Future<List<EventModel>> getEvents({String? search, String tab = 'all'}) async {
    if (_error != null) throw _error!;
    return _events;
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    return _events.where((e) => e.id == id).isEmpty
        ? null
        : _events.firstWhere((e) => e.id == id);
  }

  @override
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    int? capacity,
    required String createdBy,
  }) async {
    if (_error != null) throw _error!;
    return true;
  }

  @override
  Future<bool> signUpForEvent(String eventId) async {
    if (_error != null) throw _error!;
    return _signUpResult;
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

EventModel _makeEvent({
  String id = 'e1',
  bool isPast = false,
  bool isSignedUp = false,
  DateTime? date,
}) =>
    EventModel(
      id: id,
      title: 'Event $id',
      description: '',
      date: date ?? DateTime(2026, 12, 1),
      location: 'Hall A',
      createdBy: 'admin',
      isPast: isPast,
      isSignedUp: isSignedUp,
    );

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('EventProvider — initial state', () {
    test('starts with empty events and no loading or error', () {
      final provider = EventProvider(service: _FakeEventService());
      expect(provider.events, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('isSignedUp returns false for any event before load', () {
      final provider = EventProvider(service: _FakeEventService());
      expect(provider.isSignedUp('any-id'), false);
    });
  });

  group('EventProvider.loadEvents', () {
    test('sets isLoading then clears it, populates events on success', () async {
      final events = [_makeEvent(id: 'e1'), _makeEvent(id: 'e2')];
      final provider = EventProvider(service: _FakeEventService(events: events));

      final loadFuture = provider.loadEvents();
      expect(provider.isLoading, true);

      await loadFuture;
      expect(provider.isLoading, false);
      expect(provider.events.length, 2);
      expect(provider.error, isNull);
    });

    test('rebuilds signedUpEventIds from events returned by service', () async {
      final events = [
        _makeEvent(id: 'signed', isSignedUp: true),
        _makeEvent(id: 'not-signed', isSignedUp: false),
      ];
      final provider = EventProvider(service: _FakeEventService(events: events));

      await provider.loadEvents();

      expect(provider.isSignedUp('signed'), true);
      expect(provider.isSignedUp('not-signed'), false);
    });

    test('sets error and clears events on failure', () async {
      final provider = EventProvider(
        service: _FakeEventService(error: ApiException('Network error', 500)),
      );
      await provider.loadEvents();

      expect(provider.error, isNotNull);
      expect(provider.isLoading, false);
    });

    test('clears previous error on successful reload', () async {
      final errService = _FakeEventService(error: ApiException('fail', 500));
      final provider = EventProvider(service: errService);
      await provider.loadEvents();
      expect(provider.error, isNotNull);

      // Fix the service
      final okService = _FakeEventService(events: [_makeEvent()]);
      final providerOk = EventProvider(service: okService);
      await providerOk.loadEvents();
      expect(providerOk.error, isNull);
    });
  });

  group('EventProvider.signUp', () {
    test('adds eventId to signed-up set when service returns true', () async {
      final provider = EventProvider(
        service: _FakeEventService(signUpResult: true),
      );
      final result = await provider.signUp('evt-1');
      expect(result, true);
      expect(provider.isSignedUp('evt-1'), true);
    });

    test('removes eventId from signed-up set when service returns false', () async {
      // Pre-populate as signed up via loadEvents
      final events = [_makeEvent(id: 'evt-1', isSignedUp: true)];
      final provider = EventProvider(
        service: _FakeEventService(events: events, signUpResult: false),
      );
      await provider.loadEvents();
      expect(provider.isSignedUp('evt-1'), true);

      final result = await provider.signUp('evt-1');
      expect(result, false);
      expect(provider.isSignedUp('evt-1'), false);
    });

    test('sets error and returns false on ApiException', () async {
      final provider = EventProvider(
        service: _FakeEventService(error: ApiException('Sign-up failed', 500)),
      );
      final result = await provider.signUp('evt-1');

      expect(result, false);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('sign-up'));
    });
  });

  group('EventProvider — computed lists', () {
    test('upcomingEvents filters out past events', () async {
      final events = [
        _makeEvent(id: 'past', isPast: true, date: DateTime(2025, 1, 1)),
        _makeEvent(id: 'future', isPast: false, date: DateTime(2027, 1, 1)),
      ];
      final provider = EventProvider(service: _FakeEventService(events: events));
      await provider.loadEvents();

      expect(provider.upcomingEvents.length, 1);
      expect(provider.upcomingEvents.first.id, 'future');
    });

    test('pastEvents filters out upcoming events', () async {
      final events = [
        _makeEvent(id: 'old', isPast: true, date: DateTime(2024, 1, 1)),
        _makeEvent(id: 'new', isPast: false, date: DateTime(2027, 1, 1)),
      ];
      final provider = EventProvider(service: _FakeEventService(events: events));
      await provider.loadEvents();

      expect(provider.pastEvents.length, 1);
      expect(provider.pastEvents.first.id, 'old');
    });

    test('upcomingEvents is sorted by date ascending', () async {
      final events = [
        _makeEvent(id: 'late', date: DateTime(2027, 6, 1)),
        _makeEvent(id: 'early', date: DateTime(2027, 1, 1)),
      ];
      final provider = EventProvider(service: _FakeEventService(events: events));
      await provider.loadEvents();

      final upcoming = provider.upcomingEvents;
      expect(upcoming.first.id, 'early');
      expect(upcoming.last.id, 'late');
    });
  });
}
