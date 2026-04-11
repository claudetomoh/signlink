import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/request_model.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/info_card.dart';

class EventRequestsScreen extends StatefulWidget {
  const EventRequestsScreen({super.key});

  @override
  State<EventRequestsScreen> createState() => _EventRequestsScreenState();
}

class _EventRequestsScreenState extends State<EventRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadRequests();
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
    final all = schedule.requests;
    final pending = all.where((r) => r.isPending).toList();
    final approved = all.where((r) => r.isApproved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Requests'),
        bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Pending'), Tab(text: 'Approved'), Tab(text: 'History')]),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RequestList(items: pending, emptyMsg: 'No pending requests'),
          _RequestList(items: approved, emptyMsg: 'No approved requests'),
          _RequestList(items: all, emptyMsg: 'No history'),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<RequestModel> items;
  final String emptyMsg;
  const _RequestList({required this.items, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(emptyMsg, style: const TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: items.length,
      itemBuilder: (_, i) => _RequestCard(request: items[i]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  const _RequestCard({required this.request});

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
                  Expanded(child: Text(request.eventTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter'))),
                  StatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 6),
              _Row(icon: Icons.person_rounded, text: request.studentName),
              const SizedBox(height: 4),
              _Row(icon: Icons.category_rounded, text: request.requestType),
              const SizedBox(height: 4),
              _Row(icon: Icons.calendar_today_rounded, text: Helpers.formatDate(request.requestDate)),
              const SizedBox(height: 4),
              _Row(icon: Icons.access_time_rounded, text: Helpers.formatTime(request.requestTime)),
              if (request.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                _Row(icon: Icons.location_on_rounded, text: request.location),
              ],
              if (request.isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<ScheduleProvider>().updateRequestStatus(request.id, 'declined'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.read<ScheduleProvider>().updateRequestStatus(request.id, 'approved'),
                        child: const Text('Accept'),
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      );
}
