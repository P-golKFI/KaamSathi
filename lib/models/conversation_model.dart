import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final String initiatorUid;
  final String initiatorRole;
  final Map<String, String> participantNames;
  final Map<String, String> participantRoles;
  final String status; // "active" | "closed" | "numbers_shared"
  final String? closedReason;
  final String numberShareState; // "none" | "requested" | "shared" | "declined"
  final String? numberShareRequestedBy;
  final DateTime? numberShareRequestedAt;
  final Map<String, String>? sharedNumbers;
  final int messageCount;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final String? lastMessageText;
  final List<String> unreadBy;
  final String chatType; // 'termBased' | 'oneDay'
  final String? oneDayDate;
  final String? oneDayTiming;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.initiatorUid,
    required this.initiatorRole,
    required this.participantNames,
    required this.participantRoles,
    this.status = 'active',
    this.closedReason,
    this.numberShareState = 'none',
    this.numberShareRequestedBy,
    this.numberShareRequestedAt,
    this.sharedNumbers,
    this.messageCount = 0,
    this.lastMessageAt,
    this.lastMessageBy,
    this.lastMessageText,
    this.unreadBy = const [],
    this.chatType = 'termBased',
    this.oneDayDate,
    this.oneDayTiming,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isNumbersShared => status == 'numbers_shared';
  bool get isShareUnlocked => messageCount >= 2;
  bool get isOneDay => chatType == 'oneDay';

  String otherParticipantUid(String myUid) {
    return participants.firstWhere((uid) => uid != myUid);
  }

  String otherParticipantName(String myUid) {
    final otherUid = otherParticipantUid(myUid);
    return participantNames[otherUid] ?? 'Unknown';
  }

  String otherParticipantRole(String myUid) {
    final otherUid = otherParticipantUid(myUid);
    return participantRoles[otherUid] ?? '';
  }

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      initiatorUid: data['initiatorUid'] ?? '',
      initiatorRole: data['initiatorRole'] ?? '',
      participantNames:
          Map<String, String>.from(data['participantNames'] ?? {}),
      participantRoles:
          Map<String, String>.from(data['participantRoles'] ?? {}),
      status: data['status'] ?? 'active',
      closedReason: data['closedReason'],
      numberShareState: data['numberShareState'] ?? 'none',
      numberShareRequestedBy: data['numberShareRequestedBy'],
      numberShareRequestedAt:
          (data['numberShareRequestedAt'] as Timestamp?)?.toDate(),
      sharedNumbers: data['sharedNumbers'] != null
          ? Map<String, String>.from(data['sharedNumbers'])
          : null,
      messageCount: data['messageCount'] ?? 0,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageBy: data['lastMessageBy'],
      lastMessageText: data['lastMessageText'],
      unreadBy: List<String>.from(data['unreadBy'] ?? []),
      chatType: data['chatType'] as String? ?? 'termBased',
      oneDayDate: data['oneDayDate'] as String?,
      oneDayTiming: data['oneDayTiming'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'initiatorUid': initiatorUid,
      'initiatorRole': initiatorRole,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'status': status,
      'closedReason': closedReason,
      'numberShareState': numberShareState,
      'numberShareRequestedBy': numberShareRequestedBy,
      'numberShareRequestedAt': numberShareRequestedAt != null
          ? Timestamp.fromDate(numberShareRequestedAt!)
          : null,
      'sharedNumbers': sharedNumbers,
      'messageCount': messageCount,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageBy': lastMessageBy,
      'lastMessageText': lastMessageText,
      'unreadBy': unreadBy,
      'chatType': chatType,
      if (oneDayDate != null) 'oneDayDate': oneDayDate,
      if (oneDayTiming != null) 'oneDayTiming': oneDayTiming,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
