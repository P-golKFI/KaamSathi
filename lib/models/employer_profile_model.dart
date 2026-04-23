import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> indianStates = [
  'Andaman and Nicobar Islands',
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Lakshadweep',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const List<Map<String, String>> workCategories = [
  {
    'value': 'domestic_help',
    'label': 'Domestic Help',
    'examples': 'cooking, cleaning, laundry, ironing, babysitting, elderly care',
  },
  {
    'value': 'skilled_labor',
    'label': 'Skilled Labor',
    'examples': 'plumbing, electrical, carpentry, painting, AC repair',
  },
  {
    'value': 'commercial',
    'label': 'Commercial / Business',
    'examples': 'security guard, tailoring, beauty services, vehicle washing',
  },
  {
    'value': 'other',
    'label': 'Other',
    'examples': 'describe your requirement below',
  },
];

/// Maps employer work categories to matching helper skills
const Map<String, List<String>> categoryToSkills = {
  'domestic_help': [
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
    'Babysitting',
    'Nanny',
    'Child Care',
    'School Drop & Pick-up',
    'Home Tutoring',
    'Elderly Care',
    'Patient Care',
    'Nursing Assistance',
    'Dog Walking',
    'Personal Assistant',
  ],
  'skilled_labor': [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Wall Whitewashing',
    'AC Repair',
    'Appliance Repair',
    'Water Tank Cleaning',
    'Gardening',
    'Plant Care',
  ],
  'commercial': [
    'Security Guard',
    'Night Watchman',
    'Tailoring',
    'Hair Cutting',
    'Mehndi',
    'Beauty Services',
    'Massage at Home',
    'Yoga Instructor',
    'Fitness Trainer',
    'Vehicle Washing',
  ],
  'drivers': [
    'Driving',
    'Chauffeur Service',
  ],
};

/// Get the display label for a category value
String getCategoryLabel(String value) {
  for (final cat in workCategories) {
    if (cat['value'] == value) return cat['label']!;
  }
  return value;
}

class EmployerProfileModel {
  final String uid;
  final String username;
  final String realName;
  final String state;
  final String city;
  final String workCategory;
  final List<String> requiredSkills;
  final String scheduleType; // "full_time" | "hourly"
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployerProfileModel({
    required this.uid,
    required this.username,
    required this.realName,
    required this.state,
    required this.city,
    required this.workCategory,
    required this.requiredSkills,
    required this.scheduleType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployerProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployerProfileModel(
      uid: data['uid'] ?? doc.id,
      username: data['username'] ?? '',
      realName: data['realName'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      workCategory: data['workCategory'] ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      scheduleType: data['scheduleType'] ?? 'full_time',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'realName': realName,
      'state': state,
      'city': city,
      'workCategory': workCategory,
      'requiredSkills': requiredSkills,
      'scheduleType': scheduleType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
