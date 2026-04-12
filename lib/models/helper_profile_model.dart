import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> predefinedSkills = [
  'Cooking',
  'Cleaning',
  'Babysitting',
  'Elderly Care',
  'Plumbing',
  'Electrical',
  'Carpentry',
  'Painting',
  'Gardening',
  'Driving',
  'Security',
  'Tailoring',
];

class HelperProfileModel {
  final String uid;
  final String fullName;
  final String state;
  final String city;
  final List<String> workCities;
  final List<String> skills;
  final int yearsOfExperience;
  final String scheduleType;
  final int? hoursPerDay;
  final int? age;
  final String? maskedUid;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  HelperProfileModel({
    required this.uid,
    required this.fullName,
    required this.state,
    required this.city,
    required this.workCities,
    required this.skills,
    required this.yearsOfExperience,
    required this.scheduleType,
    this.hoursPerDay,
    this.age,
    this.maskedUid,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HelperProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final city = data['city'] ?? '';
    final rawWorkCities = List<String>.from(data['workCities'] ?? []);
    final List<String> workCities = rawWorkCities.isNotEmpty
        ? rawWorkCities
        : (city.isNotEmpty ? [city] : <String>[]);
    return HelperProfileModel(
      uid: data['uid'] ?? doc.id,
      fullName: data['fullName'] ?? '',
      state: data['state'] ?? '',
      city: city,
      workCities: workCities,
      skills: List<String>.from(data['skills'] ?? []),
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      scheduleType: data['scheduleType'] ?? 'full_time',
      hoursPerDay: data['hoursPerDay'],
      age: data['age'] as int?,
      maskedUid: data['maskedUid'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'state': state,
      'city': workCities.isNotEmpty ? workCities.first : city,
      'workCities': workCities,
      'skills': skills,
      'yearsOfExperience': yearsOfExperience,
      'scheduleType': scheduleType,
      'hoursPerDay': hoursPerDay,
      'age': age,
      'maskedUid': maskedUid,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
