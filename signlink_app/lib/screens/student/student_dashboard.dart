import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/info_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<ScheduleProvider>().loadStudentSchedule(userId);
      context.read<EventProvider>().loadEvents();
      context.read<ChatProvider>().loadConversations(userId);
    });
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: Navigator.pushNamed(context, AppRoutes.messages); break;
      case 2: Navigator.pushNamed(context, AppRoutes.notifications); break;
      case 3: Navigator.pushNamed(context, AppRoutes.studentProfile); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final schedule = context.watch<ScheduleProvider>();
    final events = context.watch<EventProvider>();
    final chat = context.watch<ChatProvider>();
    final notifs = context.watch<NotificationProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

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
        onRefresh: () async {
          final userId = context.read<AuthProvider>().currentUser?.id ?? '';
          context.read<ScheduleProvider>().loadStudentSchedule(userId);
          context.read<EventProvider>().loadEvents();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _GreetingCard(name: user.fullName),
              const SizedBox(height: 20),
              // Stats row
              Row(
                children: [
                  Expanded(child: StatCard(value: '${schedule.todaySchedules.length}', label: 'Classes Today', icon: Icons.class_rounded, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '${events.upcomingEvents.length}', label: 'Events', icon: Icons.event_rounded, color: AppColors.success)),
                  const SizedBox(width: 10),
                  Expanded(child: StatCard(value: '${chat.totalUnread}', label: 'Unread', icon: Icons.message_rounded, color: AppColors.warning)),
                ],
              ),
              const SizedBox(height: 24),
              // Today's schedule
              SectionHeader(
                title: "Today's Schedule",
                onSeeAll: () => Navigator.pushNamed(context, AppRoutes.studentTimetable),
              ),
              const SizedBox(height: 12),
              if (schedule.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (schedule.todaySchedules.isEmpty)
                _EmptyState(icon: Icons.free_breakfast_rounded, message: 'No classes today. Enjoy your free time!')
              else
                ...schedule.todaySchedules.map((s) => _ScheduleCard(schedule: s)),
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
                  _QuickAction(icon: Icons.person_add_rounded, label: 'Request Interpreter', color: AppColors.primary, onTap: () => Navigator.pushNamed(context, AppRoutes.requestStep1)),
                  _QuickAction(icon: Icons.upload_file_rounded, label: 'Upload Timetable', color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, AppRoutes.uploadTimetable)),
                  _QuickAction(icon: Icons.event_rounded, label: 'View Events', color: AppColors.success, onTap: () => Navigator.pushNamed(context, AppRoutes.eventsList)),
                  _QuickAction(icon: Icons.calendar_today_rounded, label: 'My Schedule', color: AppColors.warning, onTap: () => Navigator.pushNamed(context, AppRoutes.studentTimetable)),
                ],
              ),
              const SizedBox(height: 24),
              // Upcoming events
              SectionHeader(
                title: 'Upcoming Events',
                onSeeAll: () => Navigator.pushNamed(context, AppRoutes.eventsList),
              ),
              const SizedBox(height: 12),
              if (events.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (events.upcomingEvents.isEmpty)
                _EmptyState(icon: Icons.event_busy_rounded, message: 'No upcoming events.')
              else
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.upcomingEvents.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final e = events.upcomingEvents[i];
                      return SizedBox(
                        width: 280,
                        child: EventTile(
                          event: e,
                          isSignedUp: events.isSignedUp(e.id),
                          onSignUp: () => context.read<EventProvider>().signUp(e.id),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: e.id),
                        ),
                      );
                    },
                  ),
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
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
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
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    return Container(
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
                Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(name.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text('Welcome to SignLink', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontFamily: 'Inter')),
              ],
            ),
          ),
          const Icon(Icons.sign_language_rounded, size: 48, color: Colors.white54),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.class_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.courseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter')),
                    const SizedBox(height: 2),
                    Text('${Helpers.formatTime(schedule.startTime)} - ${Helpers.formatTime(schedule.endTime)} • ${schedule.location}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    if (schedule.hasInterpreter) ...[
                      const SizedBox(height: 4),
                      Text('Interpreter: ${schedule.interpreterName}',
                          style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              StatusBadge(status: schedule.status),
            ],
          ),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ],
        ),
      );
}
