import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _keepSignedIn = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _keepSignedIn = prefs.getBool('keepSignedIn') ?? true;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = '+91${_phoneController.text.trim()}';
    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidPhoneNumber)),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOtp(phone);

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    } else {
      Navigator.pushNamed(context, '/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top section with logo
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: screenHeight * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
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
                      Text(
                        l.appName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom card section
              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.65,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.loginWelcome,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.loginPhoneSubtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.navyBlue,
                            ),
                            decoration: AppDecorations.styledInput(
                              hint: '9876543210',
                              prefixIcon: Icons.phone_android,
                              prefixText: '+91 ',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _keepSignedIn,
                                  activeColor: AppColors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) async {
                                    setState(() => _keepSignedIn = val ?? true);
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('keepSignedIn', _keepSignedIn);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l.keepSignedIn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GradientButton(
                            text: l.sendOtp,
                            isLoading: auth.isLoading,
                            onPressed: auth.isLoading ? null : _sendOtp,
                          ),
                          const SizedBox(height: 28),

                          // Divider with "or"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l.loginOr,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Email login option
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/email-login'),
                            icon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.teal,
                            ),
                            label: Text(
                              l.useEmailInstead,
                              style: const TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
