import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/primary_button.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventProvider>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>();
    final event = events.events.where((e) => e.id == widget.eventId).firstOrNull;

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found')),
      );
    }

    final isSignedUp = events.isSignedUp(event.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: event.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        color: AppColors.primary,
                        child: const Center(
                          child: Icon(Icons.event_rounded, size: 72, color: Colors.white54),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.primary,
                      child: const Center(child: Icon(Icons.event_rounded, size: 72, color: Colors.white54)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.calendar_today_rounded, text: Helpers.formatDate(event.date)),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_rounded, text: event.location),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.people_rounded, text: '${event.signedUpCount} / ${event.capacity} attending'),
                  const SizedBox(height: 16),
                  // Capacity bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: event.capacityPercent.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.inputFill,
                      valueColor: AlwaysStoppedAnimation(event.capacityPercent >= 0.9 ? AppColors.error : AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('About', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  if (!event.isPast)
                    isSignedUp
                        ? Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.success),
                                SizedBox(width: 8),
                                Text('You\'re registered for this event', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : PrimaryButton(
                            label: 'Sign Up for Event',
                            onPressed: () => context.read<EventProvider>().signUp(event.id),
                            isLoading: events.isLoading,
                          ),
                  if (event.isPast)
                    const Center(child: Text('This event has ended', style: TextStyle(color: AppColors.textSecondary))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary))),
        ],
      );
}
