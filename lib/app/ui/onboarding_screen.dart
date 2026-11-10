import 'package:flutter/material.dart';
import '../core/storage/local_storage_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/shoploc_logo.dart';
import 'main_bottom_nav_screen.dart';

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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      categoryTag: 'COLLECTION 01 OF 03',
      tag: '✨ Handpicked Boutique Drops',
      title: 'Discover Handcrafted\nWomen\'s Fashion',
      description:
      'Connect with regional artisans and boutiques. Explore breezy Co-Ord sets, tailored Kurtas, and contemporary festive silhouettes.',
      imageUrl:
      'assets/images/onboarding.jpg',
    ),
    OnboardingItem(
      categoryTag: 'COLLECTION 02 OF 03',
      tag: '🌿 Minimalist Fashion',
      title: 'Trending Styles,\nTailored Comfort',
      description:
      'Experience curated drops with breathable fabrics, artisanal block prints, and flattering fits designed to elevate your everyday wardrobe.',
      imageUrl:
      'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      categoryTag: 'COLLECTION 03 OF 03',
      tag: '🚀 Shop Local • Shop Smart',
      title: 'Seamless Shopping,\nDelivered with Love',
      description:
      'Direct boutique-to-doorstep delivery across Kerala & India with verified secure checkout, live order tracking, and instant support.',
      imageUrl:
      'assets/images/ondelivered.png',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final storage = await LocalStorageService.getInstance();
    await storage.setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainBottomNavScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          // Ambient soft background decor circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandOrange.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                // Top Header: Official Shoploc Logo + Skip Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Official Logo
                      const ShoplocLogo(
                        height: 50,
                        showTagline: false,
                      ),

                      // Skip Pill Button
                      if (!isLastPage)
                        GestureDetector(
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
                        )
                      else
                        const SizedBox(height: 32, width: 60),
                    ],
                  ),
                ),

                // Main Page View (Hero Card + Typography)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            // Hero Fashion Card
                            Container(
                              height: (size.height * 0.44).clamp(260.0, 400.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandBlue.withValues(alpha: 0.10),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
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
                                  Image.asset(
                                    page.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported_outlined, size: 40),
                                      );
                                    },
                                  ),
                                  // Floating Tag Badge on Image
                                  Positioned(
                                    bottom: 14,
                                    left: 14,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.35),
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
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Collection Index Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandOrange.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                page.categoryTag,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                  color: AppColors.brandOrange,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Main Editorial Title
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.mainHeading.copyWith(
                                fontSize: (size.width * 0.062).clamp(21.0, 26.0),
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Description
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 330),
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

                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Bar: Animated Indicators + Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sleek Animated Dot Indicators
                      Row(
                        children: List.generate(_pages.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
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
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                          );
                        }),
                      ),

                      // Next / Get Started Action Button
                      GestureDetector(
                        onTap: () {
                          if (isLastPage) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isLastPage ? 22 : 18,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLastPage
                                  ? [AppColors.brandOrange, const Color(0xFFFF851B)]
                                  : [AppColors.brandBlue, AppColors.primaryDark],
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
                              Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? Icons.shopping_bag_outlined
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
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
