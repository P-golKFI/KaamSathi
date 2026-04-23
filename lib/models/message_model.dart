import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  prompt,
  system,
  numberShareRequest,
  numberShareAccepted,
  numberShareDeclined,
  skillsInfo,
  oneDayInfo,
}

class MessageModel {
  final String id;
  final String senderUid;
  final MessageType type;
  final String text;
  final String? promptKey;
  final DateTime createdAt;
  // One-day info card fields (only set when type == oneDayInfo)
  final String? oneDayDate;
  final String? oneDayTiming;
  final String? oneDaySkill;

  MessageModel({
    required this.id,
    required this.senderUid,
    required this.type,
    required this.text,
    this.promptKey,
    required this.createdAt,
    this.oneDayDate,
    this.oneDayTiming,
    this.oneDaySkill,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderUid: data['senderUid'] ?? '',
      type: _parseType(data['type'] ?? 'prompt'),
      text: data['text'] ?? '',
      promptKey: data['promptKey'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      oneDayDate: data['oneDayDate'] as String?,
      oneDayTiming: data['oneDayTiming'] as String?,
      oneDaySkill: data['oneDaySkill'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderUid': senderUid,
      'type': type.name,
      'text': text,
      'promptKey': promptKey,
      'createdAt': FieldValue.serverTimestamp(),
      if (oneDayDate != null) 'oneDayDate': oneDayDate,
      if (oneDayTiming != null) 'oneDayTiming': oneDayTiming,
      if (oneDaySkill != null) 'oneDaySkill': oneDaySkill,
    };
  }

  static MessageType _parseType(String value) {
    switch (value) {
      case 'system':
        return MessageType.system;
      case 'numberShareRequest':
        return MessageType.numberShareRequest;
      case 'numberShareAccepted':
        return MessageType.numberShareAccepted;
      case 'numberShareDeclined':
        return MessageType.numberShareDeclined;
      case 'skillsInfo':
        return MessageType.skillsInfo;
      case 'oneDayInfo':
        return MessageType.oneDayInfo;
      default:
        return MessageType.prompt;
    }
  }
}
