import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/info_card.dart';

class StudentTimetable extends StatefulWidget {
  const StudentTimetable({super.key});

  @override
  State<StudentTimetable> createState() => _StudentTimetableState();
}

class _StudentTimetableState extends State<StudentTimetable> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final auth = context.read<AuthProvider>();
    context.read<ScheduleProvider>().loadStudentSchedule(auth.currentUser?.id ?? 'student1');
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleProvider>();
    final all = schedule.studentSchedules;

    final now = DateTime.now();
    final today = all.where((s) => s.scheduleDate.day == now.day && s.scheduleDate.month == now.month).toList();
    final upcoming = all.where((s) => s.scheduleDate.isAfter(now)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Schedule'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRoutes.requestStep1))],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Today'), Tab(text: 'Upcoming'), Tab(text: 'All')],
        ),
      ),
      body: schedule.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _ScheduleList(items: today, emptyMessage: 'No classes today'),
                _ScheduleList(items: upcoming, emptyMessage: 'No upcoming classes'),
                _ScheduleList(items: all, emptyMessage: 'No schedule found'),
              ],
            ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<ScheduleModel> items;
  final String emptyMessage;

  const _ScheduleList({required this.items, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy_rounded, size: 56, color: AppColors.border),
          const SizedBox(height: 12),
          Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: items.length,
      itemBuilder: (_, i) => _ScheduleTile(schedule: items[i]),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ScheduleModel schedule;
  const _ScheduleTile({required this.schedule});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.courseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter')),
                        const SizedBox(height: 2),
                        Text(schedule.courseCode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  StatusBadge(status: schedule.status),
                ],
              ),
              const SizedBox(height: 10),
              _Row(icon: Icons.access_time_rounded, text: '${Helpers.formatTime(schedule.startTime)} - ${Helpers.formatTime(schedule.endTime)}'),
              const SizedBox(height: 4),
              _Row(icon: Icons.location_on_rounded, text: schedule.location),
              if (schedule.hasInterpreter) ...[
                const SizedBox(height: 4),
                _Row(icon: Icons.person_rounded, text: 'Interpreter: ${schedule.interpreterName ?? ""}', color: AppColors.success),
              ],
              if (!schedule.hasInterpreter && schedule.status != 'cancelled') ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.requestStep1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: AppColors.warning),
                        SizedBox(width: 4),
                        Text('Request Interpreter', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Row({required this.icon, required this.text, this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 13)),
        ],
      );
}
