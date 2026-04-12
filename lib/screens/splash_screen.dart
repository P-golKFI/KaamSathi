import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for logo + text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Wave/equalizer looping animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    // If the user hasn't chosen a language yet, send them there first.
    // They must pick before anything else happens.
    final hasLanguage = await LocaleProvider.hasChosenLanguage();
    if (!mounted) return;
    if (!hasLanguage) {
      Navigator.pushReplacementNamed(context, '/language-selection');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await Future.wait([
      authProvider.checkAuthState(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null &&
        firebaseUser.email != null &&
        !firebaseUser.emailVerified) {
      Navigator.pushReplacementNamed(context, '/email-verification');
      return;
    }

    switch (authProvider.status) {
      case AuthStatus.unauthenticated:
        Navigator.pushReplacementNamed(context, '/phone-login');
        break;
      case AuthStatus.authenticated:
        Navigator.pushReplacementNamed(context, '/role-selection');
        break;
      case AuthStatus.roleSelected:
        final role = authProvider.userModel!.role;
        if (role == 'helper' && authProvider.userModel!.profileComplete) {
          Navigator.pushReplacementNamed(context, '/helper-home');
        } else if (role == 'helper') {
          Navigator.pushReplacementNamed(context, '/helper-profile-setup');
        } else if (authProvider.userModel!.profileComplete) {
          Navigator.pushReplacementNamed(context, '/employer-home');
        } else {
          Navigator.pushReplacementNamed(context, '/employer-profile-setup');
        }
        break;
      case AuthStatus.uninitialized:
        break;
    }
  }

  // ── Decorative elements ──────────────────────────────────────────────

  /// Soft translucent cloud blob
  Widget _cloud({
    required double width,
    required double height,
    double opacity = 0.12,
    double borderRadius = 80,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Small sparkle / four-pointed star
  Widget _sparkle({required double size, double opacity = 0.7}) {
    return Text(
      '✦',
      style: TextStyle(
        fontSize: size,
        color: Colors.white.withValues(alpha: opacity),
        height: 1,
      ),
    );
  }

  /// A thin curved line going across the screen (decorative swoosh)
  Widget _swooshLine() {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 80),
      painter: _SwooshPainter(),
    );
  }

  /// Animated equalizer / wave bar loading indicator
  Widget _waveLoader() {
    const int barCount = 5;
    const double barWidth = 3.0;
    const double maxHeight = 20.0;
    const double minHeight = 6.0;
    const double spacing = 4.0;

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(barCount, (i) {
            // Each bar oscillates with a phase offset
            final phase = (i / barCount) * 2 * pi;
            final value = (sin(_waveController.value * 2 * pi + phase) + 1) / 2;
            final height = minHeight + (maxHeight - minHeight) * value;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              width: barWidth,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF7EC8E3), // light sky blue at top
              Color(0xFF3E8ED0), // mid blue
              Color(0xFF1B3A5C), // deep navy at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Cloud cluster (top area, soft & translucent) ──
            Positioned(
              top: -30,
              left: size.width * 0.05,
              child: _cloud(width: 160, height: 90, opacity: 0.10),
            ),
            Positioned(
              top: -10,
              left: size.width * 0.25,
              child: _cloud(width: 220, height: 120, opacity: 0.13),
            ),
            Positioned(
              top: -20,
              right: size.width * 0.05,
              child: _cloud(width: 140, height: 80, opacity: 0.09),
            ),
            // Second layer of clouds (slightly lower, more transparent)
            Positioned(
              top: 40,
              left: size.width * 0.15,
              child: _cloud(width: 180, height: 70, opacity: 0.07),
            ),
            Positioned(
              top: 50,
              right: size.width * 0.1,
              child: _cloud(width: 120, height: 55, opacity: 0.06),
            ),

            // ── Scattered sparkles ──
            Positioned(
              top: size.height * 0.15,
              left: size.width * 0.12,
              child: _sparkle(size: 10, opacity: 0.5),
            ),
            Positioned(
              top: size.height * 0.25,
              right: size.width * 0.08,
              child: _sparkle(size: 16, opacity: 0.6),
            ),
            Positioned(
              top: size.height * 0.38,
              left: size.width * 0.08,
              child: _sparkle(size: 8, opacity: 0.4),
            ),
            Positioned(
              top: size.height * 0.52,
              right: size.width * 0.15,
              child: _sparkle(size: 12, opacity: 0.5),
            ),
            Positioned(
              bottom: size.height * 0.25,
              left: size.width * 0.18,
              child: _sparkle(size: 14, opacity: 0.45),
            ),
            Positioned(
              bottom: size.height * 0.18,
              right: size.width * 0.22,
              child: _sparkle(size: 9, opacity: 0.35),
            ),

            // ── Decorative swoosh line ──
            Positioned(
              top: size.height * 0.32,
              left: 0,
              right: 0,
              child: _swooshLine(),
            ),

            // ── Main content (centered) ──
            SafeArea(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Logo
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Subtle glow behind logo
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            // The actual logo – make sure your PNG has a transparent bg
                            Image.asset(
                              'assets/images/logo.png',
                              width: 170,
                              height: 170,
                              fit: BoxFit.contain,
                            ),
                            // Corner sparkles around logo
                            Positioned(
                              top: 5,
                              right: 12,
                              child: _sparkle(size: 18, opacity: 0.8),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: _sparkle(size: 11, opacity: 0.6),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // App name
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Kaam ',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Sathi',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.tagline,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Wave / equalizer loader at the bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: _waveLoader(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Swoosh line painter ──────────────────────────────────────────────────────

class _SwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.55,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.85,
        size.width,
        size.height * 0.3,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
