import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSent;
  final DateTime time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSent,
    required this.time,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          left: isSent ? 60 : 0,
          right: isSent ? 0 : 60,
          bottom: 6,
        ),
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSent ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isSent ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: isSent ? null : Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isSent ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              AppHelpers.formatTime(time),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
}
