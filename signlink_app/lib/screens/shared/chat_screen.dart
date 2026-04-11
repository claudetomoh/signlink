import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/custom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    context.read<ChatProvider>()
      ..loadMessages(widget.conversationId)
      ..markRead(widget.conversationId, auth.currentUser?.id ?? 'student1');
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final conv = chat.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    chat.sendMessage(
      conversationId: widget.conversationId,
      senderId: auth.currentUser?.id ?? 'student1',
      receiverId: conv?.participantId ?? '',
      messageBody: text,
    );
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'student1';

    // Find conversation title
    final conv = chat.conversations.where((c) => c.id == widget.conversationId).firstOrNull;
    final title = conv?.participantName ?? 'Chat';
    final online = conv?.isOnline ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(name: title, radius: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                if (online) const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCall),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) {
                      final msg = chat.messages[i];
                      return ChatBubble(message: msg.messageBody, isSent: msg.isSentBy(userId), time: msg.sentAt);
                    },
                  ),
          ),
          _InputBar(controller: _msgCtrl, onSend: _send),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => onSend(),
                  textInputAction: TextInputAction.send,
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      );
}
