import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/info_card.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a11y = context.watch<AccessibilityProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        children: [
          // Text Size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Text Size'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('A', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Expanded(
                        child: Slider(
                          value: a11y.fontSize,
                          min: 0.8,
                          max: 1.4,
                          divisions: 3,
                          activeColor: AppColors.primary,
                          onChanged: (v) => context.read<AccessibilityProvider>().setFontSize(v),
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 22, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Center(
                    child: Text(
                      'Preview Text',
                      style: TextStyle(fontSize: 16 * a11y.fontSize, fontFamily: 'Inter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Toggles
          Card(
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.contrast_rounded,
                  title: 'High Contrast',
                  subtitle: 'Increase color contrast for better visibility',
                  value: a11y.highContrast,
                  onChanged: (v) => context.read<AccessibilityProvider>().setHighContrast(v),
                ),
                const Divider(height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.motion_photos_off_rounded,
                  title: 'Reduce Motion',
                  subtitle: 'Minimize animations and transitions',
                  value: a11y.reduceMotion,
                  onChanged: (v) => context.read<AccessibilityProvider>().setReduceMotion(v),
                ),
                const Divider(height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Screen Reader Support',
                  subtitle: 'Optimized labels for screen readers',
                  value: a11y.screenReader,
                  onChanged: (v) => context.read<AccessibilityProvider>().setScreenReader(v),
                ),
                const Divider(height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.vibration_rounded,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration feedback for interactions',
                  value: a11y.hapticFeedback,
                  onChanged: (v) => context.read<AccessibilityProvider>().setHapticFeedback(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Reset
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset to Default'),
            onPressed: () => context.read<AccessibilityProvider>().resetToDefaults(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );
}
