import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employer_profile_model.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Find helpers whose skills match an employer's work category and who work in the employer's city
  Future<List<Map<String, dynamic>>> getMatchingHelpers({
    required String workCategory,
    required String state,
    required String city,
    List<String> requiredSkills = const [],
  }) async {
    final skillsForCategory = categoryToSkills[workCategory];

    final baseQuery = _db
        .collection('users')
        .where('role', isEqualTo: 'helper')
        .where('profileComplete', isEqualTo: true)
        .where('state', isEqualTo: state);

    // Run both queries in parallel to handle old profiles (city field only)
    // and new profiles (workCities array field)
    final snapshots = await Future.wait([
      baseQuery.where('workCities', arrayContains: city).get(),
      baseQuery.where('city', isEqualTo: city).get(),
    ]);

    // Merge and deduplicate by doc ID (uid)
    final seen = <String>{};
    final merged = <Map<String, dynamic>>[];
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (seen.add(doc.id)) {
          merged.add(doc.data() as Map<String, dynamic>);
        }
      }
    }

    // Remove flagged underage accounts from results
    final eligible = merged.where((h) => h['isUnderage'] != true).toList();

    // Regular mode: only show helpers who offer full_time or hourly work
    final regularEligible = eligible.where((h) {
      final types = List<String>.from(h['scheduleTypes'] ?? []);
      return types.contains('full_time') || types.contains('hourly');
    }).toList();

    // For known categories, filter by matching skills in Dart
    // If requiredSkills is set, use those; otherwise fall back to all category skills
    // For 'other', show all helpers in the same state+city
    if (skillsForCategory != null && skillsForCategory.isNotEmpty) {
      final filterSkills = requiredSkills.isNotEmpty ? requiredSkills : skillsForCategory;
      return regularEligible.where((h) {
        final skills = List<String>.from(h['skills'] ?? []);
        return filterSkills.any((s) => skills.contains(s));
      }).toList();
    }

    return regularEligible;
  }

  /// Find employers whose work category matches a helper's skills and are in the helper's work cities
  Future<List<Map<String, dynamic>>> getMatchingEmployers({
    required List<String> skills,
    required String state,
    required List<String> workCities,
  }) async {
    if (workCities.isEmpty) return [];

    // Find which categories match the helper's skills
    final matchingCategories = <String>[];
    for (final entry in categoryToSkills.entries) {
      if (entry.value.any((skill) => skills.contains(skill))) {
        matchingCategories.add(entry.key);
      }
    }
    // 'other' employers are always relevant
    matchingCategories.add('other');

    // Run one query per category with city filter pushed to Firestore
    // (Firestore doesn't allow whereIn + whereIn in a single query)
    final snapshots = await Future.wait(
      matchingCategories.map((category) => _db
          .collection('users')
          .where('role', isEqualTo: 'employer')
          .where('profileComplete', isEqualTo: true)
          .where('state', isEqualTo: state)
          .where('workCategory', isEqualTo: category)
          .where('city', whereIn: workCities)
          .limit(50)
          .get()),
    );

    // Merge and deduplicate by doc ID
    final seen = <String>{};
    final merged = <Map<String, dynamic>>[];
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (seen.add(doc.id)) {
          merged.add(doc.data() as Map<String, dynamic>);
        }
      }
    }

    return merged;
  }

  /// Browse helpers in a specific category (for "try other categories")
  Future<List<Map<String, dynamic>>> browseHelpersByCategory({
    required String workCategory,
    required String state,
    required String city,
  }) async {
    return getMatchingHelpers(workCategory: workCategory, state: state, city: city);
  }
}
