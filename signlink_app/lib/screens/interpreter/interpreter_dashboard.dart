import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/info_card.dart';

class InterpreterDashboard extends StatefulWidget {
  const InterpreterDashboard({super.key});

  @override
  State<InterpreterDashboard> createState() => _InterpreterDashboardState();
}

class _InterpreterDashboardState extends State<InterpreterDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<ScheduleProvider>().loadInterpreterSchedule(userId);
      context.read<ChatProvider>().loadConversations(userId);
    });
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: Navigator.pushNamed(context, AppRoutes.interpreterSchedule); break;
      case 2: Navigator.pushNamed(context, AppRoutes.messages); break;
      case 3: Navigator.pushNamed(context, AppRoutes.interpreterProfile); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final schedule = context.watch<ScheduleProvider>();
    final chat = context.watch<ChatProvider>();
    final notifs = context.watch<NotificationProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final pending = schedule.interpreterSchedules.where((s) => s.status == 'pending').length;
    final todayCount = schedule.interpreterSchedules.where((s) => s.isToday).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'SignLink',
        leading: UserAvatar(name: user.fullName, imageUrl: user.profilePhoto, radius: 18),
        actions: [
          AppBarAction(icon: Icons.notifications_outlined, badge: notifs.unreadCount, onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications)),
          AppBarAction(icon: Icons.chat_bubble_outline_rounded, badge: chat.totalUnread, onPressed: () => Navigator.pushNamed(context, AppRoutes.messages)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ScheduleProvider>().loadInterpreterSchedule(auth.currentUser?.id ?? ''),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingCard(name: user.fullName),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: StatCard(value: '$todayCount', label: 'Today', icon: Icons.class_rounded, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '$pending', label: 'Pending', icon: Icons.hourglass_empty_rounded, color: AppColors.warning)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '${schedule.interpreterSchedules.length}', label: 'Total', icon: Icons.bar_chart_rounded, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(title: "Today's Assignments", onSeeAll: () => Navigator.pushNamed(context, AppRoutes.interpreterSchedule)),
              const SizedBox(height: 12),
              if (schedule.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (schedule.interpreterSchedules.where((s) => s.isToday).isEmpty)
                _EmptyCard(message: 'No assignments today')
              else
                ...schedule.interpreterSchedules.where((s) => s.isToday).map((s) => _AssignmentCard(schedule: s)),
              const SizedBox(height: 24),
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
                  _QuickAction(icon: Icons.calendar_month_rounded, label: 'My Schedule', color: AppColors.primary, onTap: () => Navigator.pushNamed(context, AppRoutes.interpreterSchedule)),
                  _QuickAction(icon: Icons.event_available_rounded, label: 'Event Requests', color: AppColors.warning, onTap: () => Navigator.pushNamed(context, AppRoutes.interpreterRequests)),
                  _QuickAction(icon: Icons.check_circle_outline_rounded, label: 'Set Availability', color: AppColors.success, onTap: () => Navigator.pushNamed(context, AppRoutes.confirmAvailability)),
                  _QuickAction(icon: Icons.video_call_rounded, label: 'Video Call', color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, AppRoutes.videoCall)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule_rounded), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  const _GreetingCard({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interpreter Portal', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  Text(name.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                  const SizedBox(height: 4),
                  const Text('Manage your assignments', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter')),
                ],
              ),
            ),
            const Icon(Icons.sign_language_rounded, size: 48, color: Colors.white54),
          ],
        ),
      );
}

class _AssignmentCard extends StatelessWidget {
  final ScheduleModel schedule;
  const _AssignmentCard({required this.schedule});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 22),
          ),
          title: Text(schedule.courseName, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          subtitle: Text('${Helpers.formatTime(schedule.startTime)} - ${Helpers.formatTime(schedule.endTime)} • ${schedule.location}', style: const TextStyle(fontSize: 12)),
          trailing: StatusBadge(status: schedule.status),
        ),
      );
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
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
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

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
        child: Row(
          children: [
            const Icon(Icons.free_breakfast_rounded, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}
