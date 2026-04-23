import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../data/indian_cities.dart';
import '../l10n/app_localizations.dart';
import '../models/helper_profile_model.dart';
import '../providers/auth_provider.dart' as app;
import '../models/employer_profile_model.dart' show indianStates;
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/profanity_filter.dart';
import '../widgets/gradient_button.dart';

class HelperProfileSetupScreen extends StatefulWidget {
  const HelperProfileSetupScreen({super.key});

  @override
  State<HelperProfileSetupScreen> createState() =>
      _HelperProfileSetupScreenState();
}

class _HelperProfileSetupScreenState extends State<HelperProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _citySearchController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _selectedState;
  List<String> _scheduleTypes = ['full_time'];
  final Set<String> _selectedSkills = {};
  final List<String> _selectedCities = [];
  List<String> _citySuggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _citySearchController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.skillsRequired)),
      );
      return;
    }

    if (_scheduleTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one work type')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final dl = AppLocalizations.of(ctx)!;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              dl.confirmYourSkills,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dl.selectedSkillsLabel,
              style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dl.skillsLockedWarning,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              dl.goBack,
              style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(dl.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        );
      },
    );

    if (confirmed != true) return;
    await _submit();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final profile = HelperProfileModel(
        uid: uid,
        fullName: _nameController.text.trim(),
        state: _selectedState!,
        city: _selectedCities.isNotEmpty ? _selectedCities.first : '',
        workCities: _selectedCities,
        skills: _selectedSkills.toList(),
        yearsOfExperience: int.parse(_experienceController.text.trim()),
        scheduleTypes: _scheduleTypes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService().saveHelperProfile(profile);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/avatar-selection', (_) => false,
          arguments: 'helper');
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.somethingWentWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top section with logo and title
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // White card section with form
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section header
                        Text(
                          l.profileSetup,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.profileSetupSubtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: l.fullNameHint,
                            prefixIcon: Icons.person_outline,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.nameRequired;
                            }
                            if (containsProfanity(v)) {
                              return l.inappropriateName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // State dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: AppDecorations.styledInput(
                            hint: l.selectStateHint,
                            prefixIcon: Icons.map_outlined,
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textGrey),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          menuMaxHeight: 300,
                          items: indianStates.map((state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedState = value;
                              _selectedCities.clear();
                              _citySuggestions = [];
                              _citySearchController.clear();
                            });
                          },
                          validator: (v) {
                            if (v == null) return l.stateRequired;
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Cities section label
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
                            const SizedBox(width: 10),
                            Text(
                              l.citiesYouCanWorkIn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Selected city chips
                        if (_selectedCities.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedCities.map((city) {
                              return Chip(
                                label: Text(city),
                                onDeleted: () =>
                                    setState(() => _selectedCities.remove(city)),
                                deleteIcon:
                                    const Icon(Icons.close, size: 16),
                                backgroundColor:
                                    AppColors.teal.withValues(alpha: 0.12),
                                labelStyle: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                deleteIconColor: AppColors.navyBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppColors.teal
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // City search input
                        TextFormField(
                          controller: _citySearchController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: l.searchCity,
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _citySuggestions = searchCities(value, state: _selectedState);
                            });
                          },
                          validator: (_) {
                            if (_selectedCities.isEmpty) {
                              return l.citiesRequired;
                            }
                            return null;
                          },
                        ),

                        // City suggestions dropdown
                        if (_citySuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade200),
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
                                  leading: const Icon(
                                    Icons.location_city_outlined,
                                    color: AppColors.teal,
                                    size: 18,
                                  ),
                                  title: Text(
                                    city,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.navyBlue,
                                    ),
                                  ),
                                  dense: true,
                                  onTap: () {
                                    setState(() {
                                      if (!_selectedCities.contains(city)) {
                                        _selectedCities.add(city);
                                      }
                                      _citySuggestions = [];
                                      _citySearchController.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Skills section label
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
                            const SizedBox(width: 10),
                            Text(
                              l.yourSkills,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Skills chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: predefinedSkills.map((skill) {
                            final isSelected = _selectedSkills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedSkills.add(skill);
                                  } else {
                                    _selectedSkills.remove(skill);
                                  }
                                });
                              },
                              selectedColor: AppColors.teal,
                              checkmarkColor: Colors.white,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : AppColors.navyBlue,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.teal
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Years of Experience
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: l.yearsOfExperienceHint,
                            prefixIcon: Icons.work_history_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l.experienceRequired;
                            }
                            final years = int.tryParse(v.trim());
                            if (years == null || years < 0 || years > 50) {
                              return l.experienceRange;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Availability section label
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
                            const SizedBox(width: 10),
                            Text(
                              l.availability,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Availability multi-select
                        Text(
                          'What kind of work are you open to?',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _availabilityChip('full_time', 'Full-time',
                                'Regular long-term work, fixed salary'),
                            _availabilityChip('hourly', 'Hourly',
                                'Come for fixed hours, paid by the hour'),
                            _availabilityChip('one_day', 'One-day / per-visit',
                                'Single jobs, events, or occasional visits'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select all that apply — most workers are open to more than one',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),

                        // Privacy notice
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.teal.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined,
                                  size: 20,
                                  color:
                                      AppColors.teal.withValues(alpha: 0.8)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l.phonePrivate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Submit button
                        GradientButton(
                          text: l.completeSetup,
                          gradient: AppGradients.orangeButtonGradient,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _confirmAndSubmit,
                        ),
                        const SizedBox(height: 16),

                        // Change role button
                        Center(
                          child: TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    await context
                                        .read<app.AuthProvider>()
                                        .resetRole();
                                    if (!context.mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/role-selection',
                                      (_) => false,
                                    );
                                  },
                            icon: const Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: AppColors.teal,
                            ),
                            label: Text(
                              l.changeRole,
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
