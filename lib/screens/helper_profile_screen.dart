import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import '../data/indian_cities.dart';
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import 'avatar_selection_screen.dart';

class HelperProfileScreen extends StatefulWidget {
  const HelperProfileScreen({super.key});

  @override
  State<HelperProfileScreen> createState() => _HelperProfileScreenState();
}

class _HelperProfileScreenState extends State<HelperProfileScreen> {
  // Loaded values (to detect changes)
  List<String> _loadedWorkCities = [];
  List<String> _loadedScheduleTypes = ['daily'];

  // Editable state
  List<String> _workCities = [];
  List<String> _scheduleTypes = ['daily'];
  bool _isDirty = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Read-only display
  String _fullName = '';
  String _state = '';
  List<String> _skills = [];
  int _yearsOfExperience = 0;
  int? _avatarIndex;
  bool _isVerified = false;
  String? _maskedUid;

  // City search
  final _citySearchController = TextEditingController();
  List<String> _citySuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data()!;

      final rawWorkCities = List<String>.from(data['workCities'] ?? []);
      final city = data['city'] ?? '';
      final workCities = rawWorkCities.isNotEmpty
          ? rawWorkCities
          : (city.isNotEmpty ? [city] : <String>[]);

      final scheduleTypes = data['scheduleTypes'] != null
          ? List<String>.from(data['scheduleTypes'])
          : ['daily'];

      setState(() {
        _fullName = data['fullName'] ?? '';
        _state = data['state'] ?? '';
        _skills = List<String>.from(data['skills'] ?? []);
        _yearsOfExperience = data['yearsOfExperience'] ?? 0;
        _avatarIndex = data['avatarIndex'] as int?;
        _isVerified = data['isVerified'] as bool? ?? false;
        _maskedUid = data['maskedUid'] as String?;

        _loadedWorkCities = List<String>.from(workCities);
        _loadedScheduleTypes = List<String>.from(scheduleTypes);

        _workCities = List<String>.from(workCities);
        _scheduleTypes = List<String>.from(scheduleTypes);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading helper profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkDirty() {
    final citiesChanged = _workCities.length != _loadedWorkCities.length ||
        !_workCities.every(_loadedWorkCities.contains);
    final dirty = citiesChanged ||
        !listEquals(_scheduleTypes, _loadedScheduleTypes);
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  Future<void> _save() async {
    if (!_isDirty || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirestoreService().updateHelperProfile(
        uid,
        workCities: _workCities,
        scheduleTypes: _scheduleTypes,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving helper profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToSave)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text(AppLocalizations.of(context)!.myProfile),
        actions: [
          TextButton(
            onPressed: (_isDirty && !_isSaving) ? _save : null,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(
                      color: (_isDirty && !_isSaving)
                          ? Colors.white
                          : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        _buildAvatar(),
        const SizedBox(height: 28),
        _buildSectionLabel(l.sectionAccount),
        _buildReadOnlyCard([
          _buildReadOnlyRow(l.labelFullName, _fullName),
        ]),
        const SizedBox(height: 20),
        _buildSectionLabel(l.sectionLocation),
        _buildReadOnlyCard([
          _buildReadOnlyRow(l.labelState, _state),
        ]),
        const SizedBox(height: 20),
        _buildSectionLabel(l.sectionSkills),
        _buildSkillsCard(),
        const SizedBox(height: 20),
        _buildSectionLabel(l.sectionExperience),
        _buildReadOnlyCard([
          _buildReadOnlyRow(
            l.labelExperience,
            '$_yearsOfExperience ${_yearsOfExperience == 1 ? l.yearSingular : l.yearPlural}',
          ),
        ]),
        const SizedBox(height: 20),
        _buildSectionLabel(l.sectionAvailability),
        _buildAvailabilityCard(),
        const SizedBox(height: 20),
        _buildSectionLabel(l.sectionWorkCities),
        _buildWorkCitiesCard(),
        const SizedBox(height: 20),
        _buildSectionLabel('VERIFICATION'),
        _buildVerificationCard(),
      ],
    );
  }

  Widget _buildAvatar() {
    final hasAvatar = _avatarIndex != null &&
        _avatarIndex! >= 0 &&
        _avatarIndex! < kHelperAvatars.length;

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasAvatar
              ? kHelperAvatars[_avatarIndex!].$2
              : AppColors.navyBlue.withValues(alpha: 0.15),
        ),
        child: Center(
          child: hasAvatar
              ? Text(
                  kHelperAvatars[_avatarIndex!].$1,
                  style: const TextStyle(fontSize: 38),
                )
              : const Icon(
                  Icons.person,
                  size: 44,
                  color: AppColors.navyBlue,
                ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildReadOnlyCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.navyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: _skills.isEmpty
          ? const Text('—', style: TextStyle(color: AppColors.textGrey))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.3)),
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
    );
  }

  Widget _buildAvailabilityCard() {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _availabilityChip('liveIn', 'Live-in',
                  "Full-day work at the employer's home"),
              _availabilityChip('daily', 'Daily (come and go)',
                  'Come for fixed hours every day, like morning to evening'),
              _availabilityChip('oneTime', 'One-time / per-visit',
                  'Single jobs, events, or occasional visits'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _availabilityChip(String value, String label, String description) {
    final selected = _scheduleTypes.contains(value);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (on) {
        setState(() {
          if (on) {
            _scheduleTypes.add(value);
          } else {
            _scheduleTypes.remove(value);
          }
        });
        _checkDirty();
      },
      tooltip: description,
      selectedColor: AppColors.teal,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.navyBlue,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.teal : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: _isVerified ? _buildVerifiedState() : _buildUnverifiedState(),
    );
  }

  Widget _buildVerifiedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF22C55E), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Aadhaar Verified',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        if (_maskedUid != null) ...[
          const SizedBox(height: 8),
          Text(
            'Aadhaar: $_maskedUid',
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ],
    );
  }

  Widget _buildUnverifiedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline,
                color: AppColors.textGrey.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Not Verified',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Verify with your Aadhaar to get a badge next to your name, so employers know you\'re real.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        GradientButton(
          text: 'Verify with Aadhaar QR',
          onPressed: () async {
            final verified = await Navigator.pushNamed(
              context,
              '/aadhaar-verify',
            );
            if (verified == true) _loadProfile();
          },
        ),
      ],
    );
  }

  Widget _buildWorkCitiesCard() {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected city chips
          if (_workCities.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _workCities.map((city) {
                return Chip(
                  label: Text(city),
                  onDeleted: () {
                    setState(() => _workCities.remove(city));
                    _checkDirty();
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                  labelStyle: const TextStyle(
                    color: AppColors.navyBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  deleteIconColor: AppColors.navyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppColors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          // City search field
          TextField(
            controller: _citySearchController,
            style: const TextStyle(fontSize: 14, color: AppColors.navyBlue),
            decoration: InputDecoration(
              hintText: l.searchCity,
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.location_on_outlined,
                  color: AppColors.teal, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.teal),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _citySuggestions = searchCities(value, state: _state);
              });
            },
          ),
          // Suggestions dropdown
          if (_citySuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _citySuggestions.length,
                itemBuilder: (context, index) {
                  final city = _citySuggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city_outlined,
                        color: AppColors.teal, size: 18),
                    title: Text(
                      city,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.navyBlue),
                    ),
                    dense: true,
                    onTap: () {
                      setState(() {
                        if (!_workCities.contains(city)) {
                          _workCities.add(city);
                        }
                        _citySuggestions = [];
                        _citySearchController.clear();
                      });
                      _checkDirty();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
