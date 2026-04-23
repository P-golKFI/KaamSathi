import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/employer_profile_model.dart';
import '../models/helper_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get a user document by UID (works offline thanks to persistence)
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Create a new user document after first sign-in
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  /// Update just the role field after role selection
  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save employer profile fields directly on user doc (1 write, 0 extra reads)
  Future<void> saveEmployerProfile(EmployerProfileModel profile) async {
    await _db.collection('users').doc(profile.uid).update({
      'displayName': profile.username,
      'username': profile.username,
      'realName': profile.realName,
      'state': profile.state,
      'city': profile.city,
      'workCategory': profile.workCategory,
      'requiredSkills': profile.requiredSkills,
      'scheduleType': profile.scheduleType,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save a verified phone number to the user doc
  Future<void> updateUserPhone(String uid, String phone) async {
    await _db.collection('users').doc(uid).update({
      'phoneNumber': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reset user role (so they can re-pick helper/employer)
  Future<void> resetUserRole(String uid) async {
    await _db.collection('users').doc(uid).update({
      'role': null,
      'profileComplete': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save the user's chosen avatar index
  Future<void> updateUserAvatar(String uid, int avatarIndex) async {
    await _db.collection('users').doc(uid).update({
      'avatarIndex': avatarIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update editable employer work preferences
  Future<void> updateEmployerWorkPreferences(
    String uid, {
    required String workCategory,
    required List<String> requiredSkills,
    required String scheduleType,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCategory': workCategory,
      'requiredSkills': requiredSkills,
      'scheduleType': scheduleType,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Persist the employer's last selected mode ('oneDay' or 'termBased')
  Future<void> updateEmployerLastMode(String uid, String lastMode) async {
    await _db.collection('users').doc(uid).update({
      'lastMode': lastMode,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark that the employer has seen the home-screen tutorial
  Future<void> markEmployerTutorialSeen(String uid) async {
    await _db.collection('users').doc(uid).update({
      'hasSeenTutorial': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Persist one-day search preferences (skill, city, date, timing)
  Future<void> updateOneDayPrefs(String uid, Map<String, dynamic> prefs) async {
    await _db.collection('users').doc(uid).update({
      'oneDayPrefs': prefs,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch helpers matching skill + city for one-day mode.
  /// Runs two queries (workCities array + legacy city field), deduplicates,
  /// then client-side filters by skill and excludes underage helpers.
  Future<List<Map<String, dynamic>>> getOneDayHelpers({
    required String skill,
    required String city,
  }) async {
    final baseQuery = _db
        .collection('users')
        .where('role', isEqualTo: 'helper')
        .where('profileComplete', isEqualTo: true);

    final snapshots = await Future.wait([
      baseQuery.where('workCities', arrayContains: city).get(),
      baseQuery.where('city', isEqualTo: city).get(),
    ]);

    // Merge and deduplicate by doc ID
    final seen = <String>{};
    final merged = <Map<String, dynamic>>[];
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (seen.add(doc.id)) {
          merged.add(doc.data());
        }
      }
    }

    // Exclude underage helpers, require one_day schedule, and filter by skill
    return merged.where((h) {
      if (h['isUnderage'] == true) return false;
      final scheduleTypes = List<String>.from(h['scheduleTypes'] ?? []);
      if (!scheduleTypes.contains('one_day')) return false;
      final skills = List<String>.from(h['skills'] ?? []);
      return skills.contains(skill);
    }).toList();
  }

  /// Persist the employer's skill filter selection and active category
  Future<void> updateEmployerSavedFilters(
    String uid, {
    required String category,
    required List<String> skills,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCategory': category,
      'savedFilters': {
        'category': category,
        'skills': skills,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update the employer's active category and required skills atomically
  /// (called when switching categories from the home screen)
  Future<void> updateEmployerCategoryAndSkills(
    String uid, {
    required String workCategory,
    required List<String> requiredSkills,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCategory': workCategory,
      'requiredSkills': requiredSkills,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update editable helper profile fields (cities, schedule)
  Future<void> updateHelperProfile(
    String uid, {
    required List<String> workCities,
    required List<String> scheduleTypes,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCities': workCities,
      'city': workCities.isNotEmpty ? workCities.first : '',
      'scheduleTypes': scheduleTypes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Flag a helper account as underage — restricts visibility in search results
  Future<void> flagHelperAsUnderage(String uid, {required int age}) async {
    await _db.collection('users').doc(uid).update({
      'isUnderage': true,
      'age': age,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save Aadhaar verification result — stores only age and masked UID
  Future<void> saveHelperVerification(
    String uid, {
    required int? age,
    required String maskedUid,
  }) async {
    await _db.collection('users').doc(uid).update({
      'age': age,
      'maskedUid': maskedUid,
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update the employer's active city (persists browse-city changes to Firestore)
  Future<void> updateEmployerCity(String uid, String city) async {
    await _db.collection('users').doc(uid).update({
      'city': city,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update the employer's active work category
  Future<void> updateEmployerWorkCategory(String uid, String workCategory) async {
    await _db.collection('users').doc(uid).update({
      'workCategory': workCategory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save helper profile fields directly on user doc
  Future<void> saveHelperProfile(HelperProfileModel profile) async {
    await _db.collection('users').doc(profile.uid).update({
      'displayName': profile.fullName,
      'fullName': profile.fullName,
      'state': profile.state,
      'city': profile.city,
      'skills': profile.skills,
      'yearsOfExperience': profile.yearsOfExperience,
      'scheduleTypes': profile.scheduleTypes,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
