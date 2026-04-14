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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<ScheduleProvider>().loadStudentSchedule(auth.currentUser?.id ?? 'student1');
    });
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
          : schedule.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.border),
                      const SizedBox(height: 12),
                      Text(schedule.error!, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          context.read<ScheduleProvider>().loadStudentSchedule(auth.currentUser?.id ?? 'student1');
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
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
              if (!schedule.hasInterpreter && schedule.status != 'pending') ...[
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
              if (schedule.canRate) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showRatingDialog(context, schedule),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Rate Interpreter', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                ),
              ],
              if (schedule.isRated) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('Interpreter rated', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                  ],
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

void _showRatingDialog(BuildContext context, ScheduleModel schedule) {
  showDialog<void>(
    context: context,
    builder: (_) => _RatingDialog(schedule: schedule),
  );
}

class _RatingDialog extends StatefulWidget {
  final ScheduleModel schedule;
  const _RatingDialog({required this.schedule});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Interpreter', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('How was your experience with ${widget.schedule.interpreterName ?? "the interpreter"}?',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _rating >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.warning,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _rating == 0 ? 'Tap a star to rate' : ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][_rating],
            style: TextStyle(
              color: _rating == 0 ? AppColors.textSecondary : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_rating == 0 || _submitting)
              ? null
              : () async {
                  setState(() => _submitting = true);
                  final provider = context.read<ScheduleProvider>();
                  final ok = await provider.rateSchedule(
                    widget.schedule.id,
                    widget.schedule.interpreterId!,
                    _rating,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Rating submitted — thank you!' : 'Failed to submit rating. Please try again.'),
                    backgroundColor: ok ? AppColors.success : AppColors.error,
                  ));
                },
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit'),
        ),
      ],
    );
  }
}
