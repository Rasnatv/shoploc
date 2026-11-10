import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'main_bottom_nav_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _footerFade;
  late Animation<double> _auraScale;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation for the official logo and brand text
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Spring scale for the official logo
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Smooth fade in
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Gentle upward slide for logo
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Staggered tagline fade and slide
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    // Footer fade
    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // 2. Continuous breathing aura animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _auraScale = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
    _checkNextScreen();
  }

  Future<void> _checkNextScreen() async {
    final storage = await LocalStorageService.getInstance();

    _navTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final bool onboardingComplete = storage.isOnboardingComplete();

      if (onboardingComplete) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const MainBottomNavScreen(),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const OnboardingScreen(),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Ambient background decorative blobs
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandBlue.withValues(alpha: 0.12),
                    AppColors.brandBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandOrange.withValues(alpha: 0.12),
                    AppColors.brandOrange.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Center: Hero Official Shoploc Logo with Animated Glow
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Breathing Glow + Official Logo Card
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Breathing Aura Glow
                    AnimatedBuilder(
                      animation: _auraScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _auraScale.value,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.brandOrange.withValues(alpha: 0.18),
                                  AppColors.brandBlue.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Official Shoploc Logo Card with Spring Entrance
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 22,
                            ),

                            child: Image.asset(
                              'assets/images/shoploclogonew.png',
                              height: 100,
                              fit: BoxFit.contain,
                              semanticLabel: 'Shoploc Official Logo',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Animated Tagline & Description
                FadeTransition(
                  opacity: _taglineFade,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Column(
                      children: [
                        Text(
                          'SHOP LOCAL • SHOP SMART',
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.8,
                            color: AppColors.brandOrange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Women's Fashion & Boutique",
                          style: AppTextStyle.bodySmall.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom: Animated Loader & Branding Footer
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _footerFade,
              child: Column(
                children: [
                  // Sleek dual-color pulsing dots loader
                  const _PulsingDotsIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appTagline,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smooth 3-dot pulsating indicator using Shoploc brand colors.
class _PulsingDotsIndicator extends StatefulWidget {
  const _PulsingDotsIndicator();

  @override
  State<_PulsingDotsIndicator> createState() => _PulsingDotsIndicatorState();
}

class _PulsingDotsIndicatorState extends State<_PulsingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double delay = index * 0.25;
            final double progress = (_dotController.value - delay).clamp(0.0, 1.0);
            final double scale = 0.6 + (0.5 * (1.0 - (progress - 0.5).abs() * 2));
            final Color dotColor = index == 1
                ? AppColors.brandOrange
                : AppColors.brandBlue;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
