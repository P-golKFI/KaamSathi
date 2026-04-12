import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import '../chat/chat_prompts.dart';
import '../models/message_model.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/prompt_button.dart';
import '../widgets/number_share_card.dart';
import '../widgets/gradient_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _convoId;
  String? _myUid;
  String? _myRole;
  String? _myName;
  String? _otherUid;
  String? _otherName;
  String? _otherRole;
  String? _otherCity;
  bool _isNewConversation = false;
  bool _initializing = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializing) {
      _initializing = false;
      _initChat();
    }
  }

  Future<void> _initChat() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _myUid = FirebaseAuth.instance.currentUser!.uid;

    final chatProvider = context.read<ChatProvider>();

    // If we already have a conversation ID, just open it
    if (args.containsKey('convoId')) {
      _convoId = args['convoId'] as String;
      chatProvider.openChat(_convoId!);
      ChatService().markConversationRead(_convoId!, _myUid!);
      // Get names from the conversation once it loads
      _loadNamesFromConvo();
      return;
    }

    // Otherwise, we're starting from a contact button
    final otherData = args['otherUserData'] as Map<String, dynamic>;
    final initiatorRole = args['initiatorRole'] as String;

    _otherUid = otherData['uid'] as String;
    _myRole = initiatorRole;
    _otherRole = initiatorRole == 'employer' ? 'helper' : 'employer';
    _otherCity = otherData['city'] as String? ?? '';

    // Get names based on role
    if (initiatorRole == 'employer') {
      _otherName =
          otherData['fullName'] ?? otherData['displayName'] ?? 'Helper';
    } else {
      _otherName =
          otherData['username'] ?? otherData['displayName'] ?? 'Employer';
    }

    // Get current user's name from Firestore
    final myDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_myUid)
        .get();
    final myData = myDoc.data() ?? {};
    if (initiatorRole == 'employer') {
      _myName = myData['username'] ?? myData['displayName'] ?? 'Employer';
      _otherCity = _otherCity!.isEmpty
          ? (myData['city'] ?? '')
          : _otherCity;
    } else {
      _myName = myData['fullName'] ?? myData['displayName'] ?? 'Helper';
    }

    // Check if a closed conversation exists — warn user
    final hasPrevious =
        await ChatService().hasClosedConversation(_myUid!, _otherUid!);
    if (hasPrevious && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Previous conversation'),
          content: Text(
            'You previously ended a conversation with ${_otherName ?? 'this person'}. Start a new conversation?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (proceed != true) {
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    // Start or find existing conversation
    _convoId = await chatProvider.startConversation(
      currentUid: _myUid!,
      otherUid: _otherUid!,
      currentRole: _myRole!,
      currentName: _myName!,
      otherName: _otherName!,
      otherRole: _otherRole!,
    );

    chatProvider.openChat(_convoId!);
    ChatService().markConversationRead(_convoId!, _myUid!);

    // Check if this is a brand new conversation (no messages yet)
    setState(() {
      _isNewConversation = true;
    });
  }

  Future<void> _loadNamesFromConvo() async {
    // Wait for the conversation to load via stream
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final convo = context.read<ChatProvider>().activeConversation;
    if (convo != null && _myUid != null) {
      setState(() {
        _otherName = convo.otherParticipantName(_myUid!);
        _otherUid = convo.otherParticipantUid(_myUid!);
        _myRole = convo.participantRoles[_myUid!];
        _otherRole = convo.otherParticipantRole(_myUid!);
        _myName = convo.participantNames[_myUid!];
      });
    }
  }

  @override
  void dispose() {
    context.read<ChatProvider>().closeChat();
    super.dispose();
  }

  // ──── Send a prompt message ────
  Future<void> _sendPrompt(ChatPrompt prompt) async {
    if (_convoId == null || _myUid == null) return;
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendPromptMessage(
      convoId: _convoId!,
      senderUid: _myUid!,
      prompt: prompt,
    );
    setState(() {
      _isNewConversation = false;
    });
  }

  // ──── Not Interested ────
  Future<void> _notInterested() async {
    if (_convoId == null) return;
    await context.read<ChatProvider>().endConversation(
          convoId: _convoId!,
          reason: 'not_interested',
        );
  }

  // ──── Share My Number ────
  Future<void> _requestShareNumber() async {
    if (_convoId == null || _myUid == null) return;
    await context.read<ChatProvider>().requestNumberShare(
          convoId: _convoId!,
          requestorUid: _myUid!,
          requestorName: _myName ?? 'Someone',
        );
  }

  // ──── Accept Number Share ────
  Future<void> _acceptShare() async {
    if (_convoId == null || _myUid == null || _otherUid == null) return;

    final myPhone =
        FirebaseAuth.instance.currentUser!.phoneNumber ?? '';

    // Fetch the other user's phone number
    final otherDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_otherUid)
        .get();
    final otherPhone = otherDoc.data()?['phoneNumber'] ?? '';

    if (!mounted) return;
    await context.read<ChatProvider>().acceptNumberShare(
          convoId: _convoId!,
          currentUid: _myUid!,
          currentPhone: myPhone,
          otherUid: _otherUid!,
          otherPhone: otherPhone,
        );
  }

  // ──── Decline Number Share (with double-confirm) ────
  Future<void> _declineShare() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Are you sure?'),
        content: const Text(
          "You won't be able to connect with this person.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Yes, Decline',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && _convoId != null && mounted) {
      final convo = context.read<ChatProvider>().activeConversation;
      await context.read<ChatProvider>().declineNumberShare(
            convoId: _convoId!,
            requestorUid: convo?.numberShareRequestedBy ?? '',
          );
    }
  }

  // ──── Report User ────
  Future<void> _reportUser() async {
    if (_myUid == null || _otherUid == null || _convoId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Report User'),
        content: Text('Report ${_otherName ?? 'this user'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Report',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ChatProvider>().reportUser(
            reporterUid: _myUid!,
            reportedUid: _otherUid!,
            conversationId: _convoId!,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text(
          _otherName ?? 'Chat',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'report') _reportUser();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'report',
                child: Text('Report User'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final convo = chatProvider.activeConversation;
          final messages = chatProvider.messages;

          if (convo == null && !_isNewConversation) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Message list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'Start the conversation by\npicking a message below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return ChatBubble(
                            message: msg,
                            isMine: msg.senderUid == _myUid,
                          );
                        },
                      ),
              ),

              // Bottom section — prompts, share button, etc.
              _buildBottomSection(convo, messages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(
    dynamic convo,
    List<MessageModel> messages,
  ) {
    // Conversation is closed
    if (convo != null && convo.isClosed) {
      return _buildClosedBar();
    }

    // Numbers already shared
    if (convo != null && convo.isNumbersShared) {
      return _buildNumbersSharedBar(convo);
    }

    // Number share requested by ME — waiting
    if (convo != null &&
        convo.numberShareState == 'requested' &&
        convo.numberShareRequestedBy == _myUid) {
      return _buildWaitingForAcceptBar();
    }

    // Number share requested by OTHER — show accept/decline
    if (convo != null &&
        convo.numberShareState == 'requested' &&
        convo.numberShareRequestedBy != _myUid) {
      return _buildAcceptDeclineBar(convo);
    }

    // New conversation — show opening prompts
    if (_isNewConversation && messages.isEmpty) {
      return _buildOpeningPromptsBar();
    }

    // Check whose turn it is
    if (convo != null && messages.isNotEmpty) {
      final lastMessage = messages.last;

      // If I sent the last message, I'm waiting for a reply
      if (lastMessage.senderUid == _myUid) {
        return _buildWaitingBar(convo);
      }

      // Other person sent the last prompt — show smart replies
      if (lastMessage.type == MessageType.prompt &&
          lastMessage.promptKey != null) {
        final promptKey = parsePromptKey(lastMessage.promptKey);
        if (promptKey != null) {
          final replies = getSmartReplies(
            lastReceivedKey: promptKey,
            currentUserRole: _myRole ?? '',
            location: _otherCity,
          );
          if (replies != null) {
            return _buildSmartRepliesBar(replies, convo);
          }
        }
      }
    }

    // Fallback — show opening prompts
    if (messages.isEmpty) {
      return _buildOpeningPromptsBar();
    }

    return const SizedBox.shrink();
  }

  // ──── Bottom Section Builders ────

  Widget _buildOpeningPromptsBar() {
    final prompts = getOpeningPrompts(
      initiatorRole: _myRole ?? 'helper',
      location: _otherCity,
    );

    return _buildPromptContainer(
      children: [
        Text(
          'Choose a message to send:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        ...prompts.map((p) => PromptButton(
              text: p.text,
              onTap: () => _sendPrompt(p),
            )),
      ],
    );
  }

  Widget _buildSmartRepliesBar(List<ChatPrompt> replies, dynamic convo) {
    return _buildPromptContainer(
      children: [
        ...replies.map((p) => PromptButton(
              text: p.text,
              isDestructive: p.endsChat,
              onTap: () => _sendPrompt(p),
            )),
        // Share My Number button (if unlocked)
        if (convo != null &&
            convo.isShareUnlocked &&
            convo.numberShareState == 'none') ...[
          const SizedBox(height: 4),
          GradientButton(
            text: 'Share My Number',
            gradient: AppGradients.orangeButtonGradient,
            onPressed: _requestShareNumber,
          ),
        ],
        // Not Interested link
        const SizedBox(height: 8),
        _buildNotInterestedLink(),
      ],
    );
  }

  Widget _buildWaitingBar(dynamic convo) {
    return _buildPromptContainer(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Waiting for response...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
        // Share My Number button (if unlocked and not yet requested)
        if (convo != null &&
            convo.isShareUnlocked &&
            convo.numberShareState == 'none') ...[
          const SizedBox(height: 8),
          GradientButton(
            text: 'Share My Number',
            gradient: AppGradients.orangeButtonGradient,
            onPressed: _requestShareNumber,
          ),
        ],
        const SizedBox(height: 8),
        _buildNotInterestedLink(),
      ],
    );
  }

  Widget _buildWaitingForAcceptBar() {
    return _buildPromptContainer(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 24, color: AppColors.orange),
                const SizedBox(height: 8),
                Text(
                  'Waiting for them to accept...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptDeclineBar(dynamic convo) {
    return _buildPromptContainer(
      children: [
        NumberShareCard(
          otherName: convo.participantNames[convo.numberShareRequestedBy],
          onAccept: _acceptShare,
          onDecline: _declineShare,
        ),
      ],
    );
  }

  Widget _buildNumbersSharedBar(dynamic convo) {
    final otherUid = convo.otherParticipantUid(_myUid!);
    final otherPhone = convo.sharedNumbers?[otherUid];

    return _buildPromptContainer(
      children: [
        NumberShareCard(
          isShared: true,
          otherName: _otherName,
          otherPhone: otherPhone,
        ),
      ],
    );
  }

  Widget _buildClosedBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Center(
        child: Text(
          'This conversation has ended.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotInterestedLink() {
    return Center(
      child: TextButton(
        onPressed: _notInterested,
        child: Text(
          'Not Interested',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildPromptContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
