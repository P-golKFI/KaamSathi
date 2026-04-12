import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employer_profile_model.dart';
import '../providers/auth_provider.dart';
import '../services/match_service.dart';
import '../theme/app_colors.dart';
import '../widgets/match_card.dart';
import '../l10n/app_localizations.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({
    super.key,
    this.browseCity,
    this.reloadTrigger,
  });

  final ValueNotifier<String?>? browseCity;
  final ValueNotifier<int>? reloadTrigger;

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  final MatchService _matchService = MatchService();

  List<Map<String, dynamic>>? _allHelpers; // raw from Firestore
  List<Map<String, dynamic>>? _helpers;   // after filters applied

  bool _isLoading = true;
  String _uid = '';
  String? _activeCategory;
  String? _userState;
  String _userCity = '';
  String? _browseCity; // null = use registered city

  // Filter state
  int? _minAge;
  int? _maxAge;
  int? _minExperience;
  bool _verifiedOnly = false;
  List<String> _selectedSkills = [];

  int get _activeFilterCount =>
      (_minAge != null ? 1 : 0) +
      (_maxAge != null ? 1 : 0) +
      (_minExperience != null && _minExperience! > 0 ? 1 : 0) +
      (_verifiedOnly ? 1 : 0) +
      (_selectedSkills.isNotEmpty ? 1 : 0);

  @override
  void initState() {
    super.initState();
    widget.browseCity?.addListener(_onBrowseCityChanged);
    widget.reloadTrigger?.addListener(_onReloadTriggered);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserAndMatches());
  }

  @override
  void dispose() {
    widget.browseCity?.removeListener(_onBrowseCityChanged);
    widget.reloadTrigger?.removeListener(_onReloadTriggered);
    super.dispose();
  }

  void _onBrowseCityChanged() {
    setState(() {
      _browseCity = widget.browseCity!.value;
      _isLoading = true;
    });
    _loadMatches();
  }

  void _onReloadTriggered() {
    setState(() {
      _isLoading = true;
      _activeCategory = null;
    });
    _loadUserAndMatches();
  }

  Future<void> _loadUserAndMatches() async {
    try {
      _uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final data = doc.data()!;

      _activeCategory ??= data['workCategory'] ?? 'other';
      _userState = data['state'] ?? '';
      _userCity = data['city'] ?? '';

      await _loadMatches();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMatches() async {
    try {
      final helpers = await _matchService.getMatchingHelpers(
        workCategory: _activeCategory!,
        state: _userState!,
        city: _browseCity ?? _userCity,
      );

      if (!mounted) return;
      _allHelpers = helpers;
      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading matches: $e');
      if (!mounted) return;
      setState(() {
        _allHelpers = [];
        _helpers = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (_allHelpers == null) return;
    final filtered = _allHelpers!.where((h) {
      final age = (h['age'] as num?)?.toInt();
      if (_minAge != null && (age == null || age < _minAge!)) return false;
      if (_maxAge != null && (age == null || age > _maxAge!)) return false;

      final exp = (h['yearsOfExperience'] as num?)?.toInt() ?? 0;
      if (_minExperience != null && exp < _minExperience!) return false;

      if (_verifiedOnly && h['isVerified'] != true) return false;

      if (_selectedSkills.isNotEmpty) {
        final skills = List<String>.from(h['skills'] ?? []);
        if (!_selectedSkills.any(skills.contains)) return false;
      }
      return true;
    }).toList();

    setState(() => _helpers = filtered);
  }

  void _clearFilters() {
    setState(() {
      _minAge = null;
      _maxAge = null;
      _minExperience = null;
      _verifiedOnly = false;
      _selectedSkills = [];
    });
    _applyFilters();
  }

  void _switchCategory(String category) {
    setState(() {
      _isLoading = true;
      _activeCategory = category;
      _selectedSkills = []; // reset skills filter when category changes
    });
    _loadMatches();
  }

  Future<void> _showFilters() async {
    final categorySkills = categoryToSkills[_activeCategory];

    // Local copies for the sheet's StatefulBuilder
    int? sheetMinAge = _minAge;
    int? sheetMaxAge = _maxAge;
    int? sheetMinExp = _minExperience;
    bool sheetVerified = _verifiedOnly;
    List<String> sheetSkills = List.from(_selectedSkills);

    final minAgeController =
        TextEditingController(text: _minAge?.toString() ?? '');
    final maxAgeController =
        TextEditingController(text: _maxAge?.toString() ?? '');

    final expOptions = [0, 1, 2, 3, 5, 10];
    final expLabels = ['Any', '1 yr', '2 yr', '3 yr', '5 yr', '10+'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
                      child: Row(
                        children: [
                          const Text(
                            'Filter Helpers',
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
                                sheetMinAge = null;
                                sheetMaxAge = null;
                                sheetMinExp = null;
                                sheetVerified = false;
                                sheetSkills = [];
                                minAgeController.clear();
                                maxAgeController.clear();
                              });
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: AppColors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Scrollable content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        children: [
                          // Skills section (only for known categories)
                          if (categorySkills != null &&
                              categorySkills.isNotEmpty) ...[
                            const Text(
                              'Skills',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Show helpers with at least one of:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: categorySkills.map((skill) {
                                final selected = sheetSkills.contains(skill);
                                return FilterChip(
                                  label: Text(skill),
                                  selected: selected,
                                  onSelected: (val) {
                                    setSheetState(() {
                                      if (val) {
                                        sheetSkills.add(skill);
                                      } else {
                                        sheetSkills.remove(skill);
                                      }
                                    });
                                  },
                                  selectedColor:
                                      AppColors.teal.withValues(alpha: 0.15),
                                  checkmarkColor: AppColors.teal,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? AppColors.teal
                                        : AppColors.navyBlue,
                                    fontSize: 13,
                                  ),
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.teal
                                        : Colors.grey.shade300,
                                  ),
                                  backgroundColor: Colors.white,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                          ],

                          // Age range
                          const Text(
                            'Age Range',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: minAgeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Min age',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: AppColors.teal),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    sheetMinAge = int.tryParse(v);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  '–',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 18),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: maxAgeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Max age',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: AppColors.teal),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    sheetMaxAge = int.tryParse(v);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Minimum experience
                          const Text(
                            'Minimum Experience',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: List.generate(expOptions.length, (i) {
                              final val = expOptions[i];
                              final selected = (sheetMinExp ?? 0) == val;
                              return ChoiceChip(
                                label: Text(expLabels[i]),
                                selected: selected,
                                onSelected: (_) {
                                  setSheetState(() {
                                    sheetMinExp = val;
                                  });
                                },
                                selectedColor:
                                    AppColors.teal.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? AppColors.teal
                                      : AppColors.navyBlue,
                                  fontSize: 13,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.teal
                                      : Colors.grey.shade300,
                                ),
                                backgroundColor: Colors.white,
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1),

                          // Verified only
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Verified helpers only',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            subtitle: Text(
                              'Show only Aadhaar-verified helpers',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                            value: sheetVerified,
                            activeThumbColor: AppColors.teal,
                            onChanged: (val) {
                              setSheetState(() => sheetVerified = val);
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    // Apply button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            setState(() {
                              _minAge = sheetMinAge;
                              _maxAge = sheetMaxAge;
                              _minExperience =
                                  (sheetMinExp != null && sheetMinExp! > 0)
                                      ? sheetMinExp
                                      : null;
                              _verifiedOnly = sheetVerified;
                              _selectedSkills = List.from(sheetSkills);
                            });
                            _applyFilters();
                          },
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filter button with active badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter helpers',
                onPressed: _showFilters,
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/phone-login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Faint logo watermark
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/logo.png',
                width: 280,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_browseCity != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Chip(
                    avatar: const Icon(Icons.location_on, size: 16,
                        color: AppColors.teal),
                    label: Text('Showing results for: $_browseCity'),
                    labelStyle: const TextStyle(
                        fontSize: 13, color: AppColors.navyBlue),
                    backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
                    deleteIcon:
                        const Icon(Icons.close, size: 16, color: AppColors.navyBlue),
                    onDeleted: () {
                      setState(() {
                        _browseCity = null;
                        _isLoading = true;
                      });
                      _loadMatches();
                    },
                  ),
                ),
              if (_activeFilterCount > 0)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, _browseCity != null ? 4 : 8, 16, 0),
                  child: Chip(
                    avatar: const Icon(Icons.filter_list, size: 16,
                        color: AppColors.teal),
                    label: Text(
                      '$_activeFilterCount ${_activeFilterCount == 1 ? 'filter' : 'filters'} active',
                    ),
                    labelStyle: const TextStyle(
                        fontSize: 13, color: AppColors.navyBlue),
                    backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.teal.withValues(alpha: 0.3)),
                    deleteIcon:
                        const Icon(Icons.close, size: 16, color: AppColors.navyBlue),
                    onDeleted: _clearFilters,
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : RefreshIndicator(
                        color: AppColors.teal,
                        onRefresh: () async {
                          setState(() => _isLoading = true);
                          await _loadMatches();
                        },
                        child: _helpers == null || _helpers!.isEmpty
                            ? _buildEmptyState()
                            : _buildHelperList(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelperList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _helpers!.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _browseCity != null
                  ? 'Helpers in $_browseCity'
                  : AppLocalizations.of(context)!.employerHome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
          );
        }
        return HelperMatchCard(data: _helpers![index - 1]);
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.search_off,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.noHelpersFound,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Try looking in other categories',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: workCategories
              .where((cat) => cat['value'] != _activeCategory)
              .map((cat) {
            return ActionChip(
              label: Text(cat['label']!),
              labelStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.navyBlue,
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.teal.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => _switchCategory(cat['value']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}
