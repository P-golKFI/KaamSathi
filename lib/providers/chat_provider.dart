import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../chat/chat_prompts.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // ──── State ────
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  ConversationModel? _activeConversation;
  bool _isLoading = false;

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _activeConvoSubscription;

  // ──── Getters ────
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  ConversationModel? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;

  // ──── Conversation List ────

  /// Start listening to all conversations for a user.
  void listenToConversations(String uid) {
    _conversationsSubscription?.cancel();
    _conversationsSubscription =
        _chatService.getUserConversations(uid).listen((convos) {
      _conversations = convos;
      notifyListeners();
    });

    // Also check for expired conversations
    _chatService.checkAndCloseExpired(uid);
  }

  /// Stop listening to the conversation list.
  void stopListeningToConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
  }

  // ──── Active Chat ────

  /// Start listening to a specific conversation and its messages.
  void openChat(String convoId) {
    _messages = [];
    _activeConversation = null;

    _activeConvoSubscription?.cancel();
    _activeConvoSubscription =
        _chatService.getConversation(convoId).listen((convo) {
      _activeConversation = convo;
      notifyListeners();
    });

    _messagesSubscription?.cancel();
    _messagesSubscription =
        _chatService.getMessages(convoId).listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
  }

  /// Stop listening to the active chat.
  void closeChat() {
    _activeConvoSubscription?.cancel();
    _activeConvoSubscription = null;
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _activeConversation = null;
    _messages = [];
  }

  // ──── Actions ────

  /// Start a new conversation (or find existing) and return the convo ID.
  Future<String> startConversation({
    required String currentUid,
    required String otherUid,
    required String currentRole,
    required String currentName,
    required String otherName,
    required String otherRole,
  }) async {
    _isLoading = true;
    notifyListeners();

    final convoId = await _chatService.startConversation(
      currentUid: currentUid,
      otherUid: otherUid,
      currentRole: currentRole,
      currentName: currentName,
      otherName: otherName,
      otherRole: otherRole,
    );

    _isLoading = false;
    notifyListeners();
    return convoId;
  }

  /// Send a prompt message.
  Future<void> sendPromptMessage({
    required String convoId,
    required String senderUid,
    required ChatPrompt prompt,
  }) async {
    final receiverUid = _activeConversation?.otherParticipantUid(senderUid) ?? '';
    await _chatService.sendPromptMessage(
      convoId: convoId,
      senderUid: senderUid,
      receiverUid: receiverUid,
      promptKey: prompt.key.name,
      text: prompt.text,
    );

    // If this prompt ends the chat, close it
    if (prompt.endsChat) {
      await _chatService.closeConversation(
        convoId: convoId,
        reason: 'not_interested',
        displayMessage: 'This conversation has ended.',
      );
    }

    // If this prompt triggers the share flow, request number share
    if (prompt.triggersShareFlow && _activeConversation != null) {
      final convo = _activeConversation!;
      final senderName =
          convo.participantNames[senderUid] ?? 'Someone';
      await _chatService.requestNumberShare(
        convoId: convoId,
        requestorUid: senderUid,
        requestorName: senderName,
        receiverUid: receiverUid,
      );
    }
  }

  /// Auto-send employer's required skills.
  Future<void> sendSkillsMessage({
    required String convoId,
    required String senderUid,
    required List<String> skills,
  }) async {
    final receiverUid = _activeConversation?.otherParticipantUid(senderUid) ?? '';
    await _chatService.sendSkillsMessage(
      convoId: convoId,
      senderUid: senderUid,
      receiverUid: receiverUid,
      skills: skills,
    );
  }

  /// Request to share phone numbers.
  Future<void> requestNumberShare({
    required String convoId,
    required String requestorUid,
    required String requestorName,
  }) async {
    final receiverUid = _activeConversation?.otherParticipantUid(requestorUid) ?? '';
    await _chatService.requestNumberShare(
      convoId: convoId,
      requestorUid: requestorUid,
      requestorName: requestorName,
      receiverUid: receiverUid,
    );
  }

  /// Accept number share — reveal both numbers.
  Future<void> acceptNumberShare({
    required String convoId,
    required String currentUid,
    required String currentPhone,
    required String otherUid,
    required String otherPhone,
  }) async {
    await _chatService.acceptNumberShare(
      convoId: convoId,
      currentUid: currentUid,
      currentPhone: currentPhone,
      otherUid: otherUid,
      otherPhone: otherPhone,
    );
  }

  /// Decline number share.
  Future<void> declineNumberShare({
    required String convoId,
    required String requestorUid,
  }) async {
    await _chatService.declineNumberShare(
      convoId: convoId,
      requestorUid: requestorUid,
    );
  }

  /// Close a conversation (e.g. "Not Interested").
  Future<void> endConversation({
    required String convoId,
    required String reason,
    String displayMessage = 'This conversation has ended.',
  }) async {
    await _chatService.closeConversation(
      convoId: convoId,
      reason: reason,
      displayMessage: displayMessage,
    );
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _activeConvoSubscription?.cancel();
    super.dispose();
  }
}
