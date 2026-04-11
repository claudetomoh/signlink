import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/info_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadRequests();
      context.read<EventProvider>().loadEvents();
      context.read<UserProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final schedule = context.watch<ScheduleProvider>();
    final userProv = context.watch<UserProvider>();
    final user = auth.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final students = userProv.studentCount;
    final interpreters = userProv.interpreterCount;
    final pending = schedule.requests.where((r) => r.isPending).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        leading: UserAvatar(name: user.fullName, imageUrl: user.profilePhoto, radius: 18),
        actions: [
          AppBarAction(icon: Icons.notifications_outlined, onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Admin Portal', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
                      const SizedBox(height: 4),
                      Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                    ]),
                  ),
                  const Icon(Icons.admin_panel_settings_rounded, color: Colors.white54, size: 44),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats
            Row(children: [
              Expanded(child: StatCard(value: '$students', label: 'Students', icon: Icons.school_rounded, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(value: '$interpreters', label: 'Interpreters', icon: Icons.sign_language_rounded, color: AppColors.success)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(value: '$pending', label: 'Pending', icon: Icons.pending_actions_rounded, color: AppColors.warning)),
            ]),
            const SizedBox(height: 24),
            // Quick actions
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _QuickAction(icon: Icons.people_rounded, label: 'Manage Users', color: AppColors.primary, onTap: () => Navigator.pushNamed(context, AppRoutes.manageUsers)),
                _QuickAction(icon: Icons.assignment_ind_rounded, label: 'Assign Interpreter', color: AppColors.warning, onTap: () => Navigator.pushNamed(context, AppRoutes.assignInterpreter)),
                _QuickAction(icon: Icons.event_rounded, label: 'Create Event', color: AppColors.success, onTap: () => Navigator.pushNamed(context, AppRoutes.createEvent)),
                _QuickAction(icon: Icons.event_available_rounded, label: 'View Events', color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, AppRoutes.eventsList)),
              ],
            ),
            const SizedBox(height: 24),
            // Recent requests
            SectionHeader(title: 'Recent Requests', onSeeAll: () => Navigator.pushNamed(context, AppRoutes.assignInterpreter)),
            const SizedBox(height: 12),
            ...schedule.requests.take(5).map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 20),
                ),
                title: Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Inter')),
                subtitle: Text(r.eventTitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: StatusBadge(status: r.status),
                onTap: () => Navigator.pushNamed(context, AppRoutes.assignInterpreter, arguments: r.id),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1: Navigator.pushNamed(context, AppRoutes.manageUsers); break;
            case 2: Navigator.pushNamed(context, AppRoutes.eventsList); break;
            case 3: Navigator.pushNamed(context, AppRoutes.notifications); break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.event_rounded), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.radiusMD), border: Border.all(color: color.withValues(alpha: 0.25))),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Inter'), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
}
