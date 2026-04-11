import 'package:intl/intl.dart';

class AppHelpers {
  /// Format a DateTime to "May 25, 2025"
  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  /// Format a DateTime to "9:00 AM"
  static String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

  /// Format a DateTime to "May 25 • 9:00 AM"
  static String formatDateTime(DateTime dt) =>
      '${DateFormat('MMM d').format(dt)} • ${DateFormat('h:mm a').format(dt)}';

  /// Returns "Today", "Tomorrow", or the formatted date
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return formatDate(dt);
  }

  /// Capitalise first letter
  static String capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Truncate to maxLen with ellipsis
  static String truncate(String s, int maxLen) =>
      s.length <= maxLen ? s : '${s.substring(0, maxLen)}…';

  /// Get initials from a full name (e.g. "Alex Johnson" → "AJ")
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// Backward-compat alias so legacy code using `Helpers.xxx` still compiles.
typedef Helpers = AppHelpers;
