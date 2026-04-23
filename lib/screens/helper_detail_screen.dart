import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employer_profile_model.dart';
import '../models/vouch_model.dart';
import '../services/vouch_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class HelperDetailScreen extends StatefulWidget {
  const HelperDetailScreen({super.key});

  @override
  State<HelperDetailScreen> createState() => _HelperDetailScreenState();
}

class _HelperDetailScreenState extends State<HelperDetailScreen> {
  Map<String, dynamic>? _data;
  bool _argsInitialized = false;

  List<VouchModel> _vouches = [];
  DocumentSnapshot? _lastVouchDoc;
  bool _isLoadingVouches = false;
  bool _hasMoreVouches = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsInitialized) {
      _data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _argsInitialized = true;
      _loadVouches();
    }
  }

  Future<void> _loadVouches() async {
    if (_isLoadingVouches || !_hasMoreVouches || _data == null) return;
    final workerId = _data!['uid'] as String?;
    if (workerId == null || workerId.isEmpty) return;
    setState(() => _isLoadingVouches = true);
    try {
      final snapshot = await VouchService().getWorkerVouchesSnapshot(
        workerId,
        startAfter: _lastVouchDoc,
      );
      final newVouches = snapshot.docs
          .map((d) => VouchModel.fromFirestore(d))
          .toList();
      if (mounted) {
        setState(() {
          _vouches.addAll(newVouches);
          if (snapshot.docs.isNotEmpty) {
            _lastVouchDoc = snapshot.docs.last;
          }
          _hasMoreVouches = newVouches.length >= 20;
          _isLoadingVouches = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingVouches = false);
    }
  }

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
    final data = _data ??
        (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);

    final name = data['fullName'] ?? data['displayName'] ?? 'Helper';
    final skills = List<String>.from(data['skills'] ?? []);
    final years = data['yearsOfExperience'] ?? 0;
    final scheduleType = data['scheduleType'] ?? 'full_time';
    final city = data['city'] ?? '';
    final state = data['state'] ?? '';
    final isVerified = data['isVerified'] as bool? ?? false;
    final age = data['age'] as int?;
    final category = _getCategory(skills);
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    final double avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0.0;
    final int vouchCount = data['vouchCount'] as int? ?? 0;

    return Scaffold(
      body: Column(
        children: [
          // Top navy gradient section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navyDark, AppColors.navyBlue],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back button row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Name + verified badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Aadhaar Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tealLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // White card section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verification status banner
                    if (isVerified)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified_user,
                                    size: 15, color: Color(0xFF16A34A)),
                                SizedBox(width: 6),
                                Text(
                                  'This worker has been verified',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                            if (age != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 21),
                                child: Text(
                                  'Age: $age years',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 15, color: Color(0xFFB45309)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'This worker\'s details have not been verified. Age has not been entered.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFB45309),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // About section
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: [city, state]
                          .where((s) => s.isNotEmpty)
                          .join(', '),
                      fallback: 'Location not specified',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.work_history_outlined,
                      text: '$years years of experience',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      icon: Icons.schedule,
                      text: scheduleType == 'full_time'
                          ? 'Available Full-time'
                          : 'Available Hourly',
                    ),

                    const SizedBox(height: 28),

                    // Skills section
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Skills',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.teal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Vouches section
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Vouches',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (vouchCount == 0 && !_isLoadingVouches)
                      Text(
                        'No vouches yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      )
                    else ...[
                      // Summary row
                      if (vouchCount > 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < avgRating.round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 16,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$vouchCount vouches',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      // Vouch list
                      ..._vouches.map((v) => _VouchTile(vouch: v)),
                      if (_isLoadingVouches)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_hasMoreVouches && !_isLoadingVouches)
                        TextButton(
                          onPressed: _loadVouches,
                          child: const Text(
                            'Load more',
                            style: TextStyle(color: AppColors.teal),
                          ),
                        ),
                    ],

                    const SizedBox(height: 36),

                    // Contact button
                    GradientButton(
                      text: 'Contact',
                      onPressed: () {
                        final chatArgs = {
                          'otherUserData': data,
                          'initiatorRole': 'employer',
                        };
                        final phone =
                            FirebaseAuth.instance.currentUser?.phoneNumber;
                        if (phone == null || phone.isEmpty) {
                          Navigator.pushNamed(context, '/add-phone',
                              arguments: chatArgs);
                        } else {
                          Navigator.pushNamed(context, '/chat',
                              arguments: chatArgs);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VouchTile extends StatelessWidget {
  final VouchModel vouch;

  const _VouchTile({required this.vouch});

  @override
  Widget build(BuildContext context) {
    final parts = vouch.employerDisplayName.trim().split(' ');
    final formattedName = parts.length > 1 && parts[1].isNotEmpty
        ? '${parts[0]} ${parts[1][0]}.'
        : parts[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < vouch.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.orange,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(vouch.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (vouch.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: vouch.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.teal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (vouch.note != null && vouch.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                vouch.note!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '— $formattedName',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? fallback;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final display = text.isEmpty ? (fallback ?? '') : text;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.teal),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            display,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
