import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    // System messages — centered, grey, no bubble
    if (message.type == MessageType.system ||
        message.type == MessageType.numberShareAccepted ||
        message.type == MessageType.numberShareDeclined) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    // Number share request — special card style
    if (message.type == MessageType.numberShareRequest) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: AppColors.orange),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // One-day info card — full-width teal info panel
    if (message.type == MessageType.oneDayInfo) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'One-day work request',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 6),
              if (message.oneDayDate != null)
                Text(
                  'Date: ${_formatOneDayDate(message.oneDayDate!)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.navyBlue),
                ),
              if (message.oneDayTiming != null)
                Text(
                  'Timing: ${message.oneDayTiming}',
                  style: const TextStyle(fontSize: 13, color: AppColors.navyBlue),
                ),
              if (message.oneDaySkill != null)
                Text(
                  'Skill needed: ${message.oneDaySkill}',
                  style: const TextStyle(fontSize: 13, color: AppColors.navyBlue),
                ),
            ],
          ),
        ),
      );
    }

    // Skills info — same bubble style, slightly smaller text
    if (message.type == MessageType.skillsInfo) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMine) const Spacer(flex: 2),
            Flexible(
              flex: 5,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.teal.withValues(alpha: 0.85) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isMine ? Colors.white : AppColors.navyBlue,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (!isMine) const Spacer(flex: 2),
          ],
        ),
      );
    }

    // Regular prompt messages — chat bubbles
    final time = DateFormat.jm().format(message.createdAt);


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isMine) const Spacer(flex: 2),
          Flexible(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppColors.teal : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMine ? Colors.white : AppColors.navyBlue,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isMine) const Spacer(flex: 2),
        ],
      ),
    );
  }

  static String _formatOneDayDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
