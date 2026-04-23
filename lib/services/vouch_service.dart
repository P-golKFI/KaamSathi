import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vouch_model.dart';

class VouchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _vouches => _db.collection('vouches');

  Future<void> createVouch({
    required String workerId,
    required String employerId,
    required String conversationId,
    required String employerDisplayName,
    required int rating,
    required List<String> tags,
    String? note,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5.');
    }
    for (final tag in tags) {
      if (!kAllowedVouchTags.contains(tag)) {
        throw ArgumentError('Invalid tag: $tag');
      }
    }
    if (tags.length > 5) {
      throw ArgumentError('Maximum 5 tags allowed.');
    }
    if (note != null && note.length > 500) {
      throw ArgumentError('Note must be 500 characters or fewer.');
    }

    // Duplicate check
    final existing = await _vouches
        .where('employerId', isEqualTo: employerId)
        .where('conversationId', isEqualTo: conversationId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError('You have already left a vouch for this conversation.');
    }

    final vouch = VouchModel(
      id: '',
      workerId: workerId,
      employerId: employerId,
      conversationId: conversationId,
      employerDisplayName: employerDisplayName,
      rating: rating,
      tags: tags,
      note: note,
      createdAt: DateTime.now(),
    );

    await _vouches.add(vouch.toFirestore());
    await _recomputeCachedFields(workerId);
  }

  Future<QuerySnapshot> getWorkerVouchesSnapshot(
    String workerId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _vouches
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<bool> hasVouchedForConversation({
    required String employerId,
    required String conversationId,
  }) async {
    final result = await _vouches
        .where('employerId', isEqualTo: employerId)
        .where('conversationId', isEqualTo: conversationId)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> _recomputeCachedFields(String workerId) async {
    final snapshot =
        await _vouches.where('workerId', isEqualTo: workerId).get();

    final docs = snapshot.docs;
    final count = docs.length;

    double avgRating = 0.0;
    final tagFrequency = <String, int>{};

    if (count > 0) {
      int total = 0;
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['rating'] as int? ?? 0);
        final docTags = List<String>.from(data['tags'] ?? []);
        for (final tag in docTags) {
          tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
        }
      }
      avgRating =
          double.parse((total / count).toStringAsFixed(1));
    }

    final sortedTags = tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(3).map((e) => e.key).toList();

    await _db.collection('users').doc(workerId).update({
      'avgRating': avgRating,
      'vouchCount': count,
      'topTags': topTags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
