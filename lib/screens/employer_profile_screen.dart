import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employer_profile_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import 'avatar_selection_screen.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  // Loaded values (to detect changes)
  String _loadedWorkCategory = '';
  List<String> _loadedRequiredSkills = [];
  String _loadedScheduleType = 'full_time';

  // Editable state
  String _workCategory = '';
  List<String> _requiredSkills = [];
  String _scheduleType = 'full_time';
  bool _isDirty = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Read-only display
  String _displayName = '';
  String _realName = '';
  String _state = '';
  String _city = '';
  int? _avatarIndex;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data()!;

      final workCategory = data['workCategory'] ?? 'other';
      final savedFilters = data['savedFilters'] as Map<String, dynamic>?;
      final requiredSkills = List<String>.from(
        savedFilters?['skills'] ?? data['requiredSkills'] ?? [],
      );
      final scheduleType = data['scheduleType'] ?? 'full_time';

      setState(() {
        _displayName = data['displayName'] ?? data['username'] ?? '';
        _realName = data['realName'] ?? '';
        _state = data['state'] ?? '';
        _city = data['city'] ?? '';
        _avatarIndex = data['avatarIndex'] as int?;

        _loadedWorkCategory = workCategory;
        _loadedRequiredSkills = requiredSkills;
        _loadedScheduleType = scheduleType;

        _workCategory = workCategory;
        _requiredSkills = List.from(requiredSkills);
        _scheduleType = scheduleType;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading employer profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkDirty() {
    final skillsChanged = _requiredSkills.length != _loadedRequiredSkills.length ||
        !_requiredSkills.every(_loadedRequiredSkills.contains);
    final dirty = _workCategory != _loadedWorkCategory ||
        skillsChanged ||
        _scheduleType != _loadedScheduleType;
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  Future<void> _save() async {
    if (!_isDirty || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await Future.wait([
        FirestoreService().updateEmployerWorkPreferences(
          uid,
          workCategory: _workCategory,
          requiredSkills: _requiredSkills,
          scheduleType: _scheduleType,
        ),
        FirestoreService().updateEmployerSavedFilters(
          uid,
          category: _workCategory,
          skills: _requiredSkills,
        ),
      ]);
      if (mounted) {
        widget.onSaved != null ? widget.onSaved!() : Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
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
        title: const Text('My Profile'),
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
                    'Save',
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        _buildAvatar(),
        const SizedBox(height: 28),
        _buildSectionLabel('ACCOUNT'),
        _buildReadOnlyCard([
          _buildReadOnlyRow('Display Name', _displayName),
          const Divider(height: 1),
          _buildReadOnlyRow('Real Name', _realName),
        ]),
        const SizedBox(height: 20),
        _buildSectionLabel('LOCATION'),
        _buildReadOnlyCard([
          _buildReadOnlyRow('State', _state),
          const Divider(height: 1),
          _buildReadOnlyRow('City', _city),
        ]),
        const SizedBox(height: 20),
        _buildSectionLabel('WORK PREFERENCES'),
        _buildEditablePreferencesCard(),
        const SizedBox(height: 20),
        _buildSectionLabel('REQUIRED SKILLS'),
        _buildRequiredSkillsCard(),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Sign Out',
              style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red.shade200),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/phone-login', (_) => false);
    }
  }

  Widget _buildAvatar() {
    final hasAvatar = _avatarIndex != null &&
        _avatarIndex! >= 0 &&
        _avatarIndex! < kEmployerAvatars.length;

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasAvatar
              ? kEmployerAvatars[_avatarIndex!].$2
              : AppColors.navyBlue.withValues(alpha: 0.15),
        ),
        child: Center(
          child: hasAvatar
              ? Text(
                  kEmployerAvatars[_avatarIndex!].$1,
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
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

  Widget _buildEditablePreferencesCard() {
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
          // Work category dropdown
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Looking for',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _workCategory.isEmpty ? null : _workCategory,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                  items: workCategories
                      .map((cat) => DropdownMenuItem(
                            value: cat['value'],
                            child: Text(
                              cat['label']!,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.navyBlue),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _workCategory = val;
                        _requiredSkills = [];
                      });
                      _checkDirty();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Schedule type toggle
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Schedule',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _scheduleChip('Full-time', 'full_time'),
                    const SizedBox(width: 8),
                    _scheduleChip('Hourly', 'hourly'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleChip(String label, String value) {
    final isSelected = _scheduleType == value;
    return GestureDetector(
      onTap: () {
        setState(() => _scheduleType = value);
        _checkDirty();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredSkillsCard() {
    final categorySkills = categoryToSkills[_workCategory];
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
          Row(
            children: [
              const Text(
                'Skills needed',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const Spacer(),
              if (categorySkills != null)
                TextButton(
                  onPressed: _showSkillsEditor,
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: AppColors.teal, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_requiredSkills.isEmpty)
            Text(
              categorySkills == null
                  ? 'All helpers in this category'
                  : 'All ${getCategoryLabel(_workCategory)} helpers',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.navyBlue,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _requiredSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _showSkillsEditor() async {
    final allSkills = categoryToSkills[_workCategory];
    if (allSkills == null) return;

    Set<String> sheetSelected = Set.from(_requiredSkills);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                      child: Row(
                        children: [
                          const Text(
                            'Skills Needed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                if (sheetSelected.length == allSkills.length) {
                                  sheetSelected = {};
                                } else {
                                  sheetSelected = Set.from(allSkills);
                                }
                              });
                            },
                            child: Text(
                              sheetSelected.length == allSkills.length
                                  ? 'Clear All'
                                  : 'Select All',
                              style: const TextStyle(color: AppColors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Leave blank to match all helpers in this category',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: allSkills.map((skill) {
                              final selected = sheetSelected.contains(skill);
                              return FilterChip(
                                label: Text(skill),
                                selected: selected,
                                onSelected: (val) {
                                  setSheetState(() {
                                    if (val) {
                                      sheetSelected.add(skill);
                                    } else {
                                      sheetSelected.remove(skill);
                                    }
                                  });
                                },
                                selectedColor: AppColors.teal.withValues(alpha: 0.15),
                                checkmarkColor: AppColors.teal,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: selected ? AppColors.teal : AppColors.navyBlue,
                                ),
                                side: BorderSide(
                                  color: selected ? AppColors.teal : Colors.grey.shade300,
                                ),
                                backgroundColor: Colors.white,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            final skills = sheetSelected.toList();
                            setState(() {
                              _requiredSkills = skills;
                            });
                            _checkDirty();
                            // Persist to savedFilters immediately so home screen stays in sync
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              FirestoreService().updateEmployerSavedFilters(
                                uid,
                                category: _workCategory,
                                skills: skills,
                              );
                            }
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
