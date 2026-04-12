import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/match_service.dart';
import '../theme/app_colors.dart';
import '../widgets/match_card.dart';
import '../l10n/app_localizations.dart';

class HelperHomeScreen extends StatefulWidget {
  const HelperHomeScreen({super.key});

  @override
  State<HelperHomeScreen> createState() => _HelperHomeScreenState();
}

class _HelperHomeScreenState extends State<HelperHomeScreen> {
  final MatchService _matchService = MatchService();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>>? _employers;
  bool _isLoading = true;
  String _uid = '';
  List<String> _userSkills = [];
  String _userState = '';
  List<String> _userWorkCities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserAndMatches());
  }

  Future<void> _loadUserAndMatches() async {
    try {
      _uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final data = doc.data()!;

      _userSkills = List<String>.from(data['skills'] ?? []);
      _userState = data['state'] ?? '';
      _userWorkCities = List<String>.from(data['workCities'] ?? []);
      // Fallback for old profiles that only have city (not workCities)
      if (_userWorkCities.isEmpty) {
        final city = data['city'] ?? '';
        if (city.isNotEmpty) _userWorkCities = [city];
      }

      await _loadMatches();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMatches() async {
    try {
      final employers = await _matchService.getMatchingEmployers(
        skills: _userSkills,
        state: _userState,
        workCities: _userWorkCities,
      );

      if (!mounted) return;
      setState(() {
        _employers = employers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading matches: $e');
      if (!mounted) return;
      setState(() {
        _employers = [];
        _isLoading = false;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: AppLocalizations.of(context)!.myProfile,
            onPressed: () async {
              await Navigator.pushNamed(context, '/helper-profile');
              if (mounted) {
                setState(() => _isLoading = true);
                await _loadUserAndMatches();
              }
            },
          ),
          StreamBuilder<bool>(
            stream: _uid.isEmpty ? null : _chatService.hasUnreadConversations(_uid),
            builder: (context, snapshot) {
              final hasUnread = snapshot.data ?? false;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/conversations'),
                  ),
                  if (hasUnread)
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
            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/self-help'),
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.selfHelp,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            Navigator.pushNamed(context, '/self-help');
          }
        },
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
                child: _employers == null || _employers!.isEmpty
                    ? _buildEmptyState()
                    : _buildEmployerList(),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _employers!.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              AppLocalizations.of(context)!.helperHome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
          );
        }
        return EmployerMatchCard(data: _employers![index - 1]);
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
          AppLocalizations.of(context)!.noEmployersFound,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check back later — new opportunities are posted regularly',
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
