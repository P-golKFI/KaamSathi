import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> predefinedSkills = [
  // Domestic / Household
  'Cooking',
  'Personal Chef',
  'Meal Prep & Tiffin',
  'Cleaning',
  'Sweeping & Mopping',
  'Utensil Washing',
  'Laundry',
  'Ironing',
  'Dusting',
  'Dishwashing',
  'Grocery Shopping',
  'House Sitting',

  // Child & Family Care
  'Babysitting',
  'Nanny',
  'Child Care',
  'School Drop & Pick-up',
  'Home Tutoring',

  // Elderly & Medical
  'Elderly Care',
  'Patient Care',
  'Nursing Assistance',

  // Home Maintenance
  'Plumbing',
  'Electrical',
  'Carpentry',
  'Painting',
  'Wall Whitewashing',
  'AC Repair',
  'Appliance Repair',
  'Water Tank Cleaning',

  // Quick Fixes & Handyman (one-day tasks)
  'Drilling & Wall Mounting',
  'TV Wall Mounting',
  'Furniture Assembly',
  'Curtain & Blind Fitting',
  'Shelf Installation',
  'Hanging Pictures & Wall Art',
  'Door Repair & Lock Fixing',

  // Deep Cleaning (one-day tasks)
  'Deep Cleaning',
  'Bathroom Deep Clean',
  'Kitchen Deep Clean',
  'Sofa & Carpet Cleaning',

  // Moving & Organizing (one-day tasks)
  'Moving & Packing Help',
  'Wardrobe Organization',
  'Heavy Lifting & Shifting',

  // Outdoor & Garden
  'Gardening',
  'Plant Care',
  'Vehicle Washing',

  // Driving & Transport
  'Driving',
  'Chauffeur Service',

  // Security
  'Security Guard',
  'Night Watchman',

  // Personal Services
  'Tailoring',
  'Hair Cutting',
  'Mehndi',
  'Beauty Services',
  'Massage at Home',

  // Wellness & Fitness
  'Yoga Instructor',
  'Fitness Trainer',

  // Events & Occasions (one-day tasks)
  'Event Setup & Decoration',
  'Party Helper',
  'Event Cleanup',

  // Other
  'Dog Walking',
  'Personal Assistant',
];

/// Skills shown in the one-day browse screen — covers quick tasks,
/// hourly services, and anything a person might need for a few hours.
/// Excludes ongoing-only roles like Night Watchman or Nursing Assistance.
const List<String> oneDaySkills = [
  // Quick Fixes & Handyman
  'Hanging Pictures & Wall Art',
  'Drilling & Wall Mounting',
  'TV Wall Mounting',
  'Furniture Assembly',
  'Curtain & Blind Fitting',
  'Shelf Installation',
  'Door Repair & Lock Fixing',

  // Home Maintenance
  'Plumbing',
  'Electrical',
  'Carpentry',
  'Painting',
  'Wall Whitewashing',
  'AC Repair',
  'Appliance Repair',
  'Water Tank Cleaning',

  // Cleaning
  'Cleaning',
  'Sweeping & Mopping',
  'Dusting',
  'Dishwashing',
  'Utensil Washing',
  'Deep Cleaning',
  'Bathroom Deep Clean',
  'Kitchen Deep Clean',
  'Sofa & Carpet Cleaning',

  // Moving & Organizing
  'Moving & Packing Help',
  'Wardrobe Organization',
  'Heavy Lifting & Shifting',

  // Outdoor & Garden
  'Gardening',
  'Plant Care',
  'Vehicle Washing',

  // Personal Care & Wellness
  'Hair Cutting',
  'Mehndi',
  'Beauty Services',
  'Massage at Home',
  'Yoga Instructor',
  'Fitness Trainer',

  // Events & Occasions
  'Event Setup & Decoration',
  'Party Helper',
  'Event Cleanup',

  // Care Services
  'Babysitting',
  'Child Care',
  'Elderly Care',
  'Dog Walking',

  // Household Tasks
  'Cooking',
  'Laundry',
  'Ironing',
  'Grocery Shopping',

  // Driving
  'Driving',
  'Chauffeur Service',

  // Security (events, one-day)
  'Security Guard',
];

class HelperProfileModel {
  final String uid;
  final String fullName;
  final String state;
  final String city;
  final List<String> workCities;
  final List<String> skills;
  final int yearsOfExperience;
  final List<String> scheduleTypes;
  final int? age;
  final String? maskedUid;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double avgRating;
  final int vouchCount;
  final List<String> topTags;

  HelperProfileModel({
    required this.uid,
    required this.fullName,
    required this.state,
    required this.city,
    required this.workCities,
    required this.skills,
    required this.yearsOfExperience,
    required this.scheduleTypes,
    this.age,
    this.maskedUid,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.avgRating = 0.0,
    this.vouchCount = 0,
    this.topTags = const [],
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
      scheduleTypes: data['scheduleTypes'] != null
          ? List<String>.from(data['scheduleTypes'])
          : ['daily'],
      age: data['age'] as int?,
      maskedUid: data['maskedUid'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      vouchCount: data['vouchCount'] as int? ?? 0,
      topTags: List<String>.from(data['topTags'] ?? []),
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
      'scheduleTypes': scheduleTypes,
      'age': age,
      'maskedUid': maskedUid,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
