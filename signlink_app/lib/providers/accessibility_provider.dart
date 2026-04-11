import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/haptic_service.dart';

/// Manages accessibility preference state and persists to SharedPreferences.
/// Consumed in [SignLinkApp] builder to apply text scaling app-wide.
class AccessibilityProvider extends ChangeNotifier {
  static const _kFontSize = 'a11y_font_size';
  static const _kHighContrast = 'a11y_high_contrast';
  static const _kReduceMotion = 'a11y_reduce_motion';
  static const _kScreenReader = 'a11y_screen_reader';
  static const _kHaptic = 'a11y_haptic_feedback';

  double _fontSize = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _screenReader = false;
  bool _hapticFeedback = true;

  double get fontSize => _fontSize;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  bool get screenReader => _screenReader;
  bool get hapticFeedback => _hapticFeedback;

  /// Call once at startup to restore persisted settings.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_kFontSize) ?? 1.0;
    _highContrast = prefs.getBool(_kHighContrast) ?? false;
    _reduceMotion = prefs.getBool(_kReduceMotion) ?? false;
    _screenReader = prefs.getBool(_kScreenReader) ?? false;
    _hapticFeedback = prefs.getBool(_kHaptic) ?? true;
    notifyListeners();
  }

  Future<void> setFontSize(double v) async {
    _fontSize = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, v);
  }

  Future<void> setHighContrast(bool v) async {
    _highContrast = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrast, v);
  }

  Future<void> setReduceMotion(bool v) async {
    _reduceMotion = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceMotion, v);
  }

  Future<void> setScreenReader(bool v) async {
    _screenReader = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kScreenReader, v);
  }

  Future<void> setHapticFeedback(bool v) async {
    _hapticFeedback = v;
    HapticService.setEnabled(v);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHaptic, v);
  }

  Future<void> resetToDefaults() async {
    _fontSize = 1.0;
    _highContrast = false;
    _reduceMotion = false;
    _screenReader = false;
    _hapticFeedback = true;
    HapticService.setEnabled(true);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, 1.0);
    await prefs.setBool(_kHighContrast, false);
    await prefs.setBool(_kReduceMotion, false);
    await prefs.setBool(_kScreenReader, false);
    await prefs.setBool(_kHaptic, true);
  }
}
