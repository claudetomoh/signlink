import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// NotificationService — local push notification scheduling.
///
/// Device resources used:
///  • System notification tray
///  • Device alarm / inexact timer for session reminders
///  • Device vibrator
///
/// Android permissions required (declared in AndroidManifest.xml):
///  • POST_NOTIFICATIONS  (Android 13+)
///  • VIBRATE
///  • RECEIVE_BOOT_COMPLETED (survive reboots)
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Notification channels (Android 8+) ───────────────────────────────────
  static const _idReminders = 'signlink_reminders';
  static const _idGeneral = 'signlink_general';

  // ── Initialise ────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    // Set up timezone database (required for zonedSchedule)
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android notification channels
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _idReminders,
        'Session Reminders',
        description: 'Reminders 15 minutes before interpretation sessions',
        importance: Importance.high,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _idGeneral,
        'General Notifications',
        description: 'General SignLink app notifications',
        importance: Importance.defaultImportance,
      ),
    );

    _initialized = true;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Request notification permission on Android 13+ (runtime prompt).
  /// Returns true if granted, false otherwise.
  static Future<bool> requestPermissions() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImpl?.requestNotificationsPermission() ?? false;
  }

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Schedules a reminder 15 minutes before [sessionTime].
  /// Silently skips if the reminder time is already in the past.
  static Future<void> scheduleSessionReminder({
    required int id,
    required String sessionTitle,
    required DateTime sessionTime,
    String location = '',
  }) async {
    if (!_initialized) await initialize();

    final reminderTime = sessionTime.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    final body = location.isNotEmpty
        ? 'Starting in 15 minutes at $location'
        : 'Starting in 15 minutes';

    await _plugin.zonedSchedule(
      id,
      'SignLink: $sessionTitle',
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _idReminders,
          'Session Reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // inexact = no USE_EXACT_ALARM permission needed
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Immediate notification ────────────────────────────────────────────────

  /// Show an immediate notification in the system tray.
  static Future<void> showNow({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _idGeneral,
          'General Notifications',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ── Cancellation ─────────────────────────────────────────────────────────

  /// Cancel a previously scheduled reminder by its [id].
  static Future<void> cancelReminder(int id) => _plugin.cancel(id);
}
