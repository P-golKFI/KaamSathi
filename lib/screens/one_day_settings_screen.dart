import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';

class OneDaySettingsScreen extends StatelessWidget {
  const OneDaySettingsScreen({super.key});

  Future<void> _switchToTermBased(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profileComplete =
        context.read<AuthProvider>().userModel?.profileComplete ?? false;
    if (uid != null) {
      await FirestoreService().updateEmployerLastMode(uid, 'termBased');
    }
    if (!context.mounted) return;
    if (profileComplete) {
      Navigator.pushReplacementNamed(context, '/employer-home',
          arguments: {'slideFrom': 'right'});
    } else {
      await Navigator.pushNamed(context, '/employer-profile-setup');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/employer-home',
            arguments: {'slideFrom': 'right'});
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
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
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await auth.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/phone-login', (_) => false);
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'KaamSathi',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 KaamSathi. All rights reserved.',
      children: [
        const SizedBox(height: 12),
        const Text(
          'KaamSathi connects employers with skilled workers for one-day and long-term jobs across India.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber;
    final email = user?.email;
    final displayName =
        context.watch<AuthProvider>().userModel?.displayName ?? '';

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A4A),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // Account section
          const _SectionHeader(label: 'ACCOUNT'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppColors.navyBlue),
                  title: const Text('Account'),
                  subtitle: Text(
                    [
                      if (displayName.isNotEmpty) displayName,
                      if (phone != null && phone.isNotEmpty) phone,
                      if (email != null && email.isNotEmpty) email,
                    ].join('\n'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  isThreeLine:
                      (phone?.isNotEmpty == true) && (email?.isNotEmpty == true),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.navyBlue),
                  title: const Text('Switch to regular hiring'),
                  subtitle: const Text(
                    'Hire live-in, daily, or long-term workers',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _switchToTermBased(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App section
          const _SectionHeader(label: 'APP'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.navyBlue),
                  title: const Text('About KaamSathi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
