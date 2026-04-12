import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? phoneNumber;
  final String? email;
  final String? role; // "worker" | "employer" | null
  final String displayName;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    this.phoneNumber,
    this.email,
    this.role,
    this.displayName = '',
    this.profileComplete = false,
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
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      email: email,
      role: clearRole ? null : (role ?? this.role),
      displayName: displayName ?? this.displayName,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
