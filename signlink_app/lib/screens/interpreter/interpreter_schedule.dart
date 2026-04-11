import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/info_card.dart';

class InterpreterSchedule extends StatefulWidget {
  const InterpreterSchedule({super.key});

  @override
  State<InterpreterSchedule> createState() => _InterpreterScheduleState();
}

class _InterpreterScheduleState extends State<InterpreterSchedule> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final auth = context.read<AuthProvider>();
    context.read<ScheduleProvider>().loadInterpreterSchedule(auth.currentUser?.id ?? 'interpreter1');
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleProvider>();
    final all = schedule.interpreterSchedules;
    final pending = all.where((s) => s.status == 'pending').toList();
    final confirmed = all.where((s) => s.status == 'confirmed').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Schedule'),
        bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Confirmed')]),
      ),
      body: schedule.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _List(items: all, onUpdate: (s, status) => context.read<ScheduleProvider>().updateStatus(s.id, status)),
                _List(items: pending, onUpdate: (s, status) => context.read<ScheduleProvider>().updateStatus(s.id, status), showActions: true),
                _List(items: confirmed, onUpdate: (s, status) => context.read<ScheduleProvider>().updateStatus(s.id, status)),
              ],
            ),
    );
  }
}

class _List extends StatelessWidget {
  final List<ScheduleModel> items;
  final void Function(ScheduleModel, String) onUpdate;
  final bool showActions;

  const _List({required this.items, required this.onUpdate, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('No items', style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: items.length,
      itemBuilder: (_, i) => _ScheduleCard(schedule: items[i], onUpdate: onUpdate, showActions: showActions),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final void Function(ScheduleModel, String) onUpdate;
  final bool showActions;
  const _ScheduleCard({required this.schedule, required this.onUpdate, required this.showActions});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(schedule.courseName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter'))),
                  StatusBadge(status: schedule.status),
                ],
              ),
              const SizedBox(height: 6),
              Text('${Helpers.formatTime(schedule.startTime)} - ${Helpers.formatTime(schedule.endTime)}  •  ${schedule.location}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Student: ${schedule.studentId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              if (showActions && schedule.status == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Decline'),
                        onPressed: () => onUpdate(schedule, 'cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Accept'),
                        onPressed: () => onUpdate(schedule, 'confirmed'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
}
