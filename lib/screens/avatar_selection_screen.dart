import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

/// Helper avatar definitions — tool/work-themed (emoji, background color)
const List<(String, Color)> kHelperAvatars = [
  ('👷', Color(0xFFF5A623)),
  ('🔨', Color(0xFF3E8ED0)),
  ('🧰', Color(0xFFE74C3C)),
  ('⚙️', Color(0xFF7F8C8D)),
  ('🏗️', Color(0xFF00BCD4)),
  ('💼', Color(0xFF34495E)),
  ('🤝', Color(0xFF27AE60)),
  ('🌟', Color(0xFFF39C12)),
  ('🔧', Color(0xFF8E44AD)),
  ('🎯', Color(0xFFE84393)),
  ('🏆', Color(0xFFD4AC0D)),
  ('🌱', Color(0xFF2ECC71)),
];

/// Employer avatar definitions — ideas/discovery/community themed (emoji, background color)
const List<(String, Color)> kEmployerAvatars = [
  ('🌍', Color(0xFF00796B)),
  ('💡', Color(0xFFF9A825)),
  ('🧭', Color(0xFF6D4C41)),
  ('🔮', Color(0xFF6A1B9A)),
  ('🧩', Color(0xFFC62828)),
  ('🎨', Color(0xFF0097A7)),
  ('🎭', Color(0xFF1A237E)),
  ('🎲', Color(0xFF388E3C)),
  ('🗺️', Color(0xFF8D6E63)),
  ('🎵', Color(0xFFAD1457)),
  ('🎯', Color(0xFFB71C1C)),
  ('🎪', Color(0xFFE65100)),
];

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  int? _selectedIndex;
  bool _isLoading = false;
  late List<(String, Color)> _avatars;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = ModalRoute.of(context)!.settings.arguments as String;
    _avatars = role == 'helper' ? kHelperAvatars : kEmployerAvatars;
  }

  Future<void> _continue() async {
    if (_selectedIndex == null) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirestoreService().updateUserAvatar(uid, _selectedIndex!);

      if (!mounted) return;
      final role = ModalRoute.of(context)!.settings.arguments as String;
      final route = role == 'helper' ? '/aadhaar-nudge' : '/employer-home';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }

  Widget _buildPreview() {
    final hasSelection = _selectedIndex != null;
    final emoji = hasSelection ? _avatars[_selectedIndex!].$1 : '?';
    final color = hasSelection ? _avatars[_selectedIndex!].$2 : Colors.white24;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: child,
      ),
      child: Container(
        key: ValueKey(_selectedIndex),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (hasSelection ? color : Colors.white)
                  .withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarItem(int index) {
    final (emoji, color) = _avatars[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            if (isSelected)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 36),

              // Big live preview
              _buildPreview(),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick one that represents you',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),

              const SizedBox(height: 32),

              // Avatar grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (_, i) => _buildAvatarItem(i),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Opacity(
                  opacity: _selectedIndex == null ? 0.4 : 1.0,
                  child: GradientButton(
                    text: 'Continue',
                    isLoading: _isLoading,
                    onPressed: (_selectedIndex == null || _isLoading)
                        ? null
                        : _continue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
