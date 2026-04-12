import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  int _step = 1; // 1 = phone entry, 2 = OTP entry
  String? _verificationId;
  String _phone = '';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final digits = _phoneController.text.trim();
    if (digits.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _phone = '+91$digits';
    });

    await _authService.verifyPhoneNumber(
      phoneNumber: _phone,
      onAutoVerified: (credential) => _linkCredential(credential),
      onCodeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _step = 2;
          _isLoading = false;
        });
      },
      onFailed: (e) {
        setState(() {
          _error = e.message ?? 'Failed to send OTP';
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    if (_verificationId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    await _linkCredential(credential);
  }

  Future<void> _linkCredential(PhoneAuthCredential credential) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.linkWithCredential(credential);
      await _firestoreService.updateUserPhone(user.uid, _phone);
      _proceedToChat();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        // Phone already linked to this account — just proceed
        _proceedToChat();
      } else if (e.code == 'credential-already-in-use') {
        setState(() {
          _error = 'This number is already linked to another account';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = e.message ?? 'Verification failed';
          _isLoading = false;
        });
      }
    }
  }

  void _proceedToChat() {
    if (!mounted) return;
    final chatArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.pushReplacementNamed(context, '/chat', arguments: chatArgs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlue,
        title: const Text('Verify Phone Number'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 36,
                color: AppColors.teal,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              _step == 1 ? 'Add your phone number' : 'Enter the OTP',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 1
                  ? 'We need this to let you share contact details during chats.'
                  : 'Enter the 6-digit code sent to $_phone',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),

            const SizedBox(height: 32),

            if (_step == 1) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 16, color: AppColors.navyBlue),
                decoration: AppDecorations.styledInput(
                  hint: '9876543210',
                  prefixIcon: Icons.phone_android,
                  prefixText: '+91 ',
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
                decoration: AppDecorations.styledInput(hint: '• • • • • •'),
              ),
              const SizedBox(height: 8),
            ],

            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              const SizedBox(height: 8),
            ],

            GradientButton(
              text: _step == 1 ? 'Send OTP' : 'Verify',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : (_step == 1 ? _sendOtp : _verifyOtp),
            ),

            if (_step == 2) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() {
                          _step = 1;
                          _otpController.clear();
                          _error = null;
                        }),
                child: const Text(
                  'Change number',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
