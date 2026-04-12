import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../data/indian_cities.dart';
import '../models/employer_profile_model.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/profanity_filter.dart';
import '../widgets/gradient_button.dart';

class EmployerProfileSetupScreen extends StatefulWidget {
  const EmployerProfileSetupScreen({super.key});

  @override
  State<EmployerProfileSetupScreen> createState() =>
      _EmployerProfileSetupScreenState();
}

class _EmployerProfileSetupScreenState
    extends State<EmployerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _workSpecController = TextEditingController();
  final _hoursController = TextEditingController();

  String? _selectedState;
  String? _selectedCategory;
  String _scheduleType = 'full_time';
  List<String> _citySuggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _realNameController.dispose();
    _cityController.dispose();
    _workSpecController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final profile = EmployerProfileModel(
        uid: uid,
        username: _usernameController.text.trim(),
        realName: _realNameController.text.trim(),
        state: _selectedState!,
        city: _cityController.text.trim(),
        workCategory: _selectedCategory!,
        workSpecification: _workSpecController.text.trim(),
        scheduleType: _scheduleType,
        hoursPerDay: _scheduleType == 'hourly'
            ? int.parse(_hoursController.text.trim())
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService().saveEmployerProfile(profile);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/avatar-selection', (_) => false,
          arguments: 'employer');
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'Kaam Sathi',
                        style: TextStyle(
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
                        const Text(
                          'Set Up Your Profile',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us about yourself and what help you need',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Username
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: 'Choose a username',
                            prefixIcon: Icons.person_outline,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Username is required';
                            }
                            if (v.trim().length < 3) {
                              return 'At least 3 characters';
                            }
                            if (containsProfanity(v)) {
                              return 'Please choose an appropriate username';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 6, bottom: 20),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined,
                                  size: 14,
                                  color: AppColors.teal.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              const Text(
                                'This will be shown publicly',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),

                        // Real Name
                        TextFormField(
                          controller: _realNameController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: 'Your full name',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (containsProfanity(v)) {
                              return 'Please enter an appropriate name';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 6, bottom: 20),
                          child: Row(
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 14,
                                  color: AppColors.teal.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              const Text(
                                'Private — only visible to you',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),

                        // State dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: AppDecorations.styledInput(
                            hint: 'Select your state',
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
                            setState(() => _selectedState = value);
                          },
                          validator: (v) {
                            if (v == null) return 'Please select your state';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // City / area with autocomplete
                        TextFormField(
                          controller: _cityController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          decoration: AppDecorations.styledInput(
                            hint: 'City or area',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _citySuggestions = searchCities(value);
                            });
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'City is required';
                            }
                            if (!indianCities.contains(v.trim())) {
                              return 'Please select a valid city from the list';
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
                                      _cityController.text = city;
                                      _citySuggestions = [];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Work Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: AppDecorations.styledInput(
                            hint: 'Select work category',
                            prefixIcon: Icons.work_outline,
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textGrey),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.navyBlue,
                          ),
                          menuMaxHeight: 350,
                          items: workCategories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['value'],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat['label']!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat['examples']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (context) {
                            return workCategories.map((cat) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  cat['label']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.navyBlue,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                          },
                          validator: (v) {
                            if (v == null) return 'Please select a category';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Work Specification (appears after category is selected)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _selectedCategory != null
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _workSpecController,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.navyBlue,
                                      ),
                                      decoration: AppDecorations.styledInput(
                                        hint:
                                            'Describe the exact work you need',
                                        prefixIcon: Icons.edit_note,
                                      ),
                                      validator: (v) {
                                        if (_selectedCategory != null &&
                                            (v == null ||
                                                v.trim().isEmpty)) {
                                          return 'Please describe the work';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Schedule section label
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
                            const Text(
                              'Work Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Schedule toggle
                        Row(
                          children: [
                            _buildScheduleChip(
                              label: 'Full-time',
                              icon: Icons.access_time_filled,
                              isSelected: _scheduleType == 'full_time',
                              onTap: () =>
                                  setState(() => _scheduleType = 'full_time'),
                            ),
                            const SizedBox(width: 12),
                            _buildScheduleChip(
                              label: 'Hourly',
                              icon: Icons.schedule,
                              isSelected: _scheduleType == 'hourly',
                              onTap: () =>
                                  setState(() => _scheduleType = 'hourly'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Hours per day (only when hourly)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _scheduleType == 'hourly'
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _hoursController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.navyBlue,
                                      ),
                                      decoration: AppDecorations.styledInput(
                                        hint: 'Hours per day (e.g. 4)',
                                        prefixIcon: Icons.timelapse,
                                      ),
                                      validator: (v) {
                                        if (_scheduleType != 'hourly') {
                                          return null;
                                        }
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Please enter hours per day';
                                        }
                                        final hours = int.tryParse(v.trim());
                                        if (hours == null ||
                                            hours < 1 ||
                                            hours > 24) {
                                          return 'Enter a number between 1 and 24';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

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
                              const Expanded(
                                child: Text(
                                  'Your phone number and real name are always kept private',
                                  style: TextStyle(
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
                          text: 'Complete Setup',
                          gradient: AppGradients.orangeButtonGradient,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submit,
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
                            label: const Text(
                              'Change Role',
                              style: TextStyle(
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

  Widget _buildScheduleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.teal : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.teal : Colors.grey.shade200,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
