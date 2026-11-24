import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../widgets/shoploc_logo.dart';

class OnboardingItem {
  final String tag;
  final String title;
  final String description;
  final String imageUrl;
  final Color accent;

  const OnboardingItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.accent,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  double _pageValue = 0.0;

  late final AnimationController _textAnimController;
  late final Animation<double> _badgeFadeAnimation;
  late final Animation<Offset> _badgeSlideAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _descFadeAnimation;
  late final Animation<Offset> _descSlideAnimation;

  late final AnimationController _ambientController;
  late final Animation<double> _ambientAnimation;

  // Put these 3 images in assets/images/ with exactly these names
  // (or change the names below):
  //   onboarding_shop.png      -> phone with store awning, dress & teddy
  //   onboarding_cart.png      -> shopping cart with colourful bags
  //   onboarding_delivery.png  -> ShopLoc delivery rider on scooter
  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      tag: '🏪 Welcome to ShopLoc',
      title: 'Our Store,\nNow On Your Phone',
      description:
      'Everything from our store, now on your phone. Browse what you like and order with ease.',
      imageUrl: 'assets/images/onbaording/onboarding1.png',
      accent: AppColors.brandBlue,
    ),
    OnboardingItem(
      tag: '⚡ Quick & Easy Ordering',
      title: 'Pick What You Love,\nOrder In Seconds',
      description:
      'Add your favourite items to the cart and complete your order in just a few taps. Simple and smooth.',
      imageUrl: 'assets/images/onbaording/onbaording2.png',
      accent: AppColors.brandOrange,
    ),
    OnboardingItem(
      tag: '🛵 Fast Local Delivery',
      title: 'Delivered To Your\nDoorstep, Fast',
      description:
      'A ShopLoc rider brings your order straight from our store to your door, with easy tracking.',
      imageUrl: 'assets/images/onbaording/onboarding3.png',
      accent: AppColors.brandBlue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() => _pageValue = _pageController.page ?? 0.0);
      }
    });

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _badgeFadeAnimation = CurvedAnimation(
      parent: _textAnimController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(_badgeFadeAnimation);

    _titleFadeAnimation = CurvedAnimation(
      parent: _textAnimController,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(_titleFadeAnimation);

    _descFadeAnimation = CurvedAnimation(
      parent: _textAnimController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _descSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(_descFadeAnimation);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _ambientAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOutSine,
    );

    _textAnimController.forward();
  }

  /// Marks onboarding done, then opens the Register screen.
  /// The Play Store referral code is autofilled there.
  void _completeOnboarding() {
    ObjectFactory().prefs.setOnboardingComplete(true);
    if (!mounted) return;
    context.go('/auth', extra: {
      'isRegister': true,
      'fromOnboarding': true,
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textAnimController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Ambient background glows
          AnimatedBuilder(
            animation: _ambientAnimation,
            builder: (context, child) {
              final floatY = _ambientAnimation.value * 14.0;
              final floatScale = 1.0 + (_ambientAnimation.value * 0.06);

              return Stack(
                children: [
                  Positioned(
                    top: -80 + floatY,
                    right: -60,
                    child: Transform.scale(
                      scale: floatScale,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.brandBlue.withValues(alpha: 0.09),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60 - floatY,
                    left: -80,
                    child: Transform.scale(
                      scale: floatScale,
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.brandOrange.withValues(alpha: 0.09),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Header: logo + skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShoplocLogo(height: 50, showTagline: false),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isLastPage ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: isLastPage,
                          child: GestureDetector(
                            onTap: _completeOnboarding,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Skip',
                                    style: AppTextStyle.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: AppColors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _textAnimController.forward(from: 0.0);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      final double diff =
                      (_pageValue - index).abs().clamp(0.0, 1.0);
                      final double imgScale = 1.0 - (diff * 0.10);
                      final double imgOpacity = 1.0 - (diff * 0.45);
                      final double parallaxX = (_pageValue - index) * 45.0;

                      final double imageAreaHeight =
                      (size.height * 0.42).clamp(270.0, 400.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            // Illustration area
                            Transform.scale(
                              scale: imgScale,
                              child: Opacity(
                                opacity: imgOpacity,
                                child: SizedBox(
                                  height: imageAreaHeight,
                                  width: double.infinity,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Soft colour blob behind the image
                                      Transform.translate(
                                        offset: Offset(parallaxX * 0.4, 0),
                                        child: Container(
                                          width: imageAreaHeight * 0.88,
                                          height: imageAreaHeight * 0.88,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                page.accent
                                                    .withValues(alpha: 0.16),
                                                page.accent
                                                    .withValues(alpha: 0.04),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Floating illustration
                                      AnimatedBuilder(
                                        animation: _ambientAnimation,
                                        builder: (context, child) {
                                          final floatY =
                                              (_ambientAnimation.value - 0.5) *
                                                  12.0;
                                          return Transform.translate(
                                            offset: Offset(parallaxX, floatY),
                                            child: child,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 22),
                                          child: Image.asset(
                                            page.imageUrl,
                                            fit: BoxFit.contain,
                                            height: imageAreaHeight - 22,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      // Tag chip
                                      Positioned(
                                        bottom: 0,
                                        child: FadeTransition(
                                          opacity: _badgeFadeAnimation,
                                          child: SlideTransition(
                                            position: _badgeSlideAnimation,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: page.accent
                                                      .withValues(alpha: 0.35),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: page.accent
                                                        .withValues(
                                                        alpha: 0.18),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                page.tag,
                                                style: TextStyle(
                                                  color: page.accent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Title
                            FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: SlideTransition(
                                position: _titleSlideAnimation,
                                child: Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.mainHeading.copyWith(
                                    fontSize: (size.width * 0.062)
                                        .clamp(21.0, 26.0),
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Description
                            FadeTransition(
                              opacity: _descFadeAnimation,
                              child: SlideTransition(
                                position: _descSlideAnimation,
                                child: ConstrainedBox(
                                  constraints:
                                  const BoxConstraints(maxWidth: 330),
                                  child: Text(
                                    page.description,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.description.copyWith(
                                      fontSize: 13,
                                      height: 1.45,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 6),
                            height: 7,
                            width: isActive ? 28 : 7,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.brandOrange
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                BoxShadow(
                                  color: AppColors.brandOrange
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                          );
                        }),
                      ),

                      GestureDetector(
                        onTap: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastPage ? 22 : 18,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLastPage
                                  ? [
                                AppColors.brandOrange,
                                const Color(0xFFFF851B),
                              ]
                                  : [
                                AppColors.brandBlue,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: (isLastPage
                                    ? AppColors.brandOrange
                                    : AppColors.brandBlue)
                                    .withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                child:
                                Text(isLastPage ? 'Get Started' : 'Next'),
                              ),
                              const SizedBox(width: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isLastPage
                                      ? Icons.shopping_bag_outlined
                                      : Icons.arrow_forward_rounded,
                                  key: ValueKey<bool>(isLastPage),
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}