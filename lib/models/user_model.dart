import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? phoneNumber;
  final String? email;
  final String? role; // "worker" | "employer" | null
  final String displayName;
  final bool profileComplete;
  final bool isBanned;
  final String? lastMode; // 'oneDay' | 'termBased' | null
  // Stores { skill, city, date (YYYY-MM-DD string), timing } for one-day mode
  final Map<String, dynamic>? oneDayPrefs;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    this.phoneNumber,
    this.email,
    this.role,
    this.displayName = '',
    this.profileComplete = false,
    this.isBanned = false,
    this.lastMode,
    this.oneDayPrefs,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a UserModel from a Firestore document snapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      role: data['role'],
      displayName: data['displayName'] ?? '',
      profileComplete: data['profileComplete'] ?? false,
      isBanned: data['isBanned'] ?? false,
      lastMode: data['lastMode'] as String?,
      oneDayPrefs: data['oneDayPrefs'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to a Map for writing to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'displayName': displayName,
      'profileComplete': profileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with some fields changed.
  /// Pass [clearRole] = true to explicitly set role to null.
  UserModel copyWith({
    String? role,
    bool clearRole = false,
    String? displayName,
    bool? profileComplete,
    String? lastMode,
    bool clearLastMode = false,
    Map<String, dynamic>? oneDayPrefs,
    bool clearOneDayPrefs = false,
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      email: email,
      role: clearRole ? null : (role ?? this.role),
      displayName: displayName ?? this.displayName,
      profileComplete: profileComplete ?? this.profileComplete,
      lastMode: clearLastMode ? null : (lastMode ?? this.lastMode),
      oneDayPrefs: clearOneDayPrefs ? null : (oneDayPrefs ?? this.oneDayPrefs),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
