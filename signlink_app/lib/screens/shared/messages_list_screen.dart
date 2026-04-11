import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      context.read<ChatProvider>().loadConversations(auth.currentUser?.id ?? 'student1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages'), centerTitle: true),
      body: chat.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chat.conversations.isEmpty
              ? const Center(child: Text('No conversations yet', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  itemCount: chat.conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (_, i) => _ConversationTile(conversation: chat.conversations[i]),
                ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            UserAvatar(name: conversation.participantName, imageUrl: conversation.participantPhoto, radius: 26),
            if (conversation.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(conversation.participantName, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter'))),
            Text(
              _timeAgo(conversation.lastMessageAt),
              style: TextStyle(fontSize: 11, color: conversation.unreadCount > 0 ? AppColors.primary : AppColors.textSecondary),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage,
                style: TextStyle(
                  fontSize: 13,
                  color: conversation.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('${conversation.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.chat, arguments: conversation.id),
      );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
