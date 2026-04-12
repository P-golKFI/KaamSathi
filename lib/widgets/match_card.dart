import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/employer_profile_model.dart';
import '../theme/app_colors.dart';
import '../screens/avatar_selection_screen.dart';

/// Card showing a helper's profile (displayed to employers)
class HelperMatchCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const HelperMatchCard({super.key, required this.data});

  /// Determine which category a helper's skills belong to
  String _getCategory(List<String> skills) {
    for (final entry in categoryToSkills.entries) {
      if (entry.value.any((s) => skills.contains(s))) {
        return getCategoryLabel(entry.key);
      }
    }
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final name = data['fullName'] ?? data['displayName'] ?? 'Helper';
    final skills = List<String>.from(data['skills'] ?? []);
    final years = data['yearsOfExperience'] ?? 0;
    final helperScheduleType = data['scheduleType'] ?? 'full_time';
    final hours = data['hoursPerDay'];
    final city = data['city'] ?? '';
    final category = _getCategory(skills);
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    final avatarIndex = data['avatarIndex'] as int?;
    final isVerified = data['isVerified'] as bool? ?? false;
    final age = data['age'] as int?;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/helper-detail', arguments: data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              if (avatarIndex != null && avatarIndex < kAvatars.length)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kAvatars[avatarIndex].$2,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      kAvatars[avatarIndex].$1,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Category label
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.verified_user,
                              size: 13, color: Color(0xFF22C55E)),
                          const SizedBox(width: 4),
                          Text(
                            age != null
                                ? 'Aadhaar Verified · Age $age'
                                : 'Aadhaar Verified',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Skills chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Experience + availability + city
                    Row(
                      children: [
                        Icon(Icons.work_history_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '$years yrs',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          helperScheduleType == 'full_time'
                              ? 'Full-time'
                              : '${hours ?? '?'} hrs/day',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            city,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card showing an employer's profile (displayed to helpers)
class EmployerMatchCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmployerMatchCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['username'] ?? data['displayName'] ?? 'Employer';
    final categoryValue = data['workCategory'] ?? '';
    final categoryLabel = getCategoryLabel(categoryValue);
    final specification = data['workSpecification'] ?? '';
    final scheduleType = data['scheduleType'] ?? 'full_time';
    final hours = data['hoursPerDay'];
    final city = data['city'] ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    final avatarIndex = data['avatarIndex'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            if (avatarIndex != null && avatarIndex < kAvatars.length)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kAvatars[avatarIndex].$2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    kAvatars[avatarIndex].$1,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Category label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      categoryLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                  if (specification.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      specification,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Schedule + city
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        scheduleType == 'full_time'
                            ? 'Full-time'
                            : '${hours ?? '?'} hrs/day',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          city,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Contact button
            GestureDetector(
              onTap: () {
                final chatArgs = {
                  'otherUserData': data,
                  'initiatorRole': 'helper',
                };
                final phone = FirebaseAuth.instance.currentUser?.phoneNumber;
                if (phone == null || phone.isEmpty) {
                  Navigator.pushNamed(context, '/add-phone', arguments: chatArgs);
                } else {
                  Navigator.pushNamed(context, '/chat', arguments: chatArgs);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: AppColors.orange,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
