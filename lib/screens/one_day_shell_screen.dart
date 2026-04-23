import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import '../data/indian_cities.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import 'conversation_list_screen.dart';
import 'one_day_home_screen.dart';
import 'one_day_settings_screen.dart';

class OneDayShellScreen extends StatefulWidget {
  const OneDayShellScreen({super.key});

  @override
  State<OneDayShellScreen> createState() => _OneDayShellScreenState();
}

class _OneDayShellScreenState extends State<OneDayShellScreen> {
  final PageController _pageController = PageController();
  final ChatService _chatService = ChatService();
  final ValueNotifier<String?> _browseCity = ValueNotifier(null);

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
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CityPickerSheet(
        onCitySelected: (city) {
          _browseCity.value = city;
          Navigator.pop(context);
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            FirestoreService().updateEmployerCity(uid, city);
          }
        },
      ),
    );
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
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: [
          OneDayHomeScreen(
            browseCity: _browseCity,
            onChangeCityTapped: () => _showCityPicker(context),
          ),
          const ConversationListScreen(chatTypeFilter: 'oneDay'),
          const OneDaySettingsScreen(),
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
          BottomNavigationBarItem(
            icon: _buildMessagesIcon(false),
            activeIcon: _buildMessagesIcon(true),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

typedef _ValueCallback<T> = void Function(T value);

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.onCitySelected});

  final _ValueCallback<String> onCitySelected;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search by City',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _suggestions = searchCities(value);
                  });
                },
              ),
            ),
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
                      separatorBuilder: (_, _) =>
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
      ),
    );
  }
}
