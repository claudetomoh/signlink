import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

/// NotificationProvider — polls the REST API every 30 s for in-app notifications.
///
/// Usage (register in MultiProvider then call [startPolling] after login):
///   context.read<NotificationProvider>().startPolling();
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;

  static const _pollInterval = Duration(seconds: 30);

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  final _api = ApiService.instance;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Start polling. Safe to call multiple times (idempotent).
  void startPolling() {
    if (_timer != null) return;
    fetch(); // immediate first fetch
    _timer = Timer.periodic(_pollInterval, (_) => fetch());
  }

  /// Stop polling (call on logout or dispose).
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetch() async {
    if (!_api.isAuthenticated) return;
    _isLoading = true;
    _error = null;
    // Don't notify here to avoid rebuilds during background polls
    try {
      final data = await _api.get('/notifications/list.php');
      final list = data['notifications'] as List<dynamic>;
      _notifications = list
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
      _unreadCount = (data['unreadCount'] as int?) ?? 0;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      // Swallow network errors silently during background polling
    }
  }

  // ── Mark as read ─────────────────────────────────────────────────────────

  Future<void> markRead(String notificationId) async {
    try {
      await _api.post('/notifications/mark_read.php', {'id': notificationId});
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            content: n.content,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } on ApiException {
      // Silently ignore — will correct on next poll
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.post('/notifications/mark_read.php', {'all': true});
      _notifications = _notifications.map((n) => NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            content: n.content,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          )).toList();
      _unreadCount = 0;
      notifyListeners();
    } on ApiException {
      // Silently ignore — will correct on next poll
    }
  }

  /// Clear local state on logout.
  void clear() {
    stopPolling();
    _notifications = [];
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }
}
