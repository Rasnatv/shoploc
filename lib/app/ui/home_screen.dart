import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/homebloc/home_bloc.dart';
import '../bloc/homebloc/home_event.dart';
import '../bloc/homebloc/home_state.dart';
import '../bloc/notificationbloc/notification_bloc.dart';
import '../bloc/notificationbloc/notification_state.dart';
import '../bloc/productbloc/product_bloc.dart';
import '../bloc/productbloc/product_event.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shoploc_logo.dart';
import 'notifications_screen.dart';
import 'product_details_screen.dart';
import 'product_list_screen.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCategory;
  const HomeScreen({super.key, required this.onNavigateToCategory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _activeBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        titleSpacing: 16,
        title: const ShoplocLogo(fontSize: 50),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              final unread = notifState is NotificationLoadedState ? notifState.unreadCount : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$unread',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.badgeText.copyWith(fontSize: 8),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is HomeErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load collections', style: AppTextStyle.sectionHeading),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<HomeBloc>().add(const LoadHomeDataEvent()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoadedState) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(context),

                    const SizedBox(height: 12),

                    // Hero Banner Carousel
                    _buildBannerCarousel(state),

                    const SizedBox(height: 20),

                    // Shop by Categories
                    _buildCategoriesSection(state),

                    const SizedBox(height: 10),

                    // New Arrivals
                    _buildHorizontalProductSection(
                      title: 'New Arrivals',
                      subtitle: 'Fresh silhouettes for the modern woman',
                      products: state.newArrivals,
                    ),

                    const SizedBox(height: 24),

                    // Trending Products
                    _buildHorizontalProductSection(
                      title: 'Trending Right Now',
                      subtitle: 'Most coveted pieces this season',
                      products: state.trendingProducts,
                    ),

                    const SizedBox(height: 24),

                    // Special Offer Banner Strip
                    _buildSpecialOfferStrip(context),

                    const SizedBox(height: 24),

                    // Best Sellers Grid
                    _buildBestSellersGrid(state),

                    const SizedBox(height: 24),

                    // Recently Viewed
                    if (state.recentlyViewed.isNotEmpty) ...[
                      _buildHorizontalProductSection(
                        title: 'Recently Viewed',
                        subtitle: 'Continue exploring what you loved',
                        products: state.recentlyViewed,
                      ),
                      const SizedBox(height: 24),
                    ],


                    const SizedBox(height: 28),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProductListScreen(autoFocusSearch: true),
            ),
          );
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search "Co-ord sets", "Kurta", "Linen dress"...',
                  style: AppTextStyle.inputHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(HomeLoadedState state) {
    if (state.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: state.banners.length,
            onPageChanged: (i) => setState(() => _activeBannerIndex = i),
            itemBuilder: (context, index) {
              final banner = state.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    if (banner.categoryId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            initialCategoryId: banner.categoryId,
                            categoryTitle: banner.title,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          NetworkImageWithFallback(
                            imageUrl: banner.imageUrl,
                            fit: BoxFit.cover,
                          ),
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.75),
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (banner.discountText != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      banner.discountText!,
                                      style: AppTextStyle.badgeText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  banner.title,
                                  style: AppTextStyle.sectionHeading.copyWith(
                                    color: AppColors.textLight,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  banner.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.caption.copyWith(
                                    color: AppColors.textLight.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.banners.length, (index) {
            final isActive = index == _activeBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: isActive ? 18 : 5,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(HomeLoadedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Handpicked Indian fashion edits',
          actionText: 'View All',
          onActionTap: widget.onNavigateToCategory,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 105,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductListScreen(
                        initialCategoryId: cat.id,
                        categoryTitle: cat.name,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: NetworkImageWithFallback(
                            imageUrl: cat.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalProductSection({
    required String title,
    required String subtitle,
    required List<dynamic> products,
  }) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        final wishlistIds = wishlistState is WishlistLoadedState
            ? wishlistState.items.map((p) => p.id).toSet()
            : <String>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: title,
              subtitle: subtitle,
              actionText: 'See All',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductListScreen(categoryTitle: title),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isWishlisted = wishlistIds.contains(product.id);

                  return SizedBox(
                    width: 165,
                    child: ProductCard(
                      product: product,
                      isWishlisted: isWishlisted,
                      onTap: () {
                        context.read<ProductBloc>().add(
                              LoadProductDetailsEvent(productId: product.id),
                            );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      onWishlistTap: () {
                        context.read<WishlistBloc>().add(
                              ToggleWishlistEvent(product: product),
                            );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecialOfferStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flat 10% OFF with "SHOPLOC10"',
                    style: AppTextStyle.labelLarge.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Applicable on all Co-Ord Sets & Kurtas above ₹999.',
                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellersGrid(HomeLoadedState state) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        final wishlistIds = wishlistState is WishlistLoadedState
            ? wishlistState.items.map((p) => p.id).toSet()
            : <String>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Best Sellers',
              subtitle: 'Customer favorites loved across India',
              actionText: 'View All',
              onActionTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(categoryTitle: 'Best Sellers'),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.bestSellers.take(4).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final product = state.bestSellers[index];
                  final isWishlisted = wishlistIds.contains(product.id);

                  return ProductCard(
                    product: product,
                    isWishlisted: isWishlisted,
                    onTap: () {
                      context.read<ProductBloc>().add(
                            LoadProductDetailsEvent(productId: product.id),
                          );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    onWishlistTap: () {
                      context.read<WishlistBloc>().add(
                            ToggleWishlistEvent(product: product),
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildPromisePill(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyle.caption.copyWith(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
