import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// The 4 possible states of the auth system
enum AuthStatus {
  uninitialized, // app just opened, still checking
  unauthenticated, // no user signed in
  authenticated, // signed in but no role selected yet
  roleSelected, // signed in and role exists → ready to use app
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // ──── State fields ────
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _userModel;
  String? _verificationId;
  int? _resendToken;
  String? _phoneNumber;
  bool _isLoading = false;
  bool _isResending = false;
  bool _emailVerificationPending = false;
  String? _errorMessage;

  // ──── Getters (screens read these) ────
  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  bool get emailVerificationPending => _emailVerificationPending;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;

  // ──── Called once from SplashScreen ────

  /// Check if user is already signed in and has a role
  Future<void> checkAuthState() async {
    final firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // If user opted out of persistent sign-in, sign them out now
    final prefs = await SharedPreferences.getInstance();
    final keepSignedIn = prefs.getBool('keepSignedIn') ?? true;
    if (!keepSignedIn) {
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // User is signed in — check Firestore for their role
    _userModel = await _firestoreService.getUser(firebaseUser.uid);

    if (_userModel == null || _userModel!.role == null) {
      _status = AuthStatus.authenticated; // needs role selection
    } else {
      _status = AuthStatus.roleSelected; // fully set up
    }
    notifyListeners();
  }

  // ──── Phone OTP Flow ────

  /// Step 1: Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    _phoneNumber = phoneNumber;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onAutoVerified: (credential) async {
        // Android auto-detected the OTP from the SMS
        await _signInWithCredential(credential);
      },
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _isLoading = false;
        notifyListeners();
      },
      onFailed: (e) {
        debugPrint('Firebase Phone Auth Error: code=${e.code}, message=${e.message}');
        _errorMessage = e.message ?? 'Verification failed';
        _isLoading = false;
        notifyListeners();
      },
      resendToken: _resendToken,
    );
  }

  /// Resend OTP to the same phone number
  Future<void> resendOtp() async {
    if (_phoneNumber == null) return;
    _isResending = true;
    _errorMessage = null;
    notifyListeners();

    await _authService.verifyPhoneNumber(
      phoneNumber: _phoneNumber!,
      onAutoVerified: (credential) async {
        await _signInWithCredential(credential);
      },
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _isResending = false;
        notifyListeners();
      },
      onFailed: (e) {
        _errorMessage = e.message ?? 'Resend failed';
        _isResending = false;
        notifyListeners();
      },
      resendToken: _resendToken,
    );
  }

  /// Step 2: Verify OTP the user typed
  Future<void> verifyOtp(String otp) async {
    if (_verificationId == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Invalid OTP';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal: sign in with a phone auth credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      await _handlePostSignIn(userCredential);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Sign in failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──── Email Flow ────

  /// Sign in with email (tries login first, registers if user not found)
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _emailVerificationPending = false;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      await _handlePostSignIn(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // User may not exist — try to register
        try {
          final userCredential = await _authService.registerWithEmail(
            email: email,
            password: password,
          );
          await _handlePostSignIn(userCredential);
          // New registration — send verification email
          await _authService.sendEmailVerification();
          _emailVerificationPending = true;
          notifyListeners();
        } on FirebaseAuthException catch (e2) {
          if (e2.code == 'email-already-in-use') {
            // User exists but typed wrong password
            _errorMessage = 'Incorrect password';
          } else {
            _errorMessage = e2.message ?? 'Registration failed';
          }
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _errorMessage = e.message ?? 'Sign in failed';
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ──── Email Verification ────

  /// Check if the user's email has been verified
  Future<bool> checkEmailVerified() async {
    await _authService.reloadUser();
    final verified = _authService.isEmailVerified;
    if (verified) {
      _emailVerificationPending = false;
      notifyListeners();
    }
    return verified;
  }

  /// Resend the verification email
  Future<void> resendVerificationEmail() async {
    _isResending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendEmailVerification();
      _isResending = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Failed to resend email';
      _isResending = false;
      notifyListeners();
    }
  }

  // ──── Post Sign-In (shared by phone + email) ────

  /// After any successful sign-in, check/create the Firestore user doc
  Future<void> _handlePostSignIn(UserCredential userCredential) async {
    final user = userCredential.user!;
    try {
      _userModel = await _firestoreService.getUser(user.uid);

      if (_userModel == null) {
        // First-time user: create Firestore doc with role = null
        _userModel = UserModel(
          uid: user.uid,
          phoneNumber: user.phoneNumber,
          email: user.email,
          role: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestoreService.createUser(_userModel!);
        _status = AuthStatus.authenticated;
      } else if (_userModel!.role == null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.roleSelected;
      }
    } catch (e) {
      debugPrint('Firestore error in _handlePostSignIn: $e');
      _errorMessage = 'Failed to load your profile. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ──── Role Selection ────

  /// Set the user's role after they pick Worker or Employer
  Future<void> setRole(String role) async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.updateUserRole(_userModel!.uid, role);
    _userModel = _userModel!.copyWith(role: role);
    _status = AuthStatus.roleSelected;

    _isLoading = false;
    notifyListeners();
  }

  // ──── Reset Role ────

  /// Reset role so user can re-pick helper/employer
  Future<void> resetRole() async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.resetUserRole(_userModel!.uid);
    _userModel = _userModel!.copyWith(clearRole: true, profileComplete: false);
    _status = AuthStatus.authenticated;

    _isLoading = false;
    notifyListeners();
  }

  // ──── Sign Out ────

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    _verificationId = null;
    _resendToken = null;
    _phoneNumber = null;
    notifyListeners();
  }
}
