import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  prompt,
  system,
  numberShareRequest,
  numberShareAccepted,
  numberShareDeclined,
}

class MessageModel {
  final String id;
  final String senderUid;
  final MessageType type;
  final String text;
  final String? promptKey;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderUid,
    required this.type,
    required this.text,
    this.promptKey,
    required this.createdAt,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderUid': senderUid,
      'type': type.name,
      'text': text,
      'promptKey': promptKey,
      'createdAt': FieldValue.serverTimestamp(),
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
      default:
        return MessageType.prompt;
    }
  }
}
