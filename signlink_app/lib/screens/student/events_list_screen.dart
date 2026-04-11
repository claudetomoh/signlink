import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/event_tile.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    context.read<EventProvider>().loadEvents();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'student1';

    List<EventModel> filter(List<EventModel> list) => _searchQuery.isEmpty
        ? list
        : list.where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMD), borderSide: BorderSide.none),
                  ),
                ),
              ),
              TabBar(controller: _tabs, tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past'), Tab(text: 'Registered')]),
            ],
          ),
        ),
      ),
      body: events.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _EventList(events: filter(events.upcomingEvents), userId: userId, emptyMsg: 'No upcoming events'),
                _EventList(events: filter(events.pastEvents), userId: userId, emptyMsg: 'No past events'),
                _EventList(
                  events: filter(events.upcomingEvents.where((e) => events.isSignedUp(e.id)).toList()),
                  userId: userId,
                  emptyMsg: 'You haven\'t signed up for any events',
                ),
              ],
            ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<EventModel> events;
  final String userId;
  final String emptyMsg;

  const _EventList({required this.events, required this.userId, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy_rounded, size: 56, color: AppColors.border),
          const SizedBox(height: 12),
          Text(emptyMsg, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final e = events[i];
        return EventTile(
          event: e,
          isSignedUp: context.watch<EventProvider>().isSignedUp(e.id),
          onSignUp: () => context.read<EventProvider>().signUp(e.id),
          onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: e.id),
        );
      },
    );
  }
}
