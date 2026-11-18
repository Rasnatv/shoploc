//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/cartbloc/cart_bloc.dart';
// import '../bloc/cartbloc/cart_state.dart';
// import '../bloc/categoriesbloc/category_bloc.dart';
// import '../bloc/categoriesbloc/category_event.dart';
// import '../bloc/categoriesbloc/category_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../core/utils/formatters.dart';
// import '../data/dummy_data/shoploc_dummy_data.dart';
// import '../data/models/category_model.dart';
// import '../data/models/product_model.dart';
// import '../widgets/network_image_with_fallback.dart';
// import 'cart_screen.dart';
// import 'product_details_screen.dart';
// import 'product_list_screen.dart';
//
//
// enum CategoryViewLayout { splitRail, visualGrid }
//
// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});
//
//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }
//
// class _CategoriesScreenState extends State<CategoriesScreen> {
//   CategoryViewLayout _currentLayout = CategoryViewLayout.splitRail;
//   int _selectedCategoryIndex = 0;
//   String? _activeSubcategory;
//   final TextEditingController _searchController = TextEditingController();
//   bool _isSearchActive = false;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<CategoryBloc>().add(const LoadCategoriesEvent());
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   IconData _getSubcategoryIcon(String subcategory) {
//     final sub = subcategory.toLowerCase();
//     if (sub.contains('co-ord') || sub.contains('cord')) {
//       return Icons.style_rounded;
//     } else if (sub.contains('kurta')) {
//       return Icons.accessibility_new_rounded;
//     } else if (sub.contains('dress') || sub.contains('midi')) {
//       return Icons.dry_cleaning_rounded;
//     } else if (sub.contains('tunic') || sub.contains('top')) {
//       return Icons.checkroom_rounded;
//     } else if (sub.contains('festive') || sub.contains('ethnic')) {
//       return Icons.auto_awesome_rounded;
//     } else if (sub.contains('educational') || sub.contains('stem') || sub.contains('learning')) {
//       return Icons.psychology_rounded;
//     } else if (sub.contains('board') || sub.contains('puzzle') || sub.contains('game')) {
//       return Icons.extension_rounded;
//     } else if (sub.contains('rc') || sub.contains('action') || sub.contains('car')) {
//       return Icons.sports_esports_rounded;
//     } else if (sub.contains('plush') || sub.contains('soft') || sub.contains('toy')) {
//       return Icons.pets_rounded;
//     } else if (sub.contains('baby') || sub.contains('romper') || sub.contains('infant')) {
//       return Icons.child_care_rounded;
//     } else if (sub.contains('block') || sub.contains('tile')) {
//       return Icons.dashboard_customize_rounded;
//     } else if (sub.contains('jutt') || sub.contains('shoe') || sub.contains('footwear')) {
//       return Icons.skateboarding_rounded;
//     } else if (sub.contains('bag') || sub.contains('clutch') || sub.contains('tote')) {
//       return Icons.shopping_bag_outlined;
//     } else if (sub.contains('decor') || sub.contains('home') || sub.contains('linen')) {
//       return Icons.home_rounded;
//     }
//     return Icons.category_outlined;
//   }
//
//   void _navigateToCategory(
//       BuildContext context, {
//         required String categoryId,
//         required String categoryName,
//         String? subcategory,
//       }) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => ProductListScreen(
//           initialCategoryId: categoryId,
//           initialSubcategory: subcategory,
//           categoryTitle: subcategory != null
//               ? '$subcategory • $categoryName'
//               : categoryName,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: _buildAppBar(context),
//       body: BlocBuilder<CategoryBloc, CategoryState>(
//         builder: (context, state) {
//           if (state is CategoryLoadingState) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             );
//           }
//
//           if (state is CategoryErrorState) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 48, color: AppColors.error),
//                   const SizedBox(height: 12),
//                   Text(state.errorMessage, style: AppTextStyle.bodyMedium),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context
//                         .read<CategoryBloc>()
//                         .add(const LoadCategoriesEvent()),
//                     child: const Text('Try Again'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (state is CategoryLoadedState) {
//             final categories = state.categories;
//             if (categories.isEmpty) {
//               return const Center(child: Text('No categories available'));
//             }
//
//             // Apply search filter if active
//             final filteredCategories = _searchQuery.isEmpty
//                 ? categories
//                 : categories.where((cat) {
//               final q = _searchQuery.toLowerCase();
//               return cat.name.toLowerCase().contains(q) ||
//                   cat.description.toLowerCase().contains(q) ||
//                   cat.subcategories.any((s) => s.toLowerCase().contains(q));
//             }).toList();
//
//             return Column(
//               children: [
//                 // Inline Search Bar (when search is toggled)
//                 if (_isSearchActive) _buildInlineSearchBar(),
//
//                 // Mode Selector Bar (Rail View vs Visual Grid)
//                 _buildLayoutSwitcher(),
//
//                 // Main Content View
//                 Expanded(
//                   child: filteredCategories.isEmpty
//                       ? _buildEmptySearch()
//                       : _currentLayout == CategoryViewLayout.splitRail
//                       ? _buildSplitRailView(filteredCategories)
//                       : _buildVisualGridView(filteredCategories),
//                 ),
//               ],
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Categories',
//             style: AppTextStyle.appBarTitle.copyWith(
//               fontSize: 21,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             ),
//           ),
//           Text(
//             'Explore Fashion, Toys, Kids & Local Stores',
//             style: AppTextStyle.caption.copyWith(
//               fontSize: 11,
//               color: AppColors.textTertiary,
//               letterSpacing: 0.2,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         // Search Toggle
//         IconButton(
//           icon: Icon(
//             _isSearchActive ? Icons.search_off_rounded : Icons.search_rounded,
//             color: _isSearchActive ? AppColors.brandOrange : AppColors.textPrimary,
//           ),
//           tooltip: 'Search Categories',
//           onPressed: () {
//             setState(() {
//               _isSearchActive = !_isSearchActive;
//               if (!_isSearchActive) {
//                 _searchController.clear();
//                 _searchQuery = '';
//               }
//             });
//           },
//         ),
//
//         // Cart Icon with Real-Time Badge
//         BlocBuilder<CartBloc, CartState>(
//           builder: (context, cartState) {
//             final count =
//             cartState is CartLoadedState ? cartState.totalItemCount : 0;
//             return Stack(
//               alignment: Alignment.center,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_bag_outlined),
//                   tooltip: 'Shopping Cart',
//                   onPressed: () {
//                     // Navigator.of(context).push(
//                     //   MaterialPageRoute(
//                     //     builder: (_) => CartScreen(
//                     //       onGoShopping: () => Navigator.of(context).pop(),
//                     //     ),
//                     //   ),
//                     // );
//                   },
//                 ),
//                 if (count > 0)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: AppColors.brandOrange,
//                         shape: BoxShape.circle,
//                       ),
//                       constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//                       child: Text(
//                         '$count',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//         const SizedBox(width: 4),
//       ],
//     );
//   }
//
//   Widget _buildInlineSearchBar() {
//     return Container(
//       color: AppColors.surface,
//       padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
//       child: TextField(
//         controller: _searchController,
//         autofocus: true,
//         decoration: InputDecoration(
//           hintText: 'Search toys, dresses, board games, sets...',
//           hintStyle: AppTextStyle.inputHint,
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: AppColors.brandOrange,
//             size: 22,
//           ),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, size: 20),
//             onPressed: () {
//               setState(() {
//                 _searchController.clear();
//                 _searchQuery = '';
//               });
//             },
//           )
//               : null,
//           filled: true,
//           fillColor: AppColors.surfaceVariant,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         onChanged: (val) {
//           setState(() => _searchQuery = val.trim());
//         },
//       ),
//     );
//   }
//
//   /// Top layout switcher: Split Browser vs Visual Grid
//   Widget _buildLayoutSwitcher() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: const BoxDecoration(
//         color: AppColors.surface,
//         border: Border(
//           bottom: BorderSide(color: AppColors.borderLight, width: 1),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Explore Collections',
//             style: AppTextStyle.labelMedium.copyWith(
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           Row(
//             children: [
//               _buildLayoutOption(
//                 icon: Icons.splitscreen_rounded,
//                 label: 'Rail View',
//                 isSelected: _currentLayout == CategoryViewLayout.splitRail,
//                 onTap: () {
//                   setState(() => _currentLayout = CategoryViewLayout.splitRail);
//                 },
//               ),
//               const SizedBox(width: 8),
//               _buildLayoutOption(
//                 icon: Icons.grid_view_rounded,
//                 label: 'Grid View',
//                 isSelected: _currentLayout == CategoryViewLayout.visualGrid,
//                 onTap: () {
//                   setState(() => _currentLayout = CategoryViewLayout.visualGrid);
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLayoutOption({
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.brandOrange.withValues(alpha: 0.12)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 14,
//               color: isSelected ? AppColors.brandOrange : AppColors.textSecondary,
//             ),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 color: isSelected ? AppColors.brandOrange : AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Split-Rail View: Left Category Navigation Rail + Right Detail Pane
//   Widget _buildSplitRailView(List<CategoryModel> categories) {
//     if (_selectedCategoryIndex >= categories.length) {
//       _selectedCategoryIndex = 0;
//     }
//     final selectedCategory = categories[_selectedCategoryIndex];
//     final previewProducts = ShoplocDummyData.products
//         .where((p) =>
//     p.categoryId == selectedCategory.id &&
//         (_activeSubcategory == null ||
//             p.subcategory.toLowerCase() == _activeSubcategory!.toLowerCase()))
//         .take(6)
//         .toList();
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left Category Sidebar Rail
//         Container(
//           width: 104,
//           decoration: const BoxDecoration(
//             color: AppColors.surfaceVariant,
//             border: Border(
//               right: BorderSide(color: AppColors.borderLight, width: 1),
//             ),
//           ),
//           child: ListView.builder(
//             itemCount: categories.length,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             itemBuilder: (context, index) {
//               final cat = categories[index];
//               final isSelected = index == _selectedCategoryIndex;
//
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedCategoryIndex = index;
//                     _activeSubcategory = null;
//                   });
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 180),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.surface : Colors.transparent,
//                     border: Border(
//                       left: BorderSide(
//                         color: isSelected ? AppColors.brandOrange : Colors.transparent,
//                         width: 4,
//                       ),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Thumbnail
//                       Container(
//                         height: 52,
//                         width: 52,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
//                             width: isSelected ? 2 : 1,
//                           ),
//                           boxShadow: isSelected
//                               ? [
//                             BoxShadow(
//                               color: AppColors.brandOrange.withValues(alpha: 0.2),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ]
//                               : null,
//                         ),
//                         clipBehavior: Clip.antiAlias,
//                         child: NetworkImageWithFallback(
//                           imageUrl: cat.imageUrl,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         cat.name,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
//                           color: isSelected ? AppColors.brandOrange : AppColors.textPrimary,
//                           height: 1.2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         // Right Detail Pane: Category Banner + Subcategories Grid + Preview Products
//         Expanded(
//           child: ListView(
//             padding: const EdgeInsets.all(14),
//             children: [
//               // Hero Category Banner
//               GestureDetector(
//                 onTap: () => _navigateToCategory(
//                   context,
//                   categoryId: selectedCategory.id,
//                   categoryName: selectedCategory.name,
//                 ),
//                 child: Container(
//                   height: 125,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: AppColors.shadowMedium,
//                         blurRadius: 10,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       NetworkImageWithFallback(
//                         imageUrl: selectedCategory.imageUrl,
//                         fit: BoxFit.cover,
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.black.withValues(alpha: 0.8),
//                               Colors.black.withValues(alpha: 0.2),
//                             ],
//                             begin: Alignment.bottomLeft,
//                             end: Alignment.topRight,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: AppColors.brandOrange,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '${selectedCategory.productCount} Designs',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 9.5,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         selectedCategory.name,
//                                         style: AppTextStyle.sectionHeading.copyWith(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w800,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 2),
//                                       Text(
//                                         'Explore all styles →',
//                                         style: TextStyle(
//                                           color: Colors.white.withValues(alpha: 0.9),
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: const BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.arrow_forward_rounded,
//                                     size: 14,
//                                     color: AppColors.brandBlue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 18),
//
//               // Subcategories Section (Displaying subcategories separately)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 3.5,
//                         height: 15,
//                         decoration: BoxDecoration(
//                           color: AppColors.brandOrange,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Subcategories',
//                         style: AppTextStyle.sectionHeading.copyWith(
//                           fontSize: 14.5,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: () => _navigateToCategory(
//                       context,
//                       categoryId: selectedCategory.id,
//                       categoryName: selectedCategory.name,
//                     ),
//                     child: Text(
//                       'View All (${selectedCategory.subcategories.length}) →',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.brandOrange,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//
//               // Interactive Subcategory Grid Cards
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: selectedCategory.subcategories.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 2.1,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemBuilder: (context, subIndex) {
//                   final sub = selectedCategory.subcategories[subIndex];
//                   final isSelected = _activeSubcategory == sub;
//                   final icon = _getSubcategoryIcon(sub);
//
//                   return InkWell(
//                     onTap: () {
//                       setState(() {
//                         _activeSubcategory = isSelected ? null : sub;
//                       });
//                     },
//                     onDoubleTap: () => _navigateToCategory(
//                       context,
//                       categoryId: selectedCategory.id,
//                       categoryName: selectedCategory.name,
//                       subcategory: sub,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 180),
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.brandOrange.withValues(alpha: 0.12)
//                             : AppColors.surface,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
//                           width: isSelected ? 1.5 : 1,
//                         ),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: AppColors.shadow,
//                             blurRadius: 3,
//                             offset: Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(5),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppColors.brandOrange
//                                   : AppColors.brandOrange.withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               icon,
//                               size: 15,
//                               color: isSelected ? Colors.white : AppColors.brandOrange,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Expanded(
//                             child: Text(
//                               sub,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
//                                 color: isSelected ? AppColors.brandOrange : AppColors.textPrimary,
//                                 height: 1.15,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => _navigateToCategory(
//                               context,
//                               categoryId: selectedCategory.id,
//                               categoryName: selectedCategory.name,
//                               subcategory: sub,
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(2),
//                               child: Icon(
//                                 Icons.open_in_new_rounded,
//                                 size: 13,
//                                 color: isSelected ? AppColors.brandOrange : AppColors.textTertiary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 18),
//
//               // Trending Picks in this Category or Selected Subcategory
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       _activeSubcategory != null
//                           ? '$_activeSubcategory in ${selectedCategory.name}'
//                           : 'Popular in ${selectedCategory.name}',
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: AppTextStyle.labelLarge.copyWith(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 13.5,
//                       ),
//                     ),
//                   ),
//                   if (_activeSubcategory != null)
//                     GestureDetector(
//                       onTap: () => setState(() => _activeSubcategory = null),
//                       child: Text(
//                         'Show All',
//                         style: AppTextStyle.caption.copyWith(
//                           color: AppColors.brandOrange,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               if (previewProducts.isNotEmpty)
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: previewProducts.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.68,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemBuilder: (context, pIndex) {
//                     final product = previewProducts[pIndex];
//                     return _CategoryPreviewProductCard(
//                       product: product,
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => ProductDetailsScreen(product: product),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 )
//               else
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: AppColors.surface,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.borderLight),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textTertiary),
//                       const SizedBox(height: 8),
//                       Text(
//                         'No products found in this subcategory yet.',
//                         style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Visual Grid View: 2-column portrait boutique tiles
//   Widget _buildVisualGridView(List<CategoryModel> categories) {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: categories.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.72,
//         crossAxisSpacing: 14,
//         mainAxisSpacing: 14,
//       ),
//       itemBuilder: (context, index) {
//         final cat = categories[index];
//         return GestureDetector(
//           onTap: () => _navigateToCategory(
//             context,
//             categoryId: cat.id,
//             categoryName: cat.name,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: AppColors.borderLight),
//               boxShadow: const [
//                 BoxShadow(
//                   color: AppColors.shadowMedium,
//                   blurRadius: 10,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 NetworkImageWithFallback(
//                   imageUrl: cat.imageUrl,
//                   fit: BoxFit.cover,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.black.withValues(alpha: 0.85),
//                         Colors.black.withValues(alpha: 0.2),
//                         Colors.transparent,
//                       ],
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       stops: const [0.0, 0.55, 1.0],
//                     ),
//                   ),
//                 ),
//                 // Item count badge
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: AppColors.brandOrange,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${cat.productCount}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Title and subtitle
//                 Positioned(
//                   bottom: 12,
//                   left: 12,
//                   right: 12,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         cat.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               cat.subcategories.isNotEmpty
//                                   ? cat.subcategories.take(3).join(' • ')
//                                   : 'Shoploc Boutique',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.9),
//                                 fontSize: 10.5,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.arrow_forward_rounded,
//                               size: 12,
//                               color: AppColors.brandBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildEmptySearch() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off_rounded, size: 48, color: AppColors.brandOrange),
//             const SizedBox(height: 12),
//             Text('No Categories Found', style: AppTextStyle.sectionHeading),
//             const SizedBox(height: 6),
//             Text(
//               'No category matches "$_searchQuery".',
//               style: AppTextStyle.caption,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Compact mini product preview card for the right pane of Split-Rail view
// class _CategoryPreviewProductCard extends StatelessWidget {
//   final ProductModel product;
//   final VoidCallback onTap;
//
//   const _CategoryPreviewProductCard({
//     required this.product,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.borderLight),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: NetworkImageWithFallback(
//                 imageUrl: product.images.isNotEmpty ? product.images.first : '',
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       Text(
//                         Formatters.formatPrice(product.discountedPrice),
//                         style: const TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.brandOrange,
//                         ),
//                       ),
//                       if (product.originalPrice > product.discountedPrice) ...[
//                         const SizedBox(width: 4),
//                         Text(
//                           Formatters.formatPrice(product.originalPrice),
//                           style: const TextStyle(
//                             fontSize: 9.5,
//                             decoration: TextDecoration.lineThrough,
//                             color: AppColors.textTertiary,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/categoriesbloc/category_bloc.dart';
import '../bloc/categoriesbloc/category_event.dart';
import '../bloc/categoriesbloc/category_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/models/homemodel.dart';
import '../widgets/network_image_with_fallback.dart';

enum CategoryViewLayout { splitRail, visualGrid }

/// Creates its own [CategoryBloc], so nothing needs registering in main.dart.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(const LoadCategoriesEvent()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  CategoryViewLayout _layout = CategoryViewLayout.splitRail;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---- Navigation hook ----
  /// Open the product list for a category / subcategory.
  void _openCategory(CategoryApiModel category, [CategoryApiModel? sub]) {
    // TODO: open products filtered by (sub ?? category).id
    // (needs the "products by category" API)
  }

  // ---- Helpers ----
  String _imageOf(CategoryApiModel c) {
    if (c.image.isNotEmpty) return c.image;
    for (final child in c.children) {
      if (child.image.isNotEmpty) return child.image;
    }
    return '';
  }

  Widget _img(String url, {IconData icon = Icons.category_outlined}) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.blush,
        child: Icon(icon, color: AppColors.textTertiary, size: 24),
      );
    }
    return NetworkImageWithFallback(
        imageUrl: url, fit: BoxFit.cover, width: double.infinity);
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<CategoryBloc>();
    bloc.add(const RefreshCategoriesEvent());
    await bloc.stream.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoadingState || state is CategoryInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is CategoryErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<CategoryBloc>()
                          .add(const LoadCategoriesEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CategoryLoadedState) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('No categories available'));
            }

            final q = _query.toLowerCase();
            final filtered = q.isEmpty
                ? state.categories
                : state.categories.where((c) {
              return c.name.toLowerCase().contains(q) ||
                  c.children.any((s) => s.name.toLowerCase().contains(q));
            }).toList();

            return Column(
              children: [
                if (_isSearchActive) _buildInlineSearchBar(),
                _buildLayoutSwitcher(),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptySearch()
                      : _layout == CategoryViewLayout.splitRail
                      ? _buildSplitRailView(filtered, state)
                      : _buildVisualGridView(filtered),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------- APP BAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: AppTextStyle.appBarTitle.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'Explore all collections & subcategories',
            style: AppTextStyle.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearchActive ? Icons.search_off_rounded : Icons.search_rounded,
            color:
            _isSearchActive ? AppColors.brandOrange : AppColors.textPrimary,
          ),
          tooltip: 'Search Categories',
          onPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                _query = '';
              }
            });
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildInlineSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search categories & subcategories...',
          hintStyle: AppTextStyle.inputHint,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.brandOrange, size: 22),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _query = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) => setState(() => _query = val.trim()),
      ),
    );
  }

  Widget _buildLayoutSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore Collections',
            style: AppTextStyle.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              _layoutOption(
                icon: Icons.splitscreen_rounded,
                label: 'Rail View',
                selected: _layout == CategoryViewLayout.splitRail,
                onTap: () =>
                    setState(() => _layout = CategoryViewLayout.splitRail),
              ),
              const SizedBox(width: 8),
              _layoutOption(
                icon: Icons.grid_view_rounded,
                label: 'Grid View',
                selected: _layout == CategoryViewLayout.visualGrid,
                onTap: () =>
                    setState(() => _layout = CategoryViewLayout.visualGrid),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _layoutOption({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandOrange.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.brandOrange : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color:
                selected ? AppColors.brandOrange : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:
                selected ? AppColors.brandOrange : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SPLIT RAIL VIEW ----------------
  Widget _buildSplitRailView(
      List<CategoryApiModel> categories, CategoryLoadedState state) {
    final selected = categories.firstWhere(
          (c) => c.id == state.selectedCategoryId,
      orElse: () => categories.first,
    );
    final subs = selected.children;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- Left rail: parent categories -----
        Container(
          width: 104,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            border: Border(
              right: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: ListView.builder(
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == selected.id;

              return GestureDetector(
                onTap: () => context
                    .read<CategoryBloc>()
                    .add(SelectCategoryEvent(categoryId: cat.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected
                            ? AppColors.brandOrange
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height:60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandOrange
                                : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _img(_imageOf(cat)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.brandOrange
                              : AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ----- Right pane: hero + subcategories -----
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              children: [
                _buildHero(selected),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 15,
                          decoration: BoxDecoration(
                            color: AppColors.brandOrange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Subcategories',
                          style: AppTextStyle.sectionHeading.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _openCategory(selected),
                      child: Text(
                        'View All (${subs.length}) →',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (subs.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subs.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.74,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, i) =>
                        _subcategoryTile(selected, subs[i]),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 36, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'No subcategories in ${selected.name} yet.',
                          style: AppTextStyle.caption
                              .copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(CategoryApiModel cat) {
    return GestureDetector(
      onTap: () => _openCategory(cat),
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _img(_imageOf(cat)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cat.children.length} Subcategories',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.sectionHeading.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Explore all styles →',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.brandBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subcategoryTile(CategoryApiModel parent, CategoryApiModel sub) {
    return GestureDetector(
      onTap: () => _openCategory(parent, sub),
      child: Column(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 4),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _img(sub.image),
          ),
          const SizedBox(height: 6),
          Text(
            sub.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- VISUAL GRID VIEW ----------------
  Widget _buildVisualGridView(List<CategoryApiModel> categories) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            // Tapping a tile jumps to Rail View showing its subcategories
            onTap: () {
              context
                  .read<CategoryBloc>()
                  .add(SelectCategoryEvent(categoryId: cat.id));
              setState(() => _layout = CategoryViewLayout.splitRail);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _img(_imageOf(cat)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cat.children.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.children.isNotEmpty
                                    ? cat.children
                                    .take(3)
                                    .map((c) => c.name)
                                    .join(' • ')
                                    : 'Shoploc Boutique',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  size: 12, color: AppColors.brandBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.brandOrange),
            const SizedBox(height: 12),
            Text('No Categories Found', style: AppTextStyle.sectionHeading),
            const SizedBox(height: 6),
            Text('No category matches "$_query".', style: AppTextStyle.caption),
          ],
        ),
      ),
    );
  }
}