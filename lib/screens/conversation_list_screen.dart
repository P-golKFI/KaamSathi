import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/conversation_model.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  late String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    // Start listening to conversations and check for expired ones
    context.read<ChatProvider>().listenToConversations(_myUid);
  }

  @override
  void dispose() {
    context.read<ChatProvider>().stopListeningToConversations();
    super.dispose();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat.jm().format(dateTime);
    if (diff.inDays < 7) return DateFormat.E().format(dateTime);
    return DateFormat.MMMd().format(dateTime);
  }

  Color _statusColor(ConversationModel convo) {
    if (convo.isNumbersShared) return AppColors.teal;
    if (convo.isClosed) return Colors.grey;
    return AppColors.orange;
  }

  String _statusLabel(ConversationModel convo) {
    if (convo.isNumbersShared) return 'Connected';
    if (convo.isClosed) return 'Ended';
    return 'Active';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text(
          AppLocalizations.of(context)!.conversations,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final conversations = chatProvider.conversations;

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noConversations,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap Contact on a profile to start chatting',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return _ConversationTile(
                convo: convo,
                myUid: _myUid,
                time: _formatTime(convo.lastMessageAt ?? convo.createdAt),
                statusColor: _statusColor(convo),
                statusLabel: _statusLabel(convo),
                onTap: () {
                  final phone = FirebaseAuth.instance.currentUser?.phoneNumber;
                  final chatArgs = {'convoId': convo.id};
                  if (phone == null || phone.isEmpty) {
                    Navigator.pushNamed(context, '/add-phone', arguments: chatArgs);
                  } else {
                    Navigator.pushNamed(context, '/chat', arguments: chatArgs);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel convo;
  final String myUid;
  final String time;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.convo,
    required this.myUid,
    required this.time,
    required this.statusColor,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherName = convo.otherParticipantName(myUid);
    final otherRole = convo.otherParticipantRole(myUid);
    final initials = otherName.isNotEmpty
        ? otherName
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';
    final isEmployer = otherRole == 'employer';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isEmployer ? AppColors.orange : AppColors.teal)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEmployer ? AppColors.orange : AppColors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.lastMessageText ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
