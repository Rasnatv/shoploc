// // //
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_bloc/flutter_bloc.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import '../bloc/homebloc/home_bloc.dart';
// // // import '../bloc/homebloc/home_event.dart';
// // // import '../bloc/homebloc/home_state.dart';
// // // import '../bloc/notificationbloc/notification_bloc.dart';
// // // import '../bloc/notificationbloc/notification_state.dart';
// // // import '../bloc/productbloc/product_bloc.dart';
// // // import '../bloc/productbloc/product_event.dart';
// // // import '../bloc/whishlistbloc/wishlist_bloc.dart';
// // // import '../bloc/whishlistbloc/wishlist_event.dart';
// // // import '../bloc/whishlistbloc/wishlist_state.dart';
// // // import '../core/theme/app_colors.dart';
// // // import '../core/theme/app_text_style.dart';
// // // import '../widgets/network_image_with_fallback.dart';
// // // import '../widgets/product_card.dart';
// // // import '../widgets/section_header.dart';
// // // import '../widgets/shoploc_logo.dart';
// // // import 'enquiry_screen.dart';
// // // import 'notifications_screen.dart';
// // // import 'product_details_screen.dart';
// // // import 'product_list_screen.dart';
// // //
// // //
// // // class HomeScreen extends StatefulWidget {
// // //   final VoidCallback onNavigateToCategory;
// // //   const HomeScreen({super.key, required this.onNavigateToCategory});
// // //
// // //   @override
// // //   State<HomeScreen> createState() => _HomeScreenState();
// // // }
// // //
// // // class _HomeScreenState extends State<HomeScreen> {
// // //   final PageController _bannerController = PageController();
// // //   int _activeBannerIndex = 0;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     context.read<HomeBloc>().add(const LoadHomeDataEvent());
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _bannerController.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: AppColors.scaffoldBackground,
// // //       appBar: AppBar(
// // //         titleSpacing: 16,
// // //         title: const ShoplocLogo(fontSize: 50),
// // //         actions: [
// // //           BlocBuilder<NotificationBloc, NotificationState>(
// // //             builder: (context, notifState) {
// // //               final unread = notifState is NotificationLoadedState ? notifState.unreadCount : 0;
// // //               return Stack(
// // //                 children: [
// // //                   IconButton(
// // //                     icon: const Icon(Icons.notifications_none_rounded, size: 24),
// // //                     onPressed: () {
// // //                       Navigator.of(context).push(
// // //                         MaterialPageRoute(builder: (_) => const NotificationsScreen()),
// // //                       );
// // //                     },
// // //                   ),
// // //                   if (unread > 0)
// // //                     Positioned(
// // //                       top: 10,
// // //                       right: 12,
// // //                       child: Container(
// // //                         padding: const EdgeInsets.all(3),
// // //                         decoration: const BoxDecoration(
// // //                           color: AppColors.primary,
// // //                           shape: BoxShape.circle,
// // //                         ),
// // //                         constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
// // //                         child: Text(
// // //                           '$unread',
// // //                           textAlign: TextAlign.center,
// // //                           style: AppTextStyle.badgeText.copyWith(fontSize: 8),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                 ],
// // //               );
// // //             },
// // //           ),
// // //           const SizedBox(width: 6),
// // //         ],
// // //       ),
// // //       body: BlocBuilder<HomeBloc, HomeState>(
// // //         builder: (context, state) {
// // //           if (state is HomeLoadingState) {
// // //             return const Center(
// // //               child: CircularProgressIndicator(
// // //                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
// // //               ),
// // //             );
// // //           }
// // //
// // //           if (state is HomeErrorState) {
// // //             return Center(
// // //               child: Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   Text('Failed to load collections', style: AppTextStyle.sectionHeading),
// // //                   const SizedBox(height: 12),
// // //                   ElevatedButton(
// // //                     onPressed: () => context.read<HomeBloc>().add(const LoadHomeDataEvent()),
// // //                     child: const Text('Try Again'),
// // //                   ),
// // //                 ],
// // //               ),
// // //             );
// // //           }
// // //
// // //           if (state is HomeLoadedState) {
// // //             return RefreshIndicator(
// // //               color: AppColors.primary,
// // //               onRefresh: () async {
// // //                 context.read<HomeBloc>().add(const RefreshHomeDataEvent());
// // //               },
// // //               child: SingleChildScrollView(
// // //                 physics: const AlwaysScrollableScrollPhysics(),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     // Search Bar
// // //                     _buildSearchBar(context),
// // //
// // //                     const SizedBox(height: 12),
// // //
// // //                     // Hero Banner Carousel
// // //                     _buildBannerCarousel(state),
// // //
// // //                     const SizedBox(height: 20),
// // //
// // //                     // Shop by Categories
// // //                     _buildCategoriesSection(state),
// // //
// // //                     const SizedBox(height: 24),
// // //
// // //                     // New Arrivals
// // //                     _buildHorizontalProductSection(
// // //                       title: 'New Arrivals',
// // //                       subtitle: 'Fresh drops across fashion, toys & lifestyle',
// // //                       products: state.newArrivals,
// // //                     ),
// // //
// // //                     const SizedBox(height: 24),
// // //
// // //                     // Trending Products
// // //                     _buildHorizontalProductSection(
// // //                       title: 'Trending Right Now',
// // //                       subtitle: 'Most coveted pieces this season',
// // //                       products: state.trendingProducts,
// // //                     ),
// // //
// // //                     const SizedBox(height: 24),
// // //
// // //                     // Special Offer Banner Strip
// // //                     _buildSpecialOfferStrip(context),
// // //
// // //                     const SizedBox(height: 24),
// // //
// // //                     // Best Sellers Grid
// // //                     _buildBestSellersGrid(state),
// // //
// // //                     const SizedBox(height: 24),
// // //
// // //                     // Recently Viewed
// // //                     if (state.recentlyViewed.isNotEmpty) ...[
// // //                       _buildHorizontalProductSection(
// // //                         title: 'Recently Viewed',
// // //                         subtitle: 'Continue exploring what you loved',
// // //                         products: state.recentlyViewed,
// // //                       ),
// // //                       const SizedBox(height: 24),
// // //                     ],
// // //
// // //                     // Web-Replica Enquiry Banner
// // //                     _buildEnquiryBanner(context),
// // //
// // //                     const SizedBox(height: 28),
// // //                   ],
// // //                 ),
// // //               ),
// // //             );
// // //           }
// // //
// // //           return const SizedBox.shrink();
// // //         },
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildSearchBar(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// // //       child: GestureDetector(
// // //         onTap: () {
// // //           Navigator.of(context).push(
// // //             MaterialPageRoute(
// // //               builder: (_) => const ProductListScreen(autoFocusSearch: true),
// // //             ),
// // //           );
// // //         },
// // //         child: Container(
// // //           height: 48,
// // //           padding: const EdgeInsets.symmetric(horizontal: 14),
// // //           decoration: BoxDecoration(
// // //             color: AppColors.surface,
// // //             borderRadius: BorderRadius.circular(10),
// // //             border: Border.all(color: AppColors.borderLight),
// // //             boxShadow: const [
// // //               BoxShadow(
// // //                 color: AppColors.shadow,
// // //                 blurRadius: 6,
// // //                 offset: Offset(0, 2),
// // //               ),
// // //             ],
// // //           ),
// // //           child: Row(
// // //             children: [
// // //               const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
// // //               const SizedBox(width: 10),
// // //               Expanded(
// // //                 child: Text(
// // //                   'Search "Toys", "Dresses", "Board games", "Kids"...',
// // //                   style: AppTextStyle.inputHint,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                 ),
// // //               ),
// // //               Container(
// // //                 height: 20,
// // //                 width: 1,
// // //                 color: AppColors.divider,
// // //                 margin: const EdgeInsets.symmetric(horizontal: 8),
// // //               ),
// // //               const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildBannerCarousel(HomeLoadedState state) {
// // //     if (state.banners.isEmpty) return const SizedBox.shrink();
// // //
// // //     return Column(
// // //       children: [
// // //         SizedBox(
// // //           height: 180,
// // //           child: PageView.builder(
// // //             controller: _bannerController,
// // //             itemCount: state.banners.length,
// // //             onPageChanged: (i) => setState(() => _activeBannerIndex = i),
// // //             itemBuilder: (context, index) {
// // //               final banner = state.banners[index];
// // //               return Padding(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 child: GestureDetector(
// // //                   onTap: () {
// // //                     if (banner.categoryId != null) {
// // //                       Navigator.of(context).push(
// // //                         MaterialPageRoute(
// // //                           builder: (_) => ProductListScreen(
// // //                             initialCategoryId: banner.categoryId,
// // //                             categoryTitle: banner.title,
// // //                           ),
// // //                         ),
// // //                       );
// // //                     }
// // //                   },
// // //                   child: Container(
// // //                     decoration: BoxDecoration(
// // //                       borderRadius: BorderRadius.circular(16),
// // //                       boxShadow: const [
// // //                         BoxShadow(
// // //                           color: AppColors.shadowMedium,
// // //                           blurRadius: 10,
// // //                           offset: Offset(0, 4),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     child: ClipRRect(
// // //                       borderRadius: BorderRadius.circular(16),
// // //                       child: Stack(
// // //                         fit: StackFit.expand,
// // //                         children: [
// // //                           NetworkImageWithFallback(
// // //                             imageUrl: banner.imageUrl,
// // //                             fit: BoxFit.cover,
// // //                           ),
// // //                           // Gradient Overlay
// // //                           Container(
// // //                             decoration: BoxDecoration(
// // //                               gradient: LinearGradient(
// // //                                 colors: [
// // //                                   Colors.black.withValues(alpha: 0.75),
// // //                                   Colors.black.withValues(alpha: 0.2),
// // //                                 ],
// // //                                 begin: Alignment.bottomLeft,
// // //                                 end: Alignment.topRight,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                           // Content
// // //                           Padding(
// // //                             padding: const EdgeInsets.all(18),
// // //                             child: Column(
// // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // //                               mainAxisAlignment: MainAxisAlignment.end,
// // //                               children: [
// // //                                 if (banner.discountText != null) ...[
// // //                                   Container(
// // //                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// // //                                     decoration: BoxDecoration(
// // //                                       color: AppColors.primary,
// // //                                       borderRadius: BorderRadius.circular(4),
// // //                                     ),
// // //                                     child: Text(
// // //                                       banner.discountText!,
// // //                                       style: AppTextStyle.badgeText,
// // //                                     ),
// // //                                   ),
// // //                                   const SizedBox(height: 8),
// // //                                 ],
// // //                                 Text(
// // //                                   banner.title,
// // //                                   style: AppTextStyle.sectionHeading.copyWith(
// // //                                     color: AppColors.textLight,
// // //                                     fontSize: 18,
// // //                                     letterSpacing: 0.5,
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(height: 3),
// // //                                 Text(
// // //                                   banner.subtitle,
// // //                                   maxLines: 1,
// // //                                   overflow: TextOverflow.ellipsis,
// // //                                   style: AppTextStyle.caption.copyWith(
// // //                                     color: AppColors.textLight.withValues(alpha: 0.85),
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //         ),
// // //         const SizedBox(height: 10),
// // //         // Dots Indicator
// // //         Row(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: List.generate(state.banners.length, (index) {
// // //             final isActive = index == _activeBannerIndex;
// // //             return AnimatedContainer(
// // //               duration: const Duration(milliseconds: 250),
// // //               margin: const EdgeInsets.symmetric(horizontal: 3),
// // //               height: 5,
// // //               width: isActive ? 18 : 5,
// // //               decoration: BoxDecoration(
// // //                 color: isActive ? AppColors.primary : AppColors.border,
// // //                 borderRadius: BorderRadius.circular(3),
// // //               ),
// // //             );
// // //           }),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildCategoriesSection(HomeLoadedState state) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         SectionHeader(
// // //           title: 'Shop by Category',
// // //           subtitle: 'Fashion, toys, kids essentials & local finds',
// // //           actionText: 'View All',
// // //           onActionTap: widget.onNavigateToCategory,
// // //         ),
// // //         const SizedBox(height: 10),
// // //         SizedBox(
// // //           height: 105,
// // //           child: ListView.separated(
// // //             padding: const EdgeInsets.symmetric(horizontal: 16),
// // //             scrollDirection: Axis.horizontal,
// // //             itemCount: state.categories.length,
// // //             separatorBuilder: (_, _) => const SizedBox(width: 14),
// // //             itemBuilder: (context, index) {
// // //               final cat = state.categories[index];
// // //               return GestureDetector(
// // //                 onTap: () {
// // //                   Navigator.of(context).push(
// // //                     MaterialPageRoute(
// // //                       builder: (_) => ProductListScreen(
// // //                         initialCategoryId: cat.id,
// // //                         categoryTitle: cat.name,
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //                 child: SizedBox(
// // //                   width: 72,
// // //                   child: Column(
// // //                     children: [
// // //                       Container(
// // //                         height: 64,
// // //                         width: 64,
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           border: Border.all(color: AppColors.borderLight, width: 1.5),
// // //                           boxShadow: const [
// // //                             BoxShadow(
// // //                               color: AppColors.shadow,
// // //                               blurRadius: 6,
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         child: ClipOval(
// // //                           child: NetworkImageWithFallback(
// // //                             imageUrl: cat.imageUrl,
// // //                             fit: BoxFit.cover,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 6),
// // //                       Text(
// // //                         cat.name,
// // //                         maxLines: 2,
// // //                         textAlign: TextAlign.center,
// // //                         overflow: TextOverflow.ellipsis,
// // //                         style: AppTextStyle.caption.copyWith(
// // //                           fontWeight: FontWeight.w600,
// // //                           fontSize: 11,
// // //                           color: AppColors.textPrimary,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               );
// // //             },
// // //           ),
// // //         ),
// // //
// // //         const SizedBox(height: 12),
// // //
// // //         // Popular Subcategories Quick Row
// // //         Padding(
// // //           padding: const EdgeInsets.symmetric(horizontal: 16),
// // //           child: Row(
// // //             children: [
// // //               Text(
// // //                 'POPULAR SUBCATEGORIES',
// // //                 style: AppTextStyle.caption.copyWith(
// // //                   fontWeight: FontWeight.w800,
// // //                   fontSize: 10,
// // //                   color: AppColors.textTertiary,
// // //                   letterSpacing: 0.6,
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 6),
// // //               const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.textTertiary),
// // //             ],
// // //           ),
// // //         ),
// // //         const SizedBox(height: 8),
// // //         SizedBox(
// // //           height: 34,
// // //           child: ListView(
// // //             scrollDirection: Axis.horizontal,
// // //             padding: const EdgeInsets.symmetric(horizontal: 16),
// // //             children: [
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Co-Ord Sets',
// // //                 categoryId: 'dresses',
// // //                 subcategory: 'Co-Ord Sets',
// // //                 icon: Icons.style_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Toys & RC Cars',
// // //                 categoryId: 'toys-games',
// // //                 subcategory: 'RC & Action Toys',
// // //                 icon: Icons.sports_esports_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Kurta Sets',
// // //                 categoryId: 'dresses',
// // //                 subcategory: 'Kurta Sets',
// // //                 icon: Icons.accessibility_new_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Baby Rompers',
// // //                 categoryId: 'kids-baby',
// // //                 subcategory: 'Baby Rompers & Sets',
// // //                 icon: Icons.child_care_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'STEM & Puzzles',
// // //                 categoryId: 'toys-games',
// // //                 subcategory: 'Educational Toys',
// // //                 icon: Icons.psychology_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Dresses & Midis',
// // //                 categoryId: 'dresses',
// // //                 subcategory: 'Dresses & Midis',
// // //                 icon: Icons.dry_cleaning_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Building Blocks',
// // //                 categoryId: 'kids-baby',
// // //                 subcategory: 'Building Blocks & Tiles',
// // //                 icon: Icons.dashboard_customize_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Soft Plushies',
// // //                 categoryId: 'toys-games',
// // //                 subcategory: 'Soft Toys & Plushies',
// // //                 icon: Icons.pets_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Ethnic Juttis',
// // //                 categoryId: 'footwear-accessories',
// // //                 subcategory: 'Ethnic Juttis & Mojaris',
// // //                 icon: Icons.skateboarding_rounded,
// // //               ),
// // //               _buildSubcategoryHomePill(
// // //                 context,
// // //                 title: 'Festive Wear',
// // //                 categoryId: 'dresses',
// // //                 subcategory: 'Festive & Ethnic',
// // //                 icon: Icons.auto_awesome_rounded,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildSubcategoryHomePill(
// // //       BuildContext context, {
// // //         required String title,
// // //         required String categoryId,
// // //         required String subcategory,
// // //         required IconData icon,
// // //       }) {
// // //     return GestureDetector(
// // //       onTap: () {
// // //         Navigator.of(context).push(
// // //           MaterialPageRoute(
// // //             builder: (_) => ProductListScreen(
// // //               initialCategoryId: categoryId,
// // //               initialSubcategory: subcategory,
// // //               categoryTitle: '$subcategory • Shoploc',
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //       child: Container(
// // //         margin: const EdgeInsets.only(right: 8),
// // //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //         decoration: BoxDecoration(
// // //           color: AppColors.surface,
// // //           borderRadius: BorderRadius.circular(18),
// // //           border: Border.all(color: AppColors.borderLight),
// // //           boxShadow: const [
// // //             BoxShadow(
// // //               color: AppColors.shadow,
// // //               blurRadius: 4,
// // //               offset: Offset(0, 1),
// // //             ),
// // //           ],
// // //         ),
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(icon, size: 14, color: AppColors.brandOrange),
// // //             const SizedBox(width: 6),
// // //             Text(
// // //               title,
// // //               style: const TextStyle(
// // //                 fontSize: 11.5,
// // //                 fontWeight: FontWeight.w700,
// // //                 color: AppColors.textPrimary,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildHorizontalProductSection({
// // //     required String title,
// // //     required String subtitle,
// // //     required List<dynamic> products,
// // //   }) {
// // //     return BlocBuilder<WishlistBloc, WishlistState>(
// // //       builder: (context, wishlistState) {
// // //         final wishlistIds = wishlistState is WishlistLoadedState
// // //             ? wishlistState.items.map((p) => p.id).toSet()
// // //             : <String>{};
// // //
// // //         return Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             SectionHeader(
// // //               title: title,
// // //               subtitle: subtitle,
// // //               actionText: 'See All',
// // //               onActionTap: () {
// // //                 Navigator.of(context).push(
// // //                   MaterialPageRoute(
// // //                     builder: (_) => ProductListScreen(categoryTitle: title),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //             const SizedBox(height: 8),
// // //             SizedBox(
// // //               height: 250,
// // //               child: ListView.separated(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 scrollDirection: Axis.horizontal,
// // //                 itemCount: products.length,
// // //                 separatorBuilder: (_, _) => const SizedBox(width: 14),
// // //                 itemBuilder: (context, index) {
// // //                   final product = products[index];
// // //                   final isWishlisted = wishlistIds.contains(product.id);
// // //
// // //                   return SizedBox(
// // //                     width: 165,
// // //                     child: ProductCard(
// // //                       product: product,
// // //                       isWishlisted: isWishlisted,
// // //                       onTap: () {
// // //                         context.read<ProductBloc>().add(
// // //                           LoadProductDetailsEvent(productId: product.id),
// // //                         );
// // //                         Navigator.of(context).push(
// // //                           MaterialPageRoute(
// // //                             builder: (_) => ProductDetailsScreen(product: product),
// // //                           ),
// // //                         );
// // //                       },
// // //                       onWishlistTap: () {
// // //                         context.read<WishlistBloc>().add(
// // //                           ToggleWishlistEvent(product: product),
// // //                         );
// // //                       },
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   Widget _buildSpecialOfferStrip(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16),
// // //       child: Container(
// // //         padding: const EdgeInsets.all(16),
// // //         decoration: BoxDecoration(
// // //           color: AppColors.blush,
// // //           borderRadius: BorderRadius.circular(14),
// // //           border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             Container(
// // //               padding: const EdgeInsets.all(10),
// // //               decoration: const BoxDecoration(
// // //                 color: AppColors.primary,
// // //                 shape: BoxShape.circle,
// // //               ),
// // //               child: const Icon(Icons.local_offer_outlined, color: Colors.white, size: 22),
// // //             ),
// // //             const SizedBox(width: 14),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Flat 10% OFF with "SHOPLOC10"',
// // //                     style: AppTextStyle.labelLarge.copyWith(color: AppColors.primaryDark),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Text(
// // //                     'Applicable across fashion, toys & essentials above ₹999.',
// // //                     style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildBestSellersGrid(HomeLoadedState state) {
// // //     return BlocBuilder<WishlistBloc, WishlistState>(
// // //       builder: (context, wishlistState) {
// // //         final wishlistIds = wishlistState is WishlistLoadedState
// // //             ? wishlistState.items.map((p) => p.id).toSet()
// // //             : <String>{};
// // //
// // //         return Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             SectionHeader(
// // //               title: 'Best Sellers',
// // //               subtitle: 'Customer favorites loved across India',
// // //               actionText: 'View All',
// // //               onActionTap: () {
// // //                 Navigator.of(context).push(
// // //                   MaterialPageRoute(
// // //                     builder: (_) => const ProductListScreen(categoryTitle: 'Best Sellers'),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //             const SizedBox(height: 8),
// // //             Padding(
// // //               padding: const EdgeInsets.symmetric(horizontal: 16),
// // //               child: GridView.builder(
// // //                 shrinkWrap: true,
// // //                 physics: const NeverScrollableScrollPhysics(),
// // //                 itemCount: state.bestSellers.take(4).length,
// // //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// // //                   crossAxisCount: 2,
// // //                   childAspectRatio: 0.65,
// // //                   crossAxisSpacing: 14,
// // //                   mainAxisSpacing: 14,
// // //                 ),
// // //                 itemBuilder: (context, index) {
// // //                   final product = state.bestSellers[index];
// // //                   final isWishlisted = wishlistIds.contains(product.id);
// // //
// // //                   return ProductCard(
// // //                     product: product,
// // //                     isWishlisted: isWishlisted,
// // //                     onTap: () {
// // //                       context.read<ProductBloc>().add(
// // //                         LoadProductDetailsEvent(productId: product.id),
// // //                       );
// // //                       Navigator.of(context).push(
// // //                         MaterialPageRoute(
// // //                           builder: (_) => ProductDetailsScreen(product: product),
// // //                         ),
// // //                       );
// // //                     },
// // //                     onWishlistTap: () {
// // //                       context.read<WishlistBloc>().add(
// // //                         ToggleWishlistEvent(product: product),
// // //                       );
// // //                     },
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //
// // //   Widget _buildEnquiryBanner(BuildContext context) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16),
// // //       child: Container(
// // //         padding: const EdgeInsets.all(20),
// // //         decoration: BoxDecoration(
// // //           color: const Color(0xFF1E60ED),
// // //           borderRadius: BorderRadius.circular(16),
// // //           boxShadow: const [
// // //             BoxShadow(
// // //               color: Color(0x301E60ED),
// // //               blurRadius: 16,
// // //               offset: Offset(0, 6),
// // //             ),
// // //           ],
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 Container(
// // //                   padding: const EdgeInsets.all(8),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.white.withValues(alpha: 0.2),
// // //                     shape: BoxShape.circle,
// // //                   ),
// // //                   child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 22),
// // //                 ),
// // //                 const SizedBox(width: 12),
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text(
// // //                         'Get In Touch',
// // //                         style: GoogleFonts.plusJakartaSans(
// // //                           textStyle: const TextStyle(
// // //                             fontSize: 18,
// // //                             fontWeight: FontWeight.w800,
// // //                             color: Colors.white,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 2),
// // //                       Text(
// // //                         'Have questions about products or services?',
// // //                         style: GoogleFonts.plusJakartaSans(
// // //                           textStyle: TextStyle(
// // //                             fontSize: 12.5,
// // //                             color: Colors.white.withValues(alpha: 0.9),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 14),
// // //             Text(
// // //               'Our team strives to provide the best customer experience possible. Reach out for any questions, support, or bulk enquiries.',
// // //               style: GoogleFonts.plusJakartaSans(
// // //                 textStyle: TextStyle(
// // //                   fontSize: 12.5,
// // //                   color: Colors.white.withValues(alpha: 0.88),
// // //                   height: 1.4,
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             SizedBox(
// // //               width: double.infinity,
// // //               height: 44,
// // //               child: ElevatedButton.icon(
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.white,
// // //                   foregroundColor: const Color(0xFF1E60ED),
// // //                   elevation: 0,
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(24),
// // //                   ),
// // //                 ),
// // //                 onPressed: () {
// // //                   Navigator.of(context).push(
// // //                     MaterialPageRoute(builder: (_) => const EnquiryScreen()),
// // //                   );
// // //                 },
// // //                 icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
// // //                 label: Text(
// // //                   'Send Us a Message',
// // //                   style: GoogleFonts.plusJakartaSans(
// // //                     textStyle: const TextStyle(
// // //                       fontSize: 14,
// // //                       fontWeight: FontWeight.w700,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildPromisePill(IconData icon, String title, String subtitle) {
// // //     return Expanded(
// // //       child: Column(
// // //         children: [
// // //           Icon(icon, size: 22, color: AppColors.primary),
// // //           const SizedBox(height: 6),
// // //           Text(
// // //             title,
// // //             textAlign: TextAlign.center,
// // //             style: AppTextStyle.caption.copyWith(
// // //               fontWeight: FontWeight.w700,
// // //               color: AppColors.textPrimary,
// // //               fontSize: 11,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 2),
// // //           Text(
// // //             subtitle,
// // //             textAlign: TextAlign.center,
// // //             style: AppTextStyle.caption.copyWith(
// // //               fontSize: 9,
// // //               color: AppColors.textSecondary,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shoploc/app/ui/product_details_screen.dart';
// import 'package:shoploc/app/ui/trendingscreen.dart';
//
// import '../bloc/homebloc/home_bloc.dart';
// import '../bloc/homebloc/home_event.dart';
// import '../bloc/homebloc/home_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../core/utils/productlisttype.dart';
// import '../data/models/models/homemodel.dart';
// import '../widgets/network_image_with_fallback.dart';
// import '../widgets/product_card.dart';
// import '../widgets/section_header.dart';
// import '../widgets/shoploc_logo.dart';
// import 'bestsellerscreen.dart';
// import 'newarrivalscreen.dart';
//
// class HomeScreen extends StatefulWidget {
//   final VoidCallback onNavigateToCategory;
//   const HomeScreen({super.key, required this.onNavigateToCategory});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<HomeBloc>().add(const LoadHomeDataEvent());
//   }
//
//   // ---- Navigation hooks ----
//   void _openProduct(HomeProductModel product) {
//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (_) => ProductDetailsScreen(productId: product.id)));
//   }
//
//   void _openCategory(CategoryApiModel category) {
//     // TODO: open product list filtered by category.id
//   }
//
//   void _openSearch() {
//     // TODO: open search screen
//   }
//
//   void _seeAll(ProductListType type) {
//     final Widget page;
//     switch (type) {
//       case ProductListType.newArrivals:
//         page = const NewArrivalsScreen();
//         break;
//       case ProductListType.trending:
//         page = const TrendingScreen();
//         break;
//       case ProductListType.bestSellers:
//         page = const BestSellersScreen();
//         break;
//     }
//     Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
//   }
//
//   Future<void> _onRefresh() async {
//     final bloc = context.read<HomeBloc>();
//     bloc.add(const RefreshHomeDataEvent());
//     await bloc.stream.first;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.surface,
//         surfaceTintColor: Colors.transparent,
//         scrolledUnderElevation: 1,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         titleSpacing: 16,
//         title: const ShoplocLogo(fontSize: 50),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_none_rounded, size: 24),
//             onPressed: () {
//               // TODO: notifications screen
//             },
//           ),
//           const SizedBox(width: 6),
//         ],
//       ),
//       body: BlocBuilder<HomeBloc, HomeState>(
//         builder: (context, state) {
//           if (state is HomeLoadingState || state is HomeInitialState) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             );
//           }
//
//           if (state is HomeErrorState) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.cloud_off_rounded,
//                         size: 44, color: AppColors.textTertiary),
//                     const SizedBox(height: 12),
//                     Text('Failed to load collections',
//                         style: AppTextStyle.sectionHeading),
//                     const SizedBox(height: 6),
//                     Text(
//                       state.errorMessage,
//                       textAlign: TextAlign.center,
//                       style: AppTextStyle.caption,
//                     ),
//                     const SizedBox(height: 14),
//                     ElevatedButton(
//                       onPressed: () => context
//                           .read<HomeBloc>()
//                           .add(const LoadHomeDataEvent()),
//                       child: const Text('Try Again'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           if (state is HomeLoadedState) {
//             return RefreshIndicator(
//               color: AppColors.primary,
//               onRefresh: _onRefresh,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSearchBar(),
//                     const SizedBox(height: 16),
//                     if (state.categories.isNotEmpty) ...[
//                       _buildCategoriesSection(state),
//                       const SizedBox(height: 24),
//                     ],
//                     if (state.newArrivals.isNotEmpty) ...[
//                       _buildHorizontalSection(
//                         title: 'New Arrivals',
//                         subtitle: 'Fresh drops across fashion & lifestyle',
//                         products: state.newArrivals,
//                         type: ProductListType.newArrivals,
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                     if (state.trendingProducts.isNotEmpty) ...[
//                       _buildHorizontalSection(
//                         title: 'Trending Right Now',
//                         subtitle: 'Most coveted pieces this season',
//                         products: state.trendingProducts,
//                         type: ProductListType.trending,
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                     _buildSpecialOfferStrip(),
//                     const SizedBox(height: 24),
//                     if (state.bestSellers.isNotEmpty) ...[
//                       _buildBestSellersGrid(state.bestSellers),
//                       const SizedBox(height: 28),
//                     ],
//                     if (state.newArrivals.isEmpty &&
//                         state.trendingProducts.isEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(32),
//                         child: Center(
//                           child: Text('No products available yet.',
//                               style: AppTextStyle.caption),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   // ---------------- SEARCH ----------------
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: GestureDetector(
//         onTap: _openSearch,
//         child: Container(
//           height: 48,
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: AppColors.borderLight),
//             boxShadow: const [
//               BoxShadow(
//                   color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
//             ],
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.search, color: AppColors.textTertiary, size: 22),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Search "Co-Ord Sets", "Kurta", "Dresses"...',
//                   style: AppTextStyle.inputHint,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Container(
//                 height: 20,
//                 width: 1,
//                 color: AppColors.divider,
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//               ),
//               const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ---------------- CATEGORIES ----------------
//   Widget _buildCategoriesSection(HomeLoadedState state) {
//     // Subcategory quick pills come from the children of every parent category
//     final subcategories =
//     state.categories.expand((c) => c.children).take(12).toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionHeader(
//           title: 'Shop by Category',
//           subtitle: 'Fashion & lifestyle finds',
//           actionText: 'View All',
//           onActionTap: widget.onNavigateToCategory,
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 105,
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             scrollDirection: Axis.horizontal,
//             itemCount: state.categories.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 14),
//             itemBuilder: (context, index) {
//               final cat = state.categories[index];
//               // Parent categories have an empty image -> use first child's image
//               final image = cat.image.isNotEmpty
//                   ? cat.image
//                   : (cat.children.isNotEmpty ? cat.children.first.image : '');
//               return GestureDetector(
//                 onTap: () => _openCategory(cat),
//                 child: SizedBox(
//                   width: 72,
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 64,
//                         width: 64,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: AppColors.surface,
//                           border: Border.all(
//                               color: AppColors.borderLight, width: 1.5),
//                           boxShadow: const [
//                             BoxShadow(color: AppColors.shadow, blurRadius: 6),
//                           ],
//                         ),
//                         child: ClipOval(
//                             child: _image(image,
//                                 fallbackIcon: Icons.category_outlined)),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         cat.name,
//                         maxLines: 2,
//                         textAlign: TextAlign.center,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyle.caption.copyWith(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 11,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         if (subcategories.isNotEmpty) ...[
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               'POPULAR SUBCATEGORIES',
//               style: AppTextStyle.caption.copyWith(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 10,
//                 color: AppColors.textTertiary,
//                 letterSpacing: 0.6,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 34,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: subcategories.length,
//               itemBuilder: (_, i) => _subcategoryPill(subcategories[i]),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _subcategoryPill(CategoryApiModel sub) {
//     return GestureDetector(
//       onTap: () => _openCategory(sub),
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: AppColors.borderLight),
//           boxShadow: const [
//             BoxShadow(
//                 color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 1)),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.style_rounded,
//                 size: 14, color: AppColors.brandOrange),
//             const SizedBox(width: 6),
//             Text(
//               sub.name,
//               style: const TextStyle(
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---------------- PRODUCT SECTIONS ----------------
//   Widget _buildHorizontalSection({
//     required String title,
//     required String subtitle,
//     required List<HomeProductModel> products,
//     required ProductListType type,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionHeader(
//           title: title,
//           subtitle: subtitle,
//           actionText: 'See All',
//           onActionTap: () => _seeAll(type),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 260,
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             scrollDirection: Axis.horizontal,
//             itemCount: products.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 14),
//             itemBuilder: (_, i) => SizedBox(
//               width: 165,
//               child: HomeProductCard(
//                 product: products[i],
//                 onTap: () => _openProduct(products[i]),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBestSellersGrid(List<HomeProductModel> products) {
//     final items = products.take(4).toList();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionHeader(
//           title: 'Best Sellers',
//           subtitle: 'Customer favorites loved across India',
//           actionText: 'View All',
//           onActionTap: () => _seeAll(ProductListType.bestSellers),
//         ),
//         const SizedBox(height: 8),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: items.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.66,
//               crossAxisSpacing: 14,
//               mainAxisSpacing: 14,
//             ),
//             itemBuilder: (_, i) => HomeProductCard(
//               product: items[i],
//               onTap: () => _openProduct(items[i]),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ---------------- OFFER STRIP ----------------
//   Widget _buildSpecialOfferStrip() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.blush,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//               color: AppColors.primaryLight.withValues(alpha: 0.3)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: const BoxDecoration(
//                   color: AppColors.primary, shape: BoxShape.circle),
//               child: const Icon(Icons.local_offer_outlined,
//                   color: Colors.white, size: 22),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Flat 10% OFF with "SHOPLOC10"',
//                     style: AppTextStyle.labelLarge
//                         .copyWith(color: AppColors.primaryDark),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     'Applicable on orders above ₹999.',
//                     style: AppTextStyle.caption
//                         .copyWith(color: AppColors.textSecondary),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---------------- HELPERS ----------------
//   Widget _image(String url, {IconData fallbackIcon = Icons.image_outlined}) {
//     if (url.isEmpty) {
//       return Container(
//         color: AppColors.blush,
//         child: Icon(fallbackIcon, color: AppColors.textTertiary, size: 26),
//       );
//     }
//     return NetworkImageWithFallback(imageUrl: url, fit: BoxFit.cover);
//   }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';
import 'package:shoploc/app/ui/trendingscreen.dart';

import '../bloc/homebloc/home_bloc.dart';
import '../bloc/homebloc/home_event.dart';
import '../bloc/homebloc/home_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/productlisttype.dart';
import '../data/models/models/apibannermodel.dart';
import '../data/models/models/homemodel.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shoploc_logo.dart';
import 'bestsellerscreen.dart';
import 'newarrivalscreen.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDataEvent());

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
    super.dispose();
  }

  // ---- Navigation hooks ----
  void _openProduct(HomeProductModel product) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: product.id)));
  }

  void _openCategory(CategoryApiModel category) {
    // TODO: open product list filtered by category.id
  }

  void _openSearch() {
    // TODO: open search screen
  }

  void _seeAll(ProductListType type) {
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
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HomeBloc>();
    bloc.add(const RefreshHomeDataEvent());
    await bloc.stream.first;
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('Failed to load collections',
                        style: AppTextStyle.sectionHeading),
                    const SizedBox(height: 6),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption,
                    ),
                    const SizedBox(height: 14),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    if (state.banners.isNotEmpty) ...[
                      _buildBannerCarousel(state.banners),
                      const SizedBox(height: 20),
                    ],
                    if (state.categories.isNotEmpty) ...[
                      _buildCategoriesSection(state),
                      const SizedBox(height: 24),
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
                    _buildSpecialOfferStrip(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          aspectRatio: 16 / 7, // change if your banner images use another ratio
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
    // Subcategory quick pills come from the children of every parent category
    final subcategories =
    state.categories.expand((c) => c.children).take(12).toList();

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
          height: 105,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
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
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'POPULAR SUBCATEGORIES',
              style: AppTextStyle.caption.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subcategories.length,
              itemBuilder: (_, i) => _subcategoryPill(subcategories[i]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _subcategoryPill(CategoryApiModel sub) {
    return GestureDetector(
      onTap: () => _openCategory(sub),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style_rounded,
                size: 14, color: AppColors.brandOrange),
            const SizedBox(width: 6),
            Text(
              sub.name,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
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
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => SizedBox(
              width: 165,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
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

  // ---------------- OFFER STRIP ----------------
  Widget _buildSpecialOfferStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.local_offer_outlined,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flat 10% OFF with "SHOPLOC10"',
                    style: AppTextStyle.labelLarge
                        .copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Applicable on orders above ₹999.',
                    style: AppTextStyle.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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