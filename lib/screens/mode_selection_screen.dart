import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool _isLoading = false;

  Future<void> _selectMode(BuildContext context, String mode) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirestoreService().updateEmployerLastMode(uid, mode);

    if (!mounted) return;

    if (mode == 'oneDay') {
      Navigator.pushNamedAndRemoveUntil(context, '/one-day-home', (_) => false);
    } else {
      final profileComplete =
          context.read<AuthProvider>().userModel?.profileComplete ?? false;
      final route =
          profileComplete ? '/employer-home' : '/employer-profile-setup';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 24),
                const Text(
                  'What are you looking for today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
                const SizedBox(height: 32),
                _ModeCard(
                  color: const Color(0xFFE8F6F6),
                  borderColor: const Color(0xFF1A8A8A),
                  icon: Icons.flash_on,
                  iconColor: const Color(0xFF1A8A8A),
                  title: 'One-day help',
                  subtitle:
                      'Find workers for same-day jobs like repairs, massages, cleaning, or events',
                  onTap: _isLoading ? null : () => _selectMode(context, 'oneDay'),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  color: const Color(0xFFE8EFF6),
                  borderColor: const Color(0xFF1A3A4A),
                  icon: Icons.people_outline,
                  iconColor: const Color(0xFF1A3A4A),
                  title: 'Regular / long-term help',
                  subtitle:
                      'Hire live-in, daily, or short-term workers like cooks, maids, drivers',
                  onTap: _isLoading ? null : () => _selectMode(context, 'termBased'),
                ),
                const Spacer(),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const Text(
                  'You can switch between these anytime',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
