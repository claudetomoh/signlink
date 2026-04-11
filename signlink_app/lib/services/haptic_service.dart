import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [HapticFeedback] and respects the user's accessibility preference.
class HapticService {
  HapticService._();

  static bool _enabled = true;

  /// Call once in [main] after [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('a11y_haptic_feedback') ?? true;
  }

  /// Update at runtime when the user toggles the accessibility setting.
  static void setEnabled(bool value) => _enabled = value;

  /// Light tap — used for button presses and normal interactions.
  static void tap() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  /// Medium impact — used for confirmations and success moments.
  static void success() {
    if (_enabled) HapticFeedback.mediumImpact();
  }
}
