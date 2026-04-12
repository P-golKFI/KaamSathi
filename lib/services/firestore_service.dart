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
      'workSpecification': profile.workSpecification,
      'scheduleType': profile.scheduleType,
      'hoursPerDay': profile.hoursPerDay,
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
    required String workSpecification,
    required String scheduleType,
    int? hoursPerDay,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCategory': workCategory,
      'workSpecification': workSpecification,
      'scheduleType': scheduleType,
      'hoursPerDay': hoursPerDay,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update editable helper profile fields (cities, schedule)
  Future<void> updateHelperProfile(
    String uid, {
    required List<String> workCities,
    required String scheduleType,
    int? hoursPerDay,
  }) async {
    await _db.collection('users').doc(uid).update({
      'workCities': workCities,
      'city': workCities.isNotEmpty ? workCities.first : '',
      'scheduleType': scheduleType,
      'hoursPerDay': hoursPerDay,
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

  /// Save helper profile fields directly on user doc
  Future<void> saveHelperProfile(HelperProfileModel profile) async {
    await _db.collection('users').doc(profile.uid).update({
      'displayName': profile.fullName,
      'fullName': profile.fullName,
      'state': profile.state,
      'city': profile.city,
      'skills': profile.skills,
      'yearsOfExperience': profile.yearsOfExperience,
      'hoursPerDay': profile.hoursPerDay,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
