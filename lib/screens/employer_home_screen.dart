import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/employer_profile_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../services/match_service.dart';
import '../theme/app_colors.dart';
import '../utils/circle_reveal_route.dart';
import '../widgets/match_card.dart';
import '../l10n/app_localizations.dart';
import 'one_day_shell_screen.dart';

const _kChipCategories = [
  ('skilled_labor', 'Skilled Labour'),
  ('domestic_help', 'Home Care'),
  ('commercial', 'Commercial'),
  ('drivers', 'Drivers'),
  ('other', 'Other'),
];

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({
    super.key,
    this.browseCity,
    this.reloadTrigger,
    this.onChangeCityTapped,
    this.messagesNavKey,
  });

  final ValueNotifier<String?>? browseCity;
  final ValueNotifier<int>? reloadTrigger;
  final VoidCallback? onChangeCityTapped;
  final GlobalKey? messagesNavKey;

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  final MatchService _matchService = MatchService();
  final GlobalKey _toggleKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _categoryChipsKey = GlobalKey();
  final GlobalKey _cityKey = GlobalKey();

  List<Map<String, dynamic>>? _allHelpers;
  List<Map<String, dynamic>>? _helpers;

  bool _isLoading = true;
  String _uid = '';
  String? _activeCategory;
  String? _userState;
  String _userCity = '';
  String? _browseCity;

  // Filter state
  int? _minAge;
  int? _maxAge;
  int? _minExperience;
  bool _verifiedOnly = false;
  String? _scheduleType;
  List<String> _selectedSkills = [];

  int get _activeFilterCount =>
      (_minAge != null ? 1 : 0) +
      (_maxAge != null ? 1 : 0) +
      (_minExperience != null && _minExperience! > 0 ? 1 : 0) +
      (_verifiedOnly ? 1 : 0) +
      (_scheduleType != null ? 1 : 0) +
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
      _userCity = _browseCity!;
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

      final savedFilters = data['savedFilters'] as Map<String, dynamic>?;
      _activeCategory ??= savedFilters?['category'] as String?
          ?? data['workCategory'] ?? 'other';
      _userState = data['state'] ?? '';
      _userCity = data['city'] ?? '';
      _selectedSkills = List<String>.from(savedFilters?['skills'] ?? []);
      final hasSeenTutorial = data['hasSeenTutorial'] as bool? ?? false;

      await _loadMatches();

      if (!hasSeenTutorial && mounted) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _showTutorial();
        });
      }
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
        requiredSkills: _selectedSkills,
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

      if (_scheduleType != null) {
        final scheduleTypes =
            List<String>.from(h['scheduleTypes'] ?? [h['scheduleType'] ?? '']);
        if (!scheduleTypes.contains(_scheduleType)) return false;
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
      _scheduleType = null;
      _selectedSkills = [];
    });
    _applyFilters();
  }

  void _switchCategory(String category) {
    setState(() {
      _isLoading = true;
      _activeCategory = category;
      _selectedSkills = [];
    });
    _loadMatches();
    if (_uid.isNotEmpty) {
      FirestoreService().updateEmployerSavedFilters(
        _uid,
        category: category,
        skills: [],
      );
    }
  }

  void _switchToOneDay() {
    final box = _toggleKey.currentContext?.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset.zero);
    final sz = box?.size;
    final center = pos != null
        ? Offset(pos.dx + sz!.width / 2, pos.dy + sz.height / 2)
        : Offset(MediaQuery.of(context).size.width - 60, 30);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) FirestoreService().updateEmployerLastMode(uid, 'oneDay');

    Navigator.pushAndRemoveUntil(
      context,
      CircleRevealRoute(
        page: const OneDayShellScreen(),
        center: center,
        expandColor: const Color(0xFF0D5E5E),
      ),
      (_) => false,
    );
  }

  Future<void> _showFilters() async {
    int? sheetMinAge = _minAge;
    int? sheetMaxAge = _maxAge;
    int? sheetMinExp = _minExperience;
    bool sheetVerified = _verifiedOnly;
    String? sheetSchedule = _scheduleType;
    List<String> sheetSelectedSkills = List.from(_selectedSkills);

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
                                sheetSchedule = null;
                                sheetSelectedSkills = [];
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
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        children: [
                          // Skills section (for categories that have sub-skills)
                          if (categoryToSkills[_activeCategory] != null) ...[
                            const Text(
                              'Skills',
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
                              children: categoryToSkills[_activeCategory]!
                                  .map((skill) {
                                final selected =
                                    sheetSelectedSkills.contains(skill);
                                return FilterChip(
                                  label: Text(skill),
                                  selected: selected,
                                  onSelected: (_) {
                                    setSheetState(() {
                                      if (selected) {
                                        sheetSelectedSkills.remove(skill);
                                      } else {
                                        sheetSelectedSkills.add(skill);
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
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Schedule type
                          const Text(
                            'Schedule Type',
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
                            children: [
                              ('Any', null),
                              ('Full-time', 'full_time'),
                              ('Hourly', 'hourly'),
                            ].map((opt) {
                              final selected = sheetSchedule == opt.$2;
                              return ChoiceChip(
                                label: Text(opt.$1),
                                selected: selected,
                                onSelected: (_) {
                                  setSheetState(() {
                                    sheetSchedule = opt.$2;
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
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
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
                              _scheduleType = sheetSchedule;
                              _selectedSkills = List.from(sheetSelectedSkills);
                              _isLoading = true;
                            });
                            _loadMatches();
                            if (_uid.isNotEmpty) {
                              FirestoreService().updateEmployerSavedFilters(
                                _uid,
                                category: _activeCategory!,
                                skills: _selectedSkills,
                              );
                            }
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

  void _showTutorial() {
    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'filter',
        keyTarget: _filterKey,
        shape: ShapeLightFocus.Circle,
        enableOverlayTab: true,
        enableTargetTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, _) => _tutorialContent(
              title: 'Find the exact skill you need',
              description:
                  'Tap here to filter by specific skills like Cooking, '
                  'Cleaning, or Electrician within your selected category',
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'toggle',
        keyTarget: _toggleKey,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        enableOverlayTab: true,
        enableTargetTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, _) => _tutorialContent(
              title: 'Need quick one-day help?',
              description:
                  'Switch this on to find workers available for same-day '
                  'jobs like repairs, cleaning, or massages',
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'categories',
        keyTarget: _categoryChipsKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        enableOverlayTab: true,
        enableTargetTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, _) => _tutorialContent(
              title: 'Browse by category',
              description:
                  'Tap any category to see workers in that field — '
                  'Home Care, Skilled Labour, Commercial, and more',
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: 'city',
        keyTarget: _cityKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        enableOverlayTab: true,
        enableTargetTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, _) => _tutorialContent(
              title: 'Change your city',
              description:
                  'Tap here to switch cities and see workers available '
                  'in a different location',
            ),
          ),
        ],
      ),
      if (widget.messagesNavKey != null)
        TargetFocus(
          identify: 'messages',
          keyTarget: widget.messagesNavKey!,
          shape: ShapeLightFocus.Circle,
          enableOverlayTab: true,
          enableTargetTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (_, _) => _tutorialContent(
                title: 'Your conversations',
                description:
                    'All your chats with workers appear here. '
                    "Start a conversation from any worker's profile",
              ),
            ),
          ],
        ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF193A4A),
      opacityShadow: 0.85,
      textSkip: 'SKIP',
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 300),
      pulseAnimationDuration: const Duration(milliseconds: 800),
      onFinish: _setTutorialSeen,
      onSkip: () {
        _setTutorialSeen();
        return true;
      },
    ).show(context: context, rootOverlay: true);
  }

  Widget _tutorialContent({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _setTutorialSeen() {
    if (_uid.isNotEmpty) {
      FirestoreService().markEmployerTutorialSeen(_uid);
    }
  }

  Widget _buildModeToggle() {
    return Container(
      key: _toggleKey,
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'One-day',
            style: TextStyle(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(width: 6),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: false,
              onChanged: (val) {
                if (val) _switchToOneDay();
              },
              trackColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? const Color(0xFF5DCAA5)
                      : Colors.white.withValues(alpha: 0.25)),
              thumbColor: WidgetStateProperty.all(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Stack(
      key: _filterKey,
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
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
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
    );
  }

  Widget _buildCityBar() {
    return Padding(
      key: _cityKey,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 12, color: Color(0xFF5DCAA5)),
          const SizedBox(width: 4),
          Text(
            _browseCity ?? _userCity,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.keyboard_arrow_down,
              size: 10, color: Colors.white.withValues(alpha: 0.5)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onChangeCityTapped,
            child: const Text(
              'Change',
              style: TextStyle(fontSize: 10, color: Color(0xFF5DCAA5)),
            ),
          ),
        ],
      ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _buildCityBar(),
        ),
        actions: [
          _buildModeToggle(),
          _buildFilterButton(),
          _buildLogoutButton(),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category chips row
          Container(
            key: _categoryChipsKey,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: _kChipCategories.map((cat) {
                  final selected = _activeCategory == cat.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.$2),
                      selected: selected,
                      onSelected: (_) => _switchCategory(cat.$1),
                      selectedColor: const Color(0xFF1a8a8a),
                      backgroundColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF1a8a8a),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: const BorderSide(color: Color(0xFF1a8a8a)),
                      shape: const StadiumBorder(),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_activeFilterCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Chip(
                avatar: const Icon(Icons.filter_list,
                    size: 16, color: AppColors.teal),
                label: Text(
                  '$_activeFilterCount ${_activeFilterCount == 1 ? 'filter' : 'filters'} active',
                ),
                labelStyle: const TextStyle(
                    fontSize: 13, color: AppColors.navyBlue),
                backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                side: BorderSide(
                    color: AppColors.teal.withValues(alpha: 0.3)),
                deleteIcon: const Icon(Icons.close,
                    size: 16, color: AppColors.navyBlue),
                onDeleted: _clearFilters,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.teal),
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
      ],
    );
  }
}
