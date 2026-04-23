import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/helper_profile_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../utils/circle_reveal_route.dart';
import '../widgets/match_card.dart';
import 'employer_shell_screen.dart';

class OneDayHomeScreen extends StatefulWidget {
  final ValueNotifier<String?> browseCity;
  final VoidCallback onChangeCityTapped;

  const OneDayHomeScreen({
    required this.browseCity,
    required this.onChangeCityTapped,
    super.key,
  });

  @override
  State<OneDayHomeScreen> createState() => _OneDayHomeScreenState();
}

class _OneDayHomeScreenState extends State<OneDayHomeScreen> {
  final GlobalKey _toggleKey = GlobalKey();

  List<Map<String, dynamic>>? _allHelpers;
  List<Map<String, dynamic>>? _helpers;

  bool _isLoading = false;
  String? _selectedSkill;
  String _browseCity = '';
  String _registeredCity = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedTiming = 'Morning (8am–12pm)';

  // Filter state
  bool _verifiedOnly = false;
  int? _minAge;
  int? _maxAge;

  // Tutorial: hidden by default until prefs load to avoid flash
  bool _hasSeenTutorial = true;

  Timer? _saveDebounce;

  int get _activeFilterCount =>
      (_verifiedOnly ? 1 : 0) +
      (_minAge != null ? 1 : 0) +
      (_maxAge != null ? 1 : 0);

  @override
  void initState() {
    super.initState();
    widget.browseCity.addListener(_onBrowseCityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserPrefs();
      await _loadHelpers();
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    widget.browseCity.removeListener(_onBrowseCityChanged);
    super.dispose();
  }

  void _onBrowseCityChanged() {
    final city = widget.browseCity.value;
    if (city != null && city.isNotEmpty) {
      setState(() => _browseCity = city);
      _loadHelpers();
      _savePrefs();
    }
  }

  Future<void> _loadUserPrefs() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data()!;

      _registeredCity = data['city'] ?? '';
      final seenTutorial = (data['hasSeenOneDayTutorial'] as bool?) ?? false;

      final prefs = data['oneDayPrefs'] as Map<String, dynamic>?;
      if (prefs != null) {
        final savedSkill = prefs['skill'] as String?;
        final savedCity = prefs['city'] as String?;
        final dateStr = prefs['date'] as String?;
        final timing = prefs['timing'] as String?;

        DateTime restoredDate = DateTime.now();
        if (dateStr != null) {
          final parsed = DateTime.tryParse(dateStr);
          if (parsed != null) {
            final today = DateTime.now();
            final todayOnly = DateTime(today.year, today.month, today.day);
            final parsedOnly =
                DateTime(parsed.year, parsed.month, parsed.day);
            restoredDate =
                parsedOnly.isBefore(todayOnly) ? todayOnly : parsedOnly;
          }
        }

        setState(() {
          _selectedSkill = savedSkill;
          _browseCity = (savedCity != null && savedCity.isNotEmpty)
              ? savedCity
              : _registeredCity;
          _selectedDate = restoredDate;
          _selectedTiming = timing ?? 'Flexible';
          _hasSeenTutorial = seenTutorial;
        });
      } else {
        setState(() {
          _selectedSkill = null;
          _browseCity = _registeredCity;
          _selectedDate = DateTime.now();
          _selectedTiming = 'Flexible';
          _hasSeenTutorial = seenTutorial;
        });
      }
    } catch (e) {
      debugPrint('Error loading user prefs: $e');
    }
  }

  Future<void> _loadHelpers() async {
    if (_selectedSkill == null || _browseCity.isEmpty) {
      setState(() => _helpers = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final helpers = await FirestoreService().getOneDayHelpers(
        skill: _selectedSkill!,
        city: _browseCity,
      );
      if (!mounted) return;
      _allHelpers = helpers;
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading one-day helpers: $e');
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
    var result = List<Map<String, dynamic>>.from(_allHelpers!);
    if (_verifiedOnly) {
      result = result.where((h) => h['isVerified'] == true).toList();
    }
    if (_minAge != null) {
      result = result.where((h) => (h['age'] ?? 0) >= _minAge!).toList();
    }
    if (_maxAge != null) {
      result = result.where((h) => (h['age'] ?? 999) <= _maxAge!).toList();
    }
    setState(() {
      _helpers = result;
      _isLoading = false;
    });
  }

  void _savePrefs() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirestoreService().updateOneDayPrefs(uid, {
        'skill': _selectedSkill,
        'city': _browseCity,
        'date': _selectedDate.toIso8601String().substring(0, 10),
        'timing': _selectedTiming,
        'lastUsed': Timestamp.now(),
      });
    });
  }

  void _dismissTutorial() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'hasSeenOneDayTutorial': true});
  }

  Future<void> _showFilters() async {
    bool sheetVerified = _verifiedOnly;
    int? sheetMinAge = _minAge;
    int? sheetMaxAge = _maxAge;

    final minAgeController =
        TextEditingController(text: _minAge?.toString() ?? '');
    final maxAgeController =
        TextEditingController(text: _maxAge?.toString() ?? '');

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
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
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
                            'Filters',
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
                                sheetVerified = false;
                                sheetMinAge = null;
                                sheetMaxAge = null;
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
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Verified workers only',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navyBlue,
                              ),
                            ),
                            subtitle: Text(
                              'Show only Aadhaar-verified workers',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                            value: sheetVerified,
                            activeThumbColor: AppColors.teal,
                            onChanged: (val) =>
                                setSheetState(() => sheetVerified = val),
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
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
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: AppColors.teal),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      sheetMinAge = int.tryParse(v),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text('–',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 18)),
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
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: AppColors.teal),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      sheetMaxAge = int.tryParse(v),
                                ),
                              ),
                            ],
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
                              _verifiedOnly = sheetVerified;
                              _minAge = sheetMinAge;
                              _maxAge = sheetMaxAge;
                            });
                            _applyFilters();
                          },
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
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

  Future<void> _confirmLogout() async {
    final auth = context.read<AuthProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/phone-login', (_) => false);
  }

  Future<void> _onToggleOff() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    bool profileComplete = false;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      profileComplete = doc.data()?['profileComplete'] as bool? ?? false;
    }
    if (!profileComplete) {
      await _showProfileGateSheet();
      return;
    }
    _runSwitchAnimation();
  }

  Future<void> _showProfileGateSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Set up your profile first',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue),
              ),
              const SizedBox(height: 12),
              const Text(
                'To browse regular workers, we need a few details about what you\'re looking for',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.pushNamed(
                        context, '/employer-profile-setup');
                    if (!mounted) return;
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get();
                    final complete =
                        doc.data()?['profileComplete'] as bool? ??
                            false;
                    if (complete && mounted) _runSwitchAnimation();
                  },
                  child: const Text('Set up now'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Not now',
                    style: TextStyle(color: AppColors.textGrey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runSwitchAnimation() {
    final box =
        _toggleKey.currentContext?.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset.zero);
    final sz = box?.size;
    final center = pos != null
        ? Offset(pos.dx + sz!.width / 2, pos.dy + sz.height / 2)
        : Offset(MediaQuery.of(context).size.width - 60, 30);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirestoreService().updateEmployerLastMode(uid, 'termBased');
    }

    Navigator.pushAndRemoveUntil(
      context,
      CircleRevealRoute(
        page: const EmployerShellScreen(),
        center: center,
        expandColor: const Color(0xFF193A4A),
      ),
      (_) => false,
    );
  }

  void _openChat(Map<String, dynamic> helperData) {
    final chatArgs = {
      'otherUserData': helperData,
      'initiatorRole': 'employer',
      'isOneDayChat': true,
      'oneDayDate': _selectedDate.toIso8601String().substring(0, 10),
      'oneDayTiming': _selectedTiming,
      'oneDaySkill': _selectedSkill ?? '',
    };
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (phone == null || phone.isEmpty) {
      Navigator.pushNamed(context, '/add-phone', arguments: chatArgs);
    } else {
      Navigator.pushNamed(context, '/chat', arguments: chatArgs);
    }
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      const weekdays = [
        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
      ];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    }
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(width: 6),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              key: _toggleKey,
              value: true,
              onChanged: (val) {
                if (!val) _onToggleOff();
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

  Widget _buildCityBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
      child: Row(
        children: [
          const Icon(Icons.location_on,
              size: 12, color: Color(0xFF5DCAA5)),
          const SizedBox(width: 4),
          Text(
            _browseCity.isNotEmpty ? _browseCity : 'Select a city',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.keyboard_arrow_down,
              size: 10,
              color: Colors.white.withValues(alpha: 0.5)),
          const Spacer(),
          GestureDetector(
            onTap: widget.onChangeCityTapped,
            child: const Text(
              'Change',
              style:
                  TextStyle(fontSize: 10, color: Color(0xFF5DCAA5)),
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
        backgroundColor: const Color(0xFF1A3A4A),
        title: const Text(
          'KaamSathi',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _buildCityBar(),
        ),
        actions: [
          _buildModeToggle(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                tooltip: 'Filters',
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Skill chips row
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                itemCount: oneDaySkills.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final skill = oneDaySkills[i];
                  final selected = _selectedSkill == skill;
                  return ChoiceChip(
                    label: Text(skill),
                    selected: selected,
                    selectedColor: const Color(0xFF1A8A8A),
                    backgroundColor: Colors.transparent,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF1A8A8A),
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(color: Color(0xFF1A8A8A)),
                    ),
                    onSelected: (_) {
                      if (!_hasSeenTutorial) {
                        setState(() => _hasSeenTutorial = true);
                        _dismissTutorial();
                      }
                      setState(() => _selectedSkill = skill);
                      _loadHelpers();
                      _savePrefs();
                    },
                  );
                },
              ),
            ),

            // First-time coach mark
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                    sizeFactor: animation, child: child),
              ),
              child: _hasSeenTutorial
                  ? const SizedBox.shrink()
                  : Container(
                      key: const ValueKey('tutorial-hint'),
                      margin:
                          const EdgeInsets.fromLTRB(14, 4, 14, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.teal
                                .withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_upward,
                              size: 16, color: AppColors.teal),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap a skill above to find available workers',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Date + Timing row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _buildDateBox()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTimingBox()),
                ],
              ),
            ),

            // Section header
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
              child: Text(
                'AVAILABLE WORKERS',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    letterSpacing: 0.8),
              ),
            ),

            // Worker list or state
            _buildWorkerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox() {
    return InkWell(
      onTap: () async {
        final today = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: today,
          lastDate: today.add(const Duration(days: 30)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx)
                  .colorScheme
                  .copyWith(primary: AppColors.teal),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
          _savePrefs();
        }
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8D8)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFAFAFA),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navyBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingBox() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            final options = [
              'Morning (8am–12pm)',
              'Afternoon (12pm–4pm)',
              'Evening (4pm–8pm)',
              'Flexible',
            ];
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...options.map((opt) => ListTile(
                        leading: Icon(
                          Icons.schedule,
                          color: _selectedTiming == opt
                              ? AppColors.teal
                              : Colors.grey,
                        ),
                        title: Text(opt),
                        trailing: _selectedTiming == opt
                            ? const Icon(Icons.check,
                                color: AppColors.teal)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTiming = opt);
                          _savePrefs();
                        },
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD8D8D8)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFAFAFA),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTiming,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navyBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    if (_selectedSkill == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Text(
            'Select a skill above to find workers',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    if (_helpers == null || _helpers!.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.search_off,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No $_selectedSkill workers found in $_browseCity for one-day work',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the skill or city above, or check back later as new workers join daily',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
      itemCount: _helpers!.length,
      itemBuilder: (_, i) => HelperMatchCard(
        data: _helpers![i],
        showOneDayBadge: true,
        onMessageTap: () => _openChat(_helpers![i]),
      ),
    );
  }
}
