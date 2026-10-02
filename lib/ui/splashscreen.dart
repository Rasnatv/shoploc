
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import 'onboaring.dart';

/// First screen when the app opens: logo + tagline on the same sky
/// background as the onboarding screen, then auto-opens onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Logo colors
  static const _blue = Color(0xFF0B7FC4);
  static const _orange = Color(0xFFEE6C0F);

  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    // Wait 2.5 seconds, then open the onboarding screen.
    _timer = Timer(const Duration(milliseconds: 2500), _goNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load the onboarding photo while the splash is showing,
    // so the next screen appears instantly with no flicker.
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage(AppAssets.splashBg), context)
          .catchError((_) {});
    }
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const OnboardingPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidth = math.min(Responsive.width(context) * 0.62, 300.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3D6),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Same sky gradient as the onboarding screen
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFBFE3F5), // light blue
                  Color(0xFFEAF5F8),
                  Color(0xFFFFF3D6), // warm cream
                ],
              ),
            ),
          ),

          // Soft sun glow in the top-left, like the photo
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFE08A).withAlpha(150),
                    const Color(0xFFFFE08A).withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child:
                    Transform.scale(scale: 0.85 + 0.15 * v, child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        width: logoWidth,
                        fit: BoxFit.contain,
                        // Only shown if logo.png is missing
                        errorBuilder: (_, __, ___) => const Text('ShopLoc',
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: _blue)),
                      ),
                      const SizedBox(height: 8),

                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: _orange),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}