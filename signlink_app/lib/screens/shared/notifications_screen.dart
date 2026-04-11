import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final items = notifProvider.notifications;
    final unread = notifProvider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Badge(
          label: Text('$unread'),
          isLabelVisible: unread > 0,
          child: const Text('Notifications'),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => context.read<NotificationProvider>().markAllRead(),
              child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: notifProvider.isLoading && items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('No notifications', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return GestureDetector(
                      onTap: () => context.read<NotificationProvider>().markRead(n.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: n.isRead
                                ? AppColors.border.withValues(alpha: 0.5)
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _typeColor(n.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: TextStyle(
                                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Helpers.relativeDate(n.createdAt),
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.content,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            if (!n.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppColors.primary, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'request':
      case 'new_request':
        return Icons.assignment_ind_rounded;
      case 'schedule':
        return Icons.calendar_today_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'request':
      case 'new_request':
        return AppColors.warning;
      case 'schedule':
        return AppColors.primary;
      case 'event':
        return AppColors.success;
      case 'message':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

