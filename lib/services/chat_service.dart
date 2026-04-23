import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // Conversations
  // ──────────────────────────────────────────────

  /// Find an existing active conversation between two users.
  /// Returns the conversation ID if found, null otherwise.
  Future<String?> _findExistingConversation(
      String uid1, String uid2) async {
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContains: uid1)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(uid2)) {
        return doc.id;
      }
    }
    return null;
  }

  /// Find an existing active one-day conversation between two users.
  Future<String?> _findExistingOneDayConversation(
      String uid1, String uid2) async {
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContains: uid1)
        .where('chatType', isEqualTo: 'oneDay')
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(uid2)) {
        return doc.id;
      }
    }
    return null;
  }

  /// Check if a closed conversation exists between two users.
  /// Returns true if they've chatted before and it ended.
  Future<bool> hasClosedConversation(String uid1, String uid2) async {
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContains: uid1)
        .where('status', isEqualTo: 'closed')
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(uid2)) {
        return true;
      }
    }
    return false;
  }

  /// Start a new conversation or return existing one.
  /// Returns the conversation document ID.
  Future<String> startConversation({
    required String currentUid,
    required String otherUid,
    required String currentRole,
    required String currentName,
    required String otherName,
    required String otherRole,
  }) async {
    // Check for existing active conversation
    final existingId = await _findExistingConversation(currentUid, otherUid);
    if (existingId != null) return existingId;

    // Create new conversation
    final doc = _db.collection('conversations').doc();
    final conversation = ConversationModel(
      id: doc.id,
      participants: [currentUid, otherUid],
      initiatorUid: currentUid,
      initiatorRole: currentRole,
      participantNames: {currentUid: currentName, otherUid: otherName},
      participantRoles: {currentUid: currentRole, otherUid: otherRole},
      chatType: 'termBased',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await doc.set(conversation.toFirestore());
    return doc.id;
  }

  /// Start a one-day conversation or return the existing active one.
  /// Auto-inserts the oneDayInfo card as the first message.
  Future<String> startOneDayConversation({
    required String employerUid,
    required String helperUid,
    required String employerName,
    required String helperName,
    required String oneDayDate,
    required String oneDayTiming,
    required String oneDaySkill,
  }) async {
    // Return existing active one-day chat if present
    final existingId = await _findExistingOneDayConversation(employerUid, helperUid);
    if (existingId != null) return existingId;

    final doc = _db.collection('conversations').doc();
    final conversation = ConversationModel(
      id: doc.id,
      participants: [employerUid, helperUid],
      initiatorUid: employerUid,
      initiatorRole: 'employer',
      participantNames: {employerUid: employerName, helperUid: helperName},
      participantRoles: {employerUid: 'employer', helperUid: 'helper'},
      chatType: 'oneDay',
      oneDayDate: oneDayDate,
      oneDayTiming: oneDayTiming,
      messageCount: 1,
      lastMessageText: 'One-day work request',
      unreadBy: [helperUid],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final batch = _db.batch();

    // Create conversation doc
    batch.set(doc, {
      ...conversation.toFirestore(),
      'initiatedBy': employerUid,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    // Auto-insert oneDayInfo card message
    final msgRef = doc.collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': employerUid,
      'type': 'oneDayInfo',
      'text': 'One-day work request',
      'oneDayDate': oneDayDate,
      'oneDayTiming': oneDayTiming,
      'oneDaySkill': oneDaySkill,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return doc.id;
  }

  // ──────────────────────────────────────────────
  // Messages
  // ──────────────────────────────────────────────

  /// Send a prompt message in a conversation.
  Future<void> sendPromptMessage({
    required String convoId,
    required String senderUid,
    required String receiverUid,
    required String promptKey,
    required String text,
  }) async {
    final batch = _db.batch();

    // Add message to sub-collection
    final msgRef =
        _db.collection('conversations').doc(convoId).collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': senderUid,
      'type': 'prompt',
      'text': text,
      'promptKey': promptKey,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update conversation metadata
    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': senderUid,
      'lastMessageText': text,
      'messageCount': FieldValue.increment(1),
      'unreadBy': FieldValue.arrayUnion([receiverUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Auto-send employer's required skills as a follow-up to an opening message.
  Future<void> sendSkillsMessage({
    required String convoId,
    required String senderUid,
    required String receiverUid,
    required List<String> skills,
  }) async {
    final text = 'Skills I\'m looking for: ${skills.join(', ')}';
    final batch = _db.batch();

    final msgRef =
        _db.collection('conversations').doc(convoId).collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': senderUid,
      'type': 'skillsInfo',
      'text': text,
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': senderUid,
      'lastMessageText': text,
      'messageCount': FieldValue.increment(1),
      'unreadBy': FieldValue.arrayUnion([receiverUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Send a system message (e.g. "This conversation has ended").
  Future<void> sendSystemMessage({
    required String convoId,
    required String text,
  }) async {
    await _db
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .add({
      'senderUid': 'system',
      'type': 'system',
      'text': text,
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────────────────
  // Number sharing
  // ──────────────────────────────────────────────

  /// Request to share phone numbers.
  Future<void> requestNumberShare({
    required String convoId,
    required String requestorUid,
    required String requestorName,
    required String receiverUid,
  }) async {
    final batch = _db.batch();

    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'numberShareState': 'requested',
      'numberShareRequestedBy': requestorUid,
      'numberShareRequestedAt': FieldValue.serverTimestamp(),
      'unreadBy': FieldValue.arrayUnion([receiverUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final msgRef = convoRef.collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': requestorUid,
      'type': 'numberShareRequest',
      'text': '$requestorName wants to share phone numbers with you.',
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Accept the number share request — reveal both numbers.
  Future<void> acceptNumberShare({
    required String convoId,
    required String currentUid,
    required String currentPhone,
    required String otherUid,
    required String otherPhone,
  }) async {
    final batch = _db.batch();

    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'numberShareState': 'shared',
      'status': 'numbers_shared',
      'sharedNumbers': {
        currentUid: currentPhone,
        otherUid: otherPhone,
      },
      'unreadBy': FieldValue.arrayUnion([otherUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final msgRef = convoRef.collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': 'system',
      'type': 'numberShareAccepted',
      'text': 'Phone numbers shared successfully! You can now call each other.',
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Decline the number share request.
  Future<void> declineNumberShare({
    required String convoId,
    required String requestorUid,
  }) async {
    final batch = _db.batch();

    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'numberShareState': 'declined',
      'unreadBy': FieldValue.arrayUnion([requestorUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Soft message to the requestor
    final msgRef1 = convoRef.collection('messages').doc();
    batch.set(msgRef1, {
      'senderUid': 'system',
      'type': 'numberShareDeclined',
      'text': "They're not ready to share numbers yet.",
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Auto-reply on behalf of the requestor
    final msgRef2 = convoRef.collection('messages').doc();
    batch.set(msgRef2, {
      'senderUid': requestorUid,
      'type': 'system',
      'text': 'No problem. Let me know if you change your mind.',
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // Close / End conversation
  // ──────────────────────────────────────────────

  /// Close a conversation with a reason and system message.
  Future<void> closeConversation({
    required String convoId,
    required String reason,
    required String displayMessage,
  }) async {
    final batch = _db.batch();

    final convoRef = _db.collection('conversations').doc(convoId);
    batch.update(convoRef, {
      'status': 'closed',
      'closedReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final msgRef = convoRef.collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': 'system',
      'type': 'system',
      'text': displayMessage,
      'promptKey': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ──────────────────────────────────────────────
  // Streams (real-time listeners)
  // ──────────────────────────────────────────────

  /// Stream of all conversations for a user, sorted by most recent.
  Stream<List<ConversationModel>> getUserConversations(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList());
  }

  /// Stream of messages in a conversation, oldest first.
  Stream<List<MessageModel>> getMessages(String convoId) {
    return _db
        .collection('conversations')
        .doc(convoId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  /// Stream of a single conversation document (for real-time status updates).
  Stream<ConversationModel?> getConversation(String convoId) {
    return _db
        .collection('conversations')
        .doc(convoId)
        .snapshots()
        .map((doc) =>
            doc.exists ? ConversationModel.fromFirestore(doc) : null);
  }

  // ──────────────────────────────────────────────
  // Client-side expiry checks
  // ──────────────────────────────────────────────

  /// Check and close expired conversations for a user.
  /// Called when the conversation list or chat screen opens.
  Future<void> checkAndCloseExpired(String uid) async {
    final now = DateTime.now();
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in query.docs) {
      final convo = ConversationModel.fromFirestore(doc);
      final lastMsg = convo.lastMessageAt;

      if (lastMsg == null) continue;

      // 48h no reply: someone sent a message but other person hasn't replied
      if (convo.lastMessageBy != null &&
          convo.lastMessageBy != uid &&
          now.difference(lastMsg).inHours >= 48) {
        await closeConversation(
          convoId: convo.id,
          reason: 'no_response_48h',
          displayMessage:
              'No response received. This conversation has been closed.',
        );
        continue;
      }

      // 7 day inactivity
      if (now.difference(lastMsg).inDays >= 7) {
        await closeConversation(
          convoId: convo.id,
          reason: 'inactivity_7d',
          displayMessage:
              'This conversation has expired due to inactivity.',
        );
        continue;
      }

      // 24h after number share decline
      if (convo.numberShareState == 'declined' &&
          convo.numberShareRequestedAt != null &&
          now.difference(convo.numberShareRequestedAt!).inHours >= 24) {
        await closeConversation(
          convoId: convo.id,
          reason: 'share_declined_expired',
          displayMessage: 'This conversation has expired.',
        );
        continue;
      }
    }
  }

  // ──────────────────────────────────────────────
  // Read / Unread tracking
  // ──────────────────────────────────────────────

  /// Mark a conversation as read for a user (removes them from unreadBy).
  Future<void> markConversationRead(String convoId, String uid) async {
    await _db.collection('conversations').doc(convoId).update({
      'unreadBy': FieldValue.arrayRemove([uid]),
    });
  }

  /// Stream that emits true if the user has any conversation with unread messages.
  Stream<bool> hasUnreadConversations(String uid) {
    return getUserConversations(uid).map(
      (convos) => convos.any((c) => c.unreadBy.contains(uid)),
    );
  }

  // ──────────────────────────────────────────────
  // Reporting
  // ──────────────────────────────────────────────

  /// Submit a full report with reasons, description, and optional file attachment.
  Future<void> submitReport({
    required String reporterUid,
    required String reportedUid,
    required String reportedName,
    required String conversationId,
    required List<String> reasons,
    required String description,
    PlatformFile? attachedFile,
  }) async {
    String? attachmentUrl;
    String? attachmentName;

    if (attachedFile != null && attachedFile.bytes != null) {
      final ref = FirebaseStorage.instance.ref(
          'reports/$reporterUid/${DateTime.now().millisecondsSinceEpoch}_${attachedFile.name}');
      await ref.putData(attachedFile.bytes!);
      attachmentUrl = await ref.getDownloadURL();
      attachmentName = attachedFile.name;
    }

    await _db.collection('reports').add({
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reportedName': reportedName,
      'conversationId': conversationId,
      'reasons': reasons,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
