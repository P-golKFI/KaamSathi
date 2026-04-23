import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kAllowedVouchTags = [
  'Professional',
  'Punctual',
  'Thorough',
  'Friendly',
  'Skilled',
  'Trustworthy',
  'Great communicator',
  'Goes above and beyond',
  'Efficient',
  'Respectful',
];

class VouchModel {
  final String id;
  final String workerId;
  final String employerId;
  final String conversationId;
  final String employerDisplayName;
  final int rating;
  final List<String> tags;
  final String? note;
  final DateTime createdAt;

  VouchModel({
    required this.id,
    required this.workerId,
    required this.employerId,
    required this.conversationId,
    required this.employerDisplayName,
    required this.rating,
    required this.tags,
    this.note,
    required this.createdAt,
  });

  factory VouchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VouchModel(
      id: doc.id,
      workerId: data['workerId'] as String? ?? '',
      employerId: data['employerId'] as String? ?? '',
      conversationId: data['conversationId'] as String? ?? '',
      employerDisplayName: data['employerDisplayName'] as String? ?? '',
      rating: data['rating'] as int? ?? 1,
      tags: List<String>.from(data['tags'] ?? []),
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'workerId': workerId,
      'employerId': employerId,
      'conversationId': conversationId,
      'employerDisplayName': employerDisplayName,
      'rating': rating,
      'tags': tags,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
