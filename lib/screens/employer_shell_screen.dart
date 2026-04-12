import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import '../data/indian_cities.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import 'conversation_list_screen.dart';
import 'employer_home_screen.dart';
import 'employer_profile_screen.dart';

class EmployerShellScreen extends StatefulWidget {
  const EmployerShellScreen({super.key});

  @override
  State<EmployerShellScreen> createState() => _EmployerShellScreenState();
}

class _EmployerShellScreenState extends State<EmployerShellScreen> {
  final PageController _pageController = PageController();
  final ChatService _chatService = ChatService();
  final ValueNotifier<String?> _browseCity = ValueNotifier(null);
  final ValueNotifier<int> _reloadTrigger = ValueNotifier(0);

  int _currentIndex = 0;
  bool _hasUnread = false;
  StreamSubscription<bool>? _unreadSub;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _unreadSub = _chatService.hasUnreadConversations(uid).listen((v) {
      if (mounted) setState(() => _hasUnread = v);
    });
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _pageController.dispose();
    _browseCity.dispose();
    _reloadTrigger.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _onCitySelected(String city) {
    _browseCity.value = city;
    _onTabTapped(0);
  }

  void _onProfileSaved() {
    _reloadTrigger.value++;
    _onTabTapped(0);
  }

  Widget _buildMessagesIcon(bool active) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active
            ? Icons.chat_bubble_rounded
            : Icons.chat_bubble_outline_rounded),
        if (_hasUnread)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: [
          EmployerHomeScreen(
            browseCity: _browseCity,
            reloadTrigger: _reloadTrigger,
          ),
          _EmployerSearchTab(
            browseCity: _browseCity,
            onCitySelected: _onCitySelected,
          ),
          const ConversationListScreen(),
          EmployerProfileScreen(onSaved: _onProfileSaved),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.navyBlue,
        unselectedItemColor: AppColors.textGrey,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _buildMessagesIcon(false),
            activeIcon: _buildMessagesIcon(true),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _EmployerSearchTab extends StatefulWidget {
  const _EmployerSearchTab({
    required this.browseCity,
    required this.onCitySelected,
  });

  final ValueNotifier<String?> browseCity;
  final ValueCallback<String> onCitySelected;

  @override
  State<_EmployerSearchTab> createState() => _EmployerSearchTabState();
}

typedef ValueCallback<T> = void Function(T value);

class _EmployerSearchTabState extends State<_EmployerSearchTab> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: const Text(
          'Search by City',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Selected city chip
          ValueListenableBuilder<String?>(
            valueListenable: widget.browseCity,
            builder: (context, city, _) {
              if (city == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Chip(
                  avatar: const Icon(Icons.location_on,
                      size: 16, color: AppColors.teal),
                  label: Text('Showing: $city'),
                  labelStyle: const TextStyle(
                      fontSize: 13, color: AppColors.navyBlue),
                  backgroundColor: AppColors.teal.withValues(alpha: 0.1),
                  side: BorderSide(
                      color: AppColors.teal.withValues(alpha: 0.3)),
                  deleteIcon: const Icon(Icons.close,
                      size: 16, color: AppColors.navyBlue),
                  onDeleted: () {
                    widget.browseCity.value = null;
                  },
                ),
              );
            },
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Type a city name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _suggestions = searchCities(value);
                });
              },
            ),
          ),
          // Results
          Expanded(
            child: _suggestions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _controller.text.isEmpty
                          ? 'Start typing to search cities'
                          : 'No cities found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (_, i) {
                      final city = _suggestions[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on_outlined,
                            color: AppColors.teal, size: 20),
                        title: Text(city),
                        onTap: () {
                          _controller.clear();
                          setState(() => _suggestions = []);
                          widget.onCitySelected(city);
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
