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
    'examples': 'cooking, cleaning, babysitting, elderly care',
  },
  {
    'value': 'skilled_labor',
    'label': 'Skilled Labor',
    'examples': 'plumbing, electrical, carpentry, painting',
  },
  {
    'value': 'commercial',
    'label': 'Commercial / Business',
    'examples': 'shop assistant, delivery, warehouse, security',
  },
  {
    'value': 'other',
    'label': 'Other',
    'examples': 'describe your requirement below',
  },
];

/// Maps employer work categories to matching helper skills
const Map<String, List<String>> categoryToSkills = {
  'domestic_help': ['Cooking', 'Cleaning', 'Babysitting', 'Elderly Care'],
  'skilled_labor': ['Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Gardening'],
  'commercial': ['Security', 'Driving', 'Tailoring'],
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
  final String workSpecification;
  final String scheduleType; // "full_time" | "hourly"
  final int? hoursPerDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployerProfileModel({
    required this.uid,
    required this.username,
    required this.realName,
    required this.state,
    required this.city,
    required this.workCategory,
    required this.workSpecification,
    required this.scheduleType,
    this.hoursPerDay,
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
      workSpecification: data['workSpecification'] ?? '',
      scheduleType: data['scheduleType'] ?? 'full_time',
      hoursPerDay: data['hoursPerDay'],
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
      'workSpecification': workSpecification,
      'scheduleType': scheduleType,
      'hoursPerDay': hoursPerDay,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
