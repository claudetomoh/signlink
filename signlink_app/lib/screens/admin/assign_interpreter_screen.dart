import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/info_card.dart';
import '../../widgets/primary_button.dart';

class AssignInterpreterScreen extends StatefulWidget {
  final String requestId;
  const AssignInterpreterScreen({super.key, required this.requestId});

  @override
  State<AssignInterpreterScreen> createState() => _AssignInterpreterScreenState();
}

class _AssignInterpreterScreenState extends State<AssignInterpreterScreen> {
  String? _selectedInterpreter;
  bool _assigned = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers(role: 'interpreter');
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedule = context.watch<ScheduleProvider>();
    final userProv = context.watch<UserProvider>();
    final request = schedule.requests.where((r) => r.id == widget.requestId).firstOrNull
        ?? schedule.requests.firstOrNull;

    final interpreters = userProv.users.where((u) => u.role == 'interpreter').toList();

    if (request == null) {
      // Show list of pending requests to select from
      final pending = schedule.requests.where((r) => r.isPending).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Assign Interpreter')),
        body: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          itemCount: pending.length,
          itemBuilder: (_, i) {
            final r = pending[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                subtitle: Text(r.eventTitle),
                trailing: StatusBadge(status: r.status),
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AssignInterpreterScreen(requestId: r.id))),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Assign Interpreter')),
      body: _assigned
          ? _SuccessView(onDone: () => Navigator.pop(context))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request summary
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Details', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Inter')),
                        const SizedBox(height: 10),
                        _Row(label: 'Student', value: request.studentName),
                        _Row(label: 'Event', value: request.eventTitle),
                        _Row(label: 'Type', value: request.requestType),
                        _Row(label: 'Date', value: Helpers.formatDate(request.requestDate)),
                        _Row(label: 'Time', value: Helpers.formatTime(request.requestTime)),
                        _Row(label: 'Location', value: request.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Select Interpreter', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...interpreters.map((u) {
                    final selected = _selectedInterpreter == u.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedInterpreter = u.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            UserAvatar(name: u.fullName, imageUrl: u.profilePhoto, radius: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                                Text(u.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ]),
                            ),
                            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Assign Interpreter',
                    onPressed: (_selectedInterpreter == null || _loading)
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            final sm = ScaffoldMessenger.of(context);
                            final ok = await context.read<ScheduleProvider>().updateRequestStatus(
                              request.id,
                              'approved',
                              interpreterId: _selectedInterpreter,
                            );
                            if (!mounted) return;
                            setState(() => _loading = false);
                            if (ok) {
                              setState(() => _assigned = true);
                            } else {
                              sm.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to assign interpreter. Please try again.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    isLoading: _loading,
                  ),
                ],
              ),
            ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
        ]),
      );
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.success),
              const SizedBox(height: 20),
              Text('Interpreter Assigned!', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('The interpreter has been notified and the student will receive an update.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Done', onPressed: onDone),
            ],
          ),
        ),
      );
}

