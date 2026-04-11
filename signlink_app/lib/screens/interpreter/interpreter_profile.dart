import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/primary_button.dart';

class InterpreterProfile extends StatelessWidget {
  const InterpreterProfile({super.key});

  Future<void> _changePhoto(BuildContext context, AuthProvider auth) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    // ignore: use_build_context_synchronously
    if (context.mounted) context.read<AuthProvider>().updateProfilePhoto(image.path);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final items = [
      _Item(icon: Icons.schedule_rounded, label: 'My Schedule', route: AppRoutes.interpreterSchedule),
      _Item(icon: Icons.event_available_rounded, label: 'Event Requests', route: AppRoutes.interpreterRequests),
      _Item(icon: Icons.check_circle_outline_rounded, label: 'Set Availability', route: AppRoutes.confirmAvailability),
      _Item(icon: Icons.notifications_outlined, label: 'Notifications', route: AppRoutes.notifications),
      _Item(icon: Icons.accessibility_new_rounded, label: 'Accessibility', route: AppRoutes.accessibility),
      _Item(icon: Icons.help_outline_rounded, label: 'Help & Support', route: AppRoutes.help),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _changePhoto(context, auth),
                    child: Stack(
                      children: [
                        UserAvatar(name: user.fullName, imageUrl: user.profilePhoto, radius: 42),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('INTERPRETER', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: items.asMap().entries.map((e) {
                  final item = e.value;
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(item.icon, color: AppColors.primary),
                        title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () => Navigator.pushNamed(context, item.route),
                      ),
                      if (e.key < items.length - 1) const Divider(height: 1, indent: 52),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            OutlineButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.read<NotificationProvider>().clear();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String route;
  const _Item({required this.icon, required this.label, required this.route});
}
