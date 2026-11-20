
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';
import 'package:shoploc/app/ui/trendingscreen.dart';
import '../bloc/homebloc/home_bloc.dart';
import '../bloc/homebloc/home_event.dart';
import '../bloc/homebloc/home_state.dart';
import '../core/utils/object_factory.dart';
import '../bloc/recentview/recentview_bloc.dart';
import '../bloc/recentview/recentview_event.dart';
import '../bloc/recentview/recentview_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/productlisttype.dart';
import '../data/models/apibannermodel.dart';
import '../data/models/homemodel.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/product_card.dart';
import '../widgets/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/shoploc_logo.dart';
import 'bestsellerscreen.dart';
import 'categories_screen.dart';
import 'newarrivalscreen.dart';
import 'recentviewscreen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToCategory;
  const HomeScreen({super.key, required this.onNavigateToCategory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Banner carousel
  final PageController _bannerController = PageController(viewportFraction: 0.92);
  Timer? _bannerTimer;
  int _activeBanner = 0;
  int _bannerCount = 0; // updated whenever banners are drawn

  // Recently viewed (top few) for the Home section
  final RecentViewBloc _recentBloc = RecentViewBloc();

  // Horizontal padding shared with SectionHeader (kept at 16 on every screen
  // size so lists, grid and headers stay aligned).
  static const double _hPad = 16;

  // ---------------- RESPONSIVE HELPERS ----------------

  /// Scale factor for phone widths only (320-480). Responsive.w() keeps
  /// growing on tablets, which would make things oversized there.
  double get _scale =>
      (Responsive.screenWidth.clamp(320.0, 480.0)).toDouble() / 390.0;

  double _w(double designValue) => designValue * _scale;

  /// Max width of the page content on big screens.
  double get _maxContentWidth => Responsive.value(
    mobile: double.infinity,
    tablet: 840.0,
    desktop: 1100.0,
  );

  /// Banner shape: wider/flatter on big screens so it isn't huge.
  double get _bannerAspect => Responsive.value(
    mobile: 16 / 7,
    tablet: 3.0,
    desktop: 3.4,
  );

  double get _categoryCircle => Responsive.value(
    mobile: _w(64),
    tablet: 76.0,
    desktop: 84.0,
  );

  /// Height of the category strip = circle + gap + two lines of label.
  double get _categoryListHeight =>
      _categoryCircle + _w(6) + Responsive.sp(11) * 3.2;

  /// Product card width in the horizontal lists (phone value unchanged).
  double get _productCardWidth => Responsive.value(
    mobile: 165.0,
    tablet: 190.0,
    desktop: 210.0,
  );

  /// Keeps the original 165 x 260 card proportion.
  double get _productListHeight => _productCardWidth * (260 / 165);

  int get _bestSellerColumns => Responsive.value(
    mobile: 2,
    tablet: 4,
    desktop: 4,
  );

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
    _recentBloc.add(const LoadRecentViewsEvent());

    // Auto-slide every 4 seconds (only when there is more than one banner)
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerCount < 2 || !_bannerController.hasClients) return;
      final next = (_activeBanner + 1) % _bannerCount;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _recentBloc.close();
    super.dispose();
  }

  // ---- Navigation hooks ----
  Future<void> _openProduct(HomeProductModel product) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: product.id)));
    // The product was saved as "recently viewed" -> refresh the section
    if (mounted) _recentBloc.add(const RefreshRecentViewsEvent());
  }

  /// Opens the Categories page with [category] already selected.
  /// For a subcategory pill, pass its PARENT category.
  void _openCategory(CategoryApiModel category) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CategoriesScreen(initialCategory: category),
    ));
  }

  void _openSearch() {
    // TODO: open search screen
  }

  Future<void> _seeAll(ProductListType type) async {
    final Widget page;
    switch (type) {
      case ProductListType.newArrivals:
        page = const NewArrivalsScreen();
        break;
      case ProductListType.trending:
        page = const TrendingScreen();
        break;
      case ProductListType.bestSellers:
        page = const BestSellersScreen();
        break;
      case ProductListType.recentViews:
        page = const RecentViewsScreen();
        break;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) _recentBloc.add(const RefreshRecentViewsEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HomeBloc>();
    bloc.add(const RefreshHomeDataEvent());
    _recentBloc.add(const RefreshRecentViewsEvent());
    await bloc.stream.first;
  }

  @override
  Widget build(BuildContext context) {
    // Refresh screen metrics (re-runs on rotation / window resize).
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 16,
        title: const ShoplocLogo(fontSize: 50),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
            onPressed: () {
              // TODO: notifications screen
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadingState || state is HomeInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is HomeErrorState) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(_w(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: _w(44), color: AppColors.textTertiary),
                    SizedBox(height: _w(12)),
                    Text('Failed to load collections',
                        style: AppTextStyle.sectionHeading),
                    SizedBox(height: _w(6)),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption,
                    ),
                    SizedBox(height: _w(14)),
                    ElevatedButton(
                      onPressed: () => context
                          .read<HomeBloc>()
                          .add(const LoadHomeDataEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoadedState) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // Centers and caps the content width on tablet/desktop.
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        if (state.banners.isNotEmpty) ...[
                          _buildBannerCarousel(state.banners),
                          const SizedBox(height: 20),
                        ],
                        if (state.categories.isNotEmpty) ...[
                          _buildCategoriesSection(state),
                          const SizedBox(height: 5),
                        ],
                        if (state.newArrivals.isNotEmpty) ...[
                          _buildHorizontalSection(
                            title: 'New Arrivals',
                            subtitle: 'Fresh drops across fashion & lifestyle',
                            products: state.newArrivals,
                            type: ProductListType.newArrivals,
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (state.trendingProducts.isNotEmpty) ...[
                          _buildHorizontalSection(
                            title: 'Trending Right Now',
                            subtitle: 'Most coveted pieces this season',
                            products: state.trendingProducts,
                            type: ProductListType.trending,
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Recently Viewed (hidden when empty / not logged in)
                        BlocBuilder<RecentViewBloc, RecentViewState>(
                          bloc: _recentBloc,
                          builder: (context, rs) {
                            // Only for logged-in users (auth token)
                            if (!ObjectFactory().prefs.hasAuthToken ||
                                rs is! RecentViewLoadedState ||
                                rs.products.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHorizontalSection(
                                  title: 'Recently Viewed',
                                  subtitle: 'Pick up where you left off',
                                  products: rs.products,
                                  type: ProductListType.recentViews,
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        if (state.bestSellers.isNotEmpty) ...[
                          _buildBestSellersGrid(state.bestSellers),
                          const SizedBox(height: 28),
                        ],
                        if (state.newArrivals.isEmpty &&
                            state.trendingProducts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text('No products available yet.',
                                  style: AppTextStyle.caption),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------- SEARCH ----------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 4),
      child: GestureDetector(
        onTap: _openSearch,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search "Co-Ord Sets", "Kurta", "Dresses"...',
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

  // ---------------- BANNERS ----------------
  Widget _buildBannerCarousel(List<BannerApiModel> banners) {
    _bannerCount = banners.length;
    final active = _activeBanner.clamp(0, banners.length - 1);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _bannerAspect, // change if your banner images differ
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _activeBanner = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                    child: _image(banners[index].image),
                  ),
                ),
              );
            },
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final isActive = i == active;
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
      ],
    );
  }

  // ---------------- CATEGORIES ----------------
  Widget _buildCategoriesSection(HomeLoadedState state) {
    final circle = _categoryCircle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Shop by Category',
          subtitle: 'Fashion & lifestyle finds',
          actionText: 'View All',
          onActionTap: widget.onNavigateToCategory,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: _categoryListHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: _hPad),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              // Parent categories have an empty image -> use first child's image
              final image = cat.image.isNotEmpty
                  ? cat.image
                  : (cat.children.isNotEmpty ? cat.children.first.image : '');
              return GestureDetector(
                onTap: () => _openCategory(cat),
                child: SizedBox(
                  width: circle + 8,
                  child: Column(
                    children: [
                      Container(
                        height: circle,
                        width: circle,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.borderLight, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: AppColors.shadow, blurRadius: 6),
                          ],
                        ),
                        child: ClipOval(
                            child: _image(image,
                                fallbackIcon: Icons.category_outlined)),
                      ),
                      SizedBox(height: _w(6)),
                      Text(
                        cat.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.sp(11),
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

  // ---------------- PRODUCT SECTIONS ----------------
  Widget _buildHorizontalSection({
    required String title,
    required String subtitle,
    required List<HomeProductModel> products,
    required ProductListType type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          actionText: 'See All',
          onActionTap: () => _seeAll(type),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _productListHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: _hPad),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => SizedBox(
              width: _productCardWidth,
              child: HomeProductCard(
                product: products[i],
                onTap: () => _openProduct(products[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestSellersGrid(List<HomeProductModel> products) {
    final items = products.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Best Sellers',
          subtitle: 'Customer favorites loved across India',
          actionText: 'View All',
          onActionTap: () => _seeAll(ProductListType.bestSellers),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _hPad),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            // 2 columns on phones, 4 on tablet/desktop (one row of 4).
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _bestSellerColumns,
              childAspectRatio: 0.66,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (_, i) => HomeProductCard(
              product: items[i],
              onTap: () => _openProduct(items[i]),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- HELPERS ----------------
  Widget _image(String url, {IconData fallbackIcon = Icons.image_outlined}) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.blush,
        child: Icon(fallbackIcon, color: AppColors.textTertiary, size: 26),
      );
    }
    return NetworkImageWithFallback(imageUrl: url, fit: BoxFit.cover);
  }
}