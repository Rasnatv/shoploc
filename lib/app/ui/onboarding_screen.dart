import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../widgets/shoploc_logo.dart';


class OnboardingItem {
  final String tag;
  final String categoryTag;
  final String title;
  final String description;
  final String imageUrl;

  const OnboardingItem({
    required this.tag,
    required this.categoryTag,
    required this.title,
    required this.description,
    required this.imageUrl,
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

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      categoryTag: 'DISCOVER 01 OF 03',
      tag: '✨ Trending Fashion & Local Drops',
      title: 'Fashion, Toys &\nEveryday Essentials',
      description:
      'Explore top boutique fashion, kids toys, creative games, and lifestyle essentials curated directly from verified neighborhood stores.',
      imageUrl: 'assets/images/onboarding.jpg',
    ),
    OnboardingItem(
      categoryTag: 'COLLECTION 02 OF 03',
      tag: '🧸 Fun Toys & Kids Zone',
      title: 'Exciting Toys &\nFamily Favorites',
      description:
      'From educational STEM puzzles, board games, and RC cars to cuddly soft toys and baby essentials — delighting every child and family.',
      imageUrl: 'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      categoryTag: 'EXPERIENCE 03 OF 03',
      tag: '🚀 Shop Local • Shop Smart',
      title: 'Direct From Local Stores\nTo Your Doorstep',
      description:
      'Support your favorite neighborhood boutiques, toy shops, and local makers across Kerala & India with fast, trackable doorstep delivery.',
      imageUrl: 'assets/images/ondelivered.png',
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
                      final double cardScale = 1.0 - (diff * 0.08);
                      final double cardOpacity = 1.0 - (diff * 0.25);
                      final double parallaxX = (_pageValue - index) * 35.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            Transform.scale(
                              scale: cardScale,
                              child: Opacity(
                                opacity: cardOpacity,
                                child: Container(
                                  height:
                                  (size.height * 0.44).clamp(260.0, 400.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandBlue
                                            .withValues(alpha: 0.12),
                                        blurRadius: 26,
                                        offset: const Offset(0, 12),
                                        spreadRadius: 1,
                                      ),
                                      const BoxShadow(
                                        color: AppColors.shadowMedium,
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(parallaxX, 0),
                                        child: Image.asset(
                                          page.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
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
                                      Positioned(
                                        bottom: 14,
                                        left: 14,
                                        right: 14,
                                        child: FadeTransition(
                                          opacity: _badgeFadeAnimation,
                                          child: SlideTransition(
                                            position: _badgeSlideAnimation,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.65),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.35),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    page.tag,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      letterSpacing: 0.4,
                                                    ),
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
                              ),
                            ),

                            const SizedBox(height: 24),

                            FadeTransition(
                              opacity: _badgeFadeAnimation,
                              child: SlideTransition(
                                position: _badgeSlideAnimation,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandOrange
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    page.categoryTag,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.8,
                                      color: AppColors.brandOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

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