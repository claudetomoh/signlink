import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signlink_app/providers/accessibility_provider.dart';

void main() {
  // Ensure the Flutter binding is available so SharedPreferences mock works.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AccessibilityProvider — defaults', () {
    test('fontSize defaults to 1.0', () {
      final p = AccessibilityProvider();
      expect(p.fontSize, 1.0);
    });

    test('highContrast defaults to false', () {
      expect(AccessibilityProvider().highContrast, false);
    });

    test('reduceMotion defaults to false', () {
      expect(AccessibilityProvider().reduceMotion, false);
    });

    test('screenReader defaults to false', () {
      expect(AccessibilityProvider().screenReader, false);
    });

    test('hapticFeedback defaults to true', () {
      expect(AccessibilityProvider().hapticFeedback, true);
    });
  });

  group('AccessibilityProvider.load', () {
    test('uses defaults when SharedPreferences is empty', () async {
      final p = AccessibilityProvider();
      await p.load();
      expect(p.fontSize, 1.0);
      expect(p.highContrast, false);
    });

    test('restores persisted values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'a11y_font_size': 1.4,
        'a11y_high_contrast': true,
        'a11y_reduce_motion': true,
        'a11y_screen_reader': true,
        'a11y_haptic_feedback': false,
      });
      final p = AccessibilityProvider();
      await p.load();
      expect(p.fontSize, 1.4);
      expect(p.highContrast, true);
      expect(p.reduceMotion, true);
      expect(p.screenReader, true);
      expect(p.hapticFeedback, false);
    });
  });

  group('AccessibilityProvider setters', () {
    test('setFontSize updates fontSize', () async {
      final p = AccessibilityProvider();
      await p.setFontSize(1.2);
      expect(p.fontSize, 1.2);
    });

    test('setHighContrast updates highContrast', () async {
      final p = AccessibilityProvider();
      await p.setHighContrast(true);
      expect(p.highContrast, true);
    });

    test('setReduceMotion updates reduceMotion', () async {
      final p = AccessibilityProvider();
      await p.setReduceMotion(true);
      expect(p.reduceMotion, true);
    });

    test('setScreenReader updates screenReader', () async {
      final p = AccessibilityProvider();
      await p.setScreenReader(true);
      expect(p.screenReader, true);
    });

    test('setHapticFeedback updates hapticFeedback', () async {
      final p = AccessibilityProvider();
      await p.setHapticFeedback(false);
      expect(p.hapticFeedback, false);
    });

    test('setFontSize persists value to SharedPreferences', () async {
      final p = AccessibilityProvider();
      await p.setFontSize(1.5);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('a11y_font_size'), 1.5);
    });

    test('setHighContrast persists value to SharedPreferences', () async {
      final p = AccessibilityProvider();
      await p.setHighContrast(true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('a11y_high_contrast'), true);
    });
  });

  group('AccessibilityProvider.resetToDefaults', () {
    test('resets all values back to initial defaults', () async {
      final p = AccessibilityProvider();
      await p.setFontSize(1.8);
      await p.setHighContrast(true);
      await p.setReduceMotion(true);
      await p.setScreenReader(true);
      await p.setHapticFeedback(false);

      p.resetToDefaults();

      expect(p.fontSize, 1.0);
      expect(p.highContrast, false);
      expect(p.reduceMotion, false);
      expect(p.screenReader, false);
      expect(p.hapticFeedback, true);
    });
  });
}
