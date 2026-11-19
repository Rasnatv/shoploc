//
// import 'dart:ui' show ImageFilter;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shoploc/app/ui/subcategory_productscreen.dart';
// import '../bloc/categoriesbloc/category_bloc.dart';
// import '../bloc/categoriesbloc/category_event.dart';
// import '../bloc/categoriesbloc/category_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../data/models/homemodel.dart';
//
//
// enum CategoryViewLayout { splitRail, visualGrid }
//
// /// Creates its own [CategoryBloc], so nothing needs registering in main.dart.
// class CategoriesScreen extends StatelessWidget {
//   /// When opened from Home, the tapped category is pre-selected in Rail View.
//   final CategoryApiModel? initialCategory;
//
//   const CategoriesScreen({super.key, this.initialCategory});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => CategoryBloc()..add(const LoadCategoriesEvent()),
//       child: _CategoriesView(initialCategory: initialCategory),
//     );
//   }
// }
//
// class _CategoriesView extends StatefulWidget {
//   final CategoryApiModel? initialCategory;
//   const _CategoriesView({this.initialCategory});
//
//   @override
//   State<_CategoriesView> createState() => _CategoriesViewState();
// }
//
// class _CategoriesViewState extends State<_CategoriesView> {
//   // Neutral colors for this screen (no orange/pink tint)
//   static const Color _neutralBg = Color(0xFFF3F3F3);
//   static const Color _neutralBorder = Color(0xFFE2E2E2);
//
//   CategoryViewLayout _layout = CategoryViewLayout.splitRail;
//   bool _initialApplied = false;
//   final TextEditingController _searchController = TextEditingController();
//   bool _isSearchActive = false;
//   String _query = '';
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // ---- Navigation hook ----
//   /// Open the product list for a subcategory (POST /subcategory/products).
//   /// The API only works per subcategory, so a parent-only tap does nothing yet.
//   void _openCategory(CategoryApiModel category, [CategoryApiModel? sub]) {
//     if (sub == null) return;
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (_) => SubCategoryProductsScreen(
//         subCategory: sub,
//         parentName: category.name,
//       ),
//     ));
//   }
//
//   // ---- Helpers ----
//   String _imageOf(CategoryApiModel c) {
//     if (c.image.isNotEmpty) return c.image;
//     for (final child in c.children) {
//       if (child.image.isNotEmpty) return child.image;
//     }
//     return '';
//   }
//
//   /// Neutral placeholder (no orange/pink tint).
//   Widget _placeholder(IconData icon) => Container(
//     color: _neutralBg,
//     alignment: Alignment.center,
//     child: Icon(icon, color: Colors.grey.shade500, size: 24),
//   );
//
//   /// [fit] cover = fills the box; [alignment] topCenter keeps the head/face
//   /// visible when a portrait photo is cropped into a circle or banner.
//   Widget _img(
//       String url, {
//         IconData icon = Icons.category_outlined,
//         BoxFit fit = BoxFit.cover,
//         Alignment alignment = Alignment.topCenter,
//       }) {
//     if (url.isEmpty) return _placeholder(icon);
//     return Image.network(
//       url,
//       fit: fit,
//       alignment: alignment,
//       width: double.infinity,
//       height: double.infinity,
//       loadingBuilder: (context, child, progress) =>
//       progress == null ? child : Container(color: _neutralBg),
//       errorBuilder: (context, error, stack) => _placeholder(icon),
//     );
//   }
//
//   /// Circle that is ALWAYS completely filled by the image.
//   /// The border is drawn on top, so nothing behind it can show through.
//   /// [zoom] slightly enlarges the photo to hide any baked-in white/pink margin.
//   Widget _circleImage(
//       String url, {
//         required double size,
//         Color borderColor = _neutralBorder,
//         double borderWidth = 1.5,
//         double zoom = 1.0,
//         IconData icon = Icons.category_outlined,
//       }) {
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: ClipOval(
//               child: url.isEmpty
//                   ? _placeholder(icon)
//                   : Transform.scale(
//                 scale: zoom,
//                 child: Image.network(
//                   url,
//                   width: size,
//                   height: size,
//                   fit: BoxFit.cover,
//                   alignment: Alignment.topCenter,
//                   loadingBuilder: (context, child, progress) =>
//                   progress == null
//                       ? child
//                       : Container(color: _neutralBg),
//                   errorBuilder: (context, error, stack) =>
//                       _placeholder(icon),
//                 ),
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: IgnorePointer(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: borderColor, width: borderWidth),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _onRefresh() async {
//     final bloc = context.read<CategoryBloc>();
//     bloc.add(const RefreshCategoriesEvent());
//     await bloc.stream.first;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CategoryBloc, CategoryState>(
//       // Runs once, when the categories first finish loading
//       listenWhen: (_, s) => s is CategoryLoadedState && !_initialApplied,
//       listener: (context, state) {
//         _initialApplied = true;
//         final initial = widget.initialCategory;
//         if (initial != null) {
//           context
//               .read<CategoryBloc>()
//               .add(SelectCategoryEvent(categoryId: initial.id));
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.scaffoldBackground,
//         appBar: _buildAppBar(),
//         body: BlocBuilder<CategoryBloc, CategoryState>(
//           builder: (context, state) {
//             if (state is CategoryLoadingState || state is CategoryInitialState) {
//               return const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//                 ),
//               );
//             }
//
//             if (state is CategoryErrorState) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.error_outline,
//                           size: 48, color: AppColors.error),
//                       const SizedBox(height: 12),
//                       Text(state.errorMessage,
//                           textAlign: TextAlign.center,
//                           style: AppTextStyle.bodyMedium),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => context
//                             .read<CategoryBloc>()
//                             .add(const LoadCategoriesEvent()),
//                         child: const Text('Try Again'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//
//             if (state is CategoryLoadedState) {
//               if (state.categories.isEmpty) {
//                 return const Center(child: Text('No categories available'));
//               }
//
//               final q = _query.toLowerCase();
//               final filtered = q.isEmpty
//                   ? state.categories
//                   : state.categories.where((c) {
//                 return c.name.toLowerCase().contains(q) ||
//                     c.children.any((s) => s.name.toLowerCase().contains(q));
//               }).toList();
//
//               return Column(
//                 children: [
//                   if (_isSearchActive) _buildInlineSearchBar(),
//                   _buildLayoutSwitcher(),
//                   Expanded(
//                     child: filtered.isEmpty
//                         ? _buildEmptySearch()
//                         : _layout == CategoryViewLayout.splitRail
//                         ? _buildSplitRailView(filtered, state)
//                         : _buildVisualGridView(filtered),
//                   ),
//                 ],
//               );
//             }
//
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
//
//   // ---------------- APP BAR ----------------
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.surface,
//       surfaceTintColor: Colors.transparent,
//       scrolledUnderElevation: 1,
//       elevation: 0,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//               'Categories',
//               style: AppTextStyle.appBarTitle
//           ),
//           Text(
//             'Explore all collections & subcategories',
//             style: AppTextStyle.caption.copyWith(
//               fontSize: 11,
//               color: AppColors.textTertiary,
//               letterSpacing: 0.2,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(
//             _isSearchActive ? Icons.search_off_rounded : Icons.search_rounded,
//             color:
//             _isSearchActive ? AppColors.brandOrange : AppColors.textPrimary,
//           ),
//           tooltip: 'Search Categories',
//           onPressed: () {
//             setState(() {
//               _isSearchActive = !_isSearchActive;
//               if (!_isSearchActive) {
//                 _searchController.clear();
//                 _query = '';
//               }
//             });
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
//           hintText: 'Search categories & subcategories...',
//           hintStyle: AppTextStyle.inputHint,
//           prefixIcon: const Icon(Icons.search_rounded,
//               color: AppColors.brandOrange, size: 22),
//           suffixIcon: _query.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, size: 20),
//             onPressed: () {
//               setState(() {
//                 _searchController.clear();
//                 _query = '';
//               });
//             },
//           )
//               : null,
//           filled: true,
//           fillColor: _neutralBg,
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         onChanged: (val) => setState(() => _query = val.trim()),
//       ),
//     );
//   }
//
//   Widget _buildLayoutSwitcher() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: const BoxDecoration(
//         color: AppColors.surface,
//         border: Border(
//           bottom: BorderSide(color: _neutralBorder, width: 1),
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
//               _layoutOption(
//                 icon: Icons.splitscreen_rounded,
//                 label: 'Rail View',
//                 selected: _layout == CategoryViewLayout.splitRail,
//                 onTap: () =>
//                     setState(() => _layout = CategoryViewLayout.splitRail),
//               ),
//               const SizedBox(width: 8),
//               _layoutOption(
//                 icon: Icons.grid_view_rounded,
//                 label: 'Grid View',
//                 selected: _layout == CategoryViewLayout.visualGrid,
//                 onTap: () =>
//                     setState(() => _layout = CategoryViewLayout.visualGrid),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _layoutOption({
//     required IconData icon,
//     required String label,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: selected
//               ? AppColors.brandOrange.withValues(alpha: 0.12)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: selected ? AppColors.brandOrange : _neutralBorder,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon,
//                 size: 14,
//                 color:
//                 selected ? AppColors.brandOrange : AppColors.textSecondary),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
//                 color:
//                 selected ? AppColors.brandOrange : AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---------------- SPLIT RAIL VIEW ----------------
//   Widget _buildSplitRailView(
//       List<CategoryApiModel> categories, CategoryLoadedState state) {
//     final selected = categories.firstWhere(
//           (c) => c.id == state.selectedCategoryId,
//       orElse: () => categories.first,
//     );
//     final subs = selected.children;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ----- Left rail: parent categories -----
//         Container(
//           width: 104,
//           decoration: const BoxDecoration(
//             color: _neutralBg,
//             border: Border(
//               right: BorderSide(color: _neutralBorder, width: 1),
//             ),
//           ),
//           child: ListView.builder(
//             itemCount: categories.length,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             itemBuilder: (context, index) {
//               final cat = categories[index];
//               final isSelected = cat.id == selected.id;
//
//               return GestureDetector(
//                 onTap: () => context
//                     .read<CategoryBloc>()
//                     .add(SelectCategoryEvent(categoryId: cat.id)),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 180),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.surface : Colors.transparent,
//                     border: Border(
//                       left: BorderSide(
//                         color: isSelected
//                             ? AppColors.brandOrange
//                             : Colors.transparent,
//                         width: 4,
//                       ),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _circleImage(
//                         _imageOf(cat),
//                         size: 56,
//                         zoom: 1.15,
//                         borderColor: isSelected
//                             ? AppColors.brandOrange
//                             : _neutralBorder,
//                         borderWidth: isSelected ? 2.5 : 1,
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         cat.name,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight:
//                           isSelected ? FontWeight.w800 : FontWeight.w600,
//                           color: isSelected
//                               ? AppColors.brandOrange
//                               : AppColors.textPrimary,
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
//         // ----- Right pane: hero + subcategories -----
//         Expanded(
//           child: RefreshIndicator(
//             color: AppColors.primary,
//             onRefresh: _onRefresh,
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: const EdgeInsets.all(14),
//               children: [
//                 _buildHero(selected),
//                 const SizedBox(height: 18),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 3.5,
//                           height: 15,
//                           decoration: BoxDecoration(
//                             color: AppColors.brandOrange,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Subcategories',
//                           style: AppTextStyle.sectionHeading.copyWith(
//                             fontSize: 14.5,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                       ],
//                     ),
//                     GestureDetector(
//                       onTap: () => _openCategory(selected),
//                       child: Text(
//                         'View All (${subs.length}) →',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.brandOrange,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 if (subs.isNotEmpty)
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: subs.length,
//                     gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       childAspectRatio: 0.9,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 12,
//                     ),
//                     itemBuilder: (context, i) =>
//                         _subcategoryTile(selected, subs[i]),
//                   )
//                 else
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: AppColors.surface,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: _neutralBorder),
//                     ),
//                     child: Column(
//                       children: [
//                         const Icon(Icons.inventory_2_outlined,
//                             size: 36, color: AppColors.textTertiary),
//                         const SizedBox(height: 8),
//                         Text(
//                           'No subcategories in ${selected.name} yet.',
//                           style: AppTextStyle.caption
//                               .copyWith(color: AppColors.textSecondary),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHero(CategoryApiModel cat) {
//     return GestureDetector(
//       onTap: () => _openCategory(cat),
//       child: Container(
//         height: 150,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: const [
//             BoxShadow(
//               color: AppColors.shadowMedium,
//               blurRadius: 10,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // blurred backdrop fills the banner...
//             ImageFiltered(
//               imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
//               child: _img(_imageOf(cat)),
//             ),
//             Container(color: Colors.black.withValues(alpha: 0.25)),
//             // ...and the full, uncropped image sits on top
//             _img(_imageOf(cat),
//                 fit: BoxFit.contain, alignment: Alignment.center),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.black.withValues(alpha: 0.8),
//                     Colors.black.withValues(alpha: 0.2),
//                   ],
//                   begin: Alignment.bottomLeft,
//                   end: Alignment.topRight,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: AppColors.brandOrange,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${cat.children.length} Subcategories',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 9.5,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               cat.name,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyle.sectionHeading.copyWith(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'Explore all styles →',
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.9),
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.arrow_forward_rounded,
//                             size: 14, color: AppColors.brandBlue),
//                       ),
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
//
//   /// Clean white circle, thin neutral border, no pink shadow.
//   Widget _subcategoryTile(CategoryApiModel parent, CategoryApiModel sub) {
//     return GestureDetector(
//       onTap: () => _openCategory(parent, sub),
//       child: Column(
//         children: [
//           _circleImage(sub.image, size: 68, zoom: 1.15),
//           const SizedBox(height: 6),
//           Text(
//             sub.name,
//             maxLines: 2,
//             textAlign: TextAlign.center,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//               height: 1.15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------- VISUAL GRID VIEW ----------------
//   Widget _buildVisualGridView(List<CategoryApiModel> categories) {
//     return RefreshIndicator(
//       color: AppColors.primary,
//       onRefresh: _onRefresh,
//       child: GridView.builder(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         itemCount: categories.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.72,
//           crossAxisSpacing: 14,
//           mainAxisSpacing: 14,
//         ),
//         itemBuilder: (context, index) {
//           final cat = categories[index];
//           return GestureDetector(
//             // Tapping a tile jumps to Rail View showing its subcategories
//             onTap: () {
//               context
//                   .read<CategoryBloc>()
//                   .add(SelectCategoryEvent(categoryId: cat.id));
//               setState(() => _layout = CategoryViewLayout.splitRail);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.surface,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: _neutralBorder),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: AppColors.shadowMedium,
//                     blurRadius: 10,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   _img(_imageOf(cat)),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.black.withValues(alpha: 0.85),
//                           Colors.black.withValues(alpha: 0.2),
//                           Colors.transparent,
//                         ],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         stops: const [0.0, 0.55, 1.0],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: AppColors.brandOrange,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         '${cat.children.length}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 12,
//                     left: 12,
//                     right: 12,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           cat.name,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 cat.children.isNotEmpty
//                                     ? cat.children
//                                     .take(3)
//                                     .map((c) => c.name)
//                                     .join(' • ')
//                                     : 'Shoploc Boutique',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   color: Colors.white.withValues(alpha: 0.9),
//                                   fontSize: 10.5,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.arrow_forward_rounded,
//                                   size: 12, color: AppColors.brandBlue),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
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
//             const Icon(Icons.search_off_rounded,
//                 size: 48, color: AppColors.brandOrange),
//             const SizedBox(height: 12),
//             Text('No Categories Found', style: AppTextStyle.sectionHeading),
//             const SizedBox(height: 6),
//             Text('No category matches "$_query".', style: AppTextStyle.caption),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/subcategory_productscreen.dart';
import '../bloc/categoriesbloc/category_bloc.dart';
import '../bloc/categoriesbloc/category_event.dart';
import '../bloc/categoriesbloc/category_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/homemodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/responsive.dart';

enum CategoryViewLayout { splitRail, visualGrid }

/// Creates its own [CategoryBloc], so nothing needs registering in main.dart.
class CategoriesScreen extends StatelessWidget {
  /// When opened from Home, the tapped category is pre-selected in Rail View.
  final CategoryApiModel? initialCategory;

  const CategoriesScreen({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryBloc()..add(const LoadCategoriesEvent()),
      child: _CategoriesView(initialCategory: initialCategory),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  final CategoryApiModel? initialCategory;
  const _CategoriesView({this.initialCategory});

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  // Neutral colors for this screen (no orange/pink tint)
  static const Color _neutralBg = Color(0xFFF3F3F3);
  static const Color _neutralBorder = Color(0xFFE2E2E2);

  CategoryViewLayout _layout = CategoryViewLayout.splitRail;
  bool _initialApplied = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- RESPONSIVE HELPERS ----------------

  /// Scale factor for phone widths only (320-480). Responsive.w() keeps
  /// growing on tablets, which would make circles/paddings huge, so sizes
  /// use this capped factor and tablets get explicit values instead.
  double get _scale => (Responsive.screenWidth.clamp(320.0, 480.0)).toDouble() / 390.0;

  double _w(double designValue) => designValue * _scale;

  /// Max width of the screen content on big screens.
  double get _maxContentWidth => Responsive.value(
    mobile: double.infinity,
    tablet: 720.0,
    desktop: 960.0,
  );

  double get _railWidth => Responsive.value(
    mobile: _w(104),
    tablet: 128.0,
    desktop: 140.0,
  );

  double get _railCircleSize => Responsive.value(
    mobile: _w(56),
    tablet: 64.0,
    desktop: 68.0,
  );

  double get _subCircleSize => Responsive.value(
    mobile: _w(68),
    tablet: 76.0,
    desktop: 80.0,
  );

  double get _subTileMaxExtent => Responsive.value(
    mobile: _w(120),
    tablet: 130.0,
    desktop: 140.0,
  );

  double get _heroHeight => Responsive.value(
    mobile: _w(150),
    tablet: 200.0,
    desktop: 220.0,
  );

  int get _visualGridColumns => Responsive.value(
    mobile: 2,
    tablet: 3,
    desktop: 4,
  );

  // ---- Navigation hook ----
  /// Open the product list for a subcategory (POST /subcategory/products).
  /// The API only works per subcategory, so a parent-only tap shows a hint.
  void _openCategory(CategoryApiModel category, [CategoryApiModel? sub]) {
    if (sub == null) {
      AppSnackbar.warning('Select a subcategory to see its products');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SubCategoryProductsScreen(
        subCategory: sub,
        parentName: category.name,
      ),
    ));
  }

  // ---- Helpers ----
  String _imageOf(CategoryApiModel c) {
    if (c.image.isNotEmpty) return c.image;
    for (final child in c.children) {
      if (child.image.isNotEmpty) return child.image;
    }
    return '';
  }

  /// Neutral placeholder (no orange/pink tint).
  Widget _placeholder(IconData icon) => Container(
    color: _neutralBg,
    alignment: Alignment.center,
    child: Icon(icon, color: Colors.grey.shade500, size: _w(24)),
  );

  /// [fit] cover = fills the box; [alignment] topCenter keeps the head/face
  /// visible when a portrait photo is cropped into a circle or banner.
  Widget _img(
      String url, {
        IconData icon = Icons.category_outlined,
        BoxFit fit = BoxFit.cover,
        Alignment alignment = Alignment.topCenter,
      }) {
    if (url.isEmpty) return _placeholder(icon);
    return Image.network(
      url,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) =>
      progress == null ? child : Container(color: _neutralBg),
      errorBuilder: (context, error, stack) => _placeholder(icon),
    );
  }

  /// Circle that is ALWAYS completely filled by the image.
  /// The border is drawn on top, so nothing behind it can show through.
  /// [zoom] slightly enlarges the photo to hide any baked-in white/pink margin.
  Widget _circleImage(
      String url, {
        required double size,
        Color borderColor = _neutralBorder,
        double borderWidth = 1.5,
        double zoom = 1.0,
        IconData icon = Icons.category_outlined,
      }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: url.isEmpty
                  ? _placeholder(icon)
                  : Transform.scale(
                scale: zoom,
                child: Image.network(
                  url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  loadingBuilder: (context, child, progress) =>
                  progress == null
                      ? child
                      : Container(color: _neutralBg),
                  errorBuilder: (context, error, stack) =>
                      _placeholder(icon),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<CategoryBloc>();
    bloc.add(const RefreshCategoriesEvent());
    await bloc.stream.first;
  }

  @override
  Widget build(BuildContext context) {
    // Refresh screen metrics (re-runs on rotation / window resize).
    Responsive.init(context);

    return BlocListener<CategoryBloc, CategoryState>(
      // Runs once, when the categories first finish loading
      listenWhen: (_, s) => s is CategoryLoadedState && !_initialApplied,
      listener: (context, state) {
        _initialApplied = true;
        final initial = widget.initialCategory;
        if (initial != null) {
          context
              .read<CategoryBloc>()
              .add(SelectCategoryEvent(categoryId: initial.id));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: _buildAppBar(),
        body: SafeArea(
          top: false,
          // Centers and caps the content width on tablet/desktop.
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _maxContentWidth),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<CategoryBloc, CategoryState>(
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(_w(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: _w(48), color: AppColors.error),
                  SizedBox(height: _w(12)),
                  Text(state.errorMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium),
                  SizedBox(height: _w(16)),
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
            // stretch => header bars fill the (possibly capped) width
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );
  }

  // ---------------- APP BAR ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: AppTextStyle.appBarTitle,
          ),
          Text(
            'Explore all collections & subcategories',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption.copyWith(
              fontSize: Responsive.sp(11),
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
        SizedBox(width: _w(4)),
      ],
    );
  }

  Widget _buildInlineSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(_w(16), _w(6), _w(16), _w(10)),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search categories & subcategories...',
          hintStyle: AppTextStyle.inputHint,
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.brandOrange, size: _w(22)),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, size: _w(20)),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _query = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: _neutralBg,
          contentPadding:
          EdgeInsets.symmetric(horizontal: _w(14), vertical: _w(10)),
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
    // Very narrow phones: show icons only so the row can't overflow.
    final showLabels = Responsive.screenWidth >= 360;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _w(16), vertical: _w(8)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: _neutralBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Explore Collections',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.labelMedium.copyWith(
                fontSize: Responsive.sp(13),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: _w(8)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _layoutOption(
                icon: Icons.splitscreen_rounded,
                label: 'Rail View',
                showLabel: showLabels,
                selected: _layout == CategoryViewLayout.splitRail,
                onTap: () =>
                    setState(() => _layout = CategoryViewLayout.splitRail),
              ),
              SizedBox(width: _w(8)),
              _layoutOption(
                icon: Icons.grid_view_rounded,
                label: 'Grid View',
                showLabel: showLabels,
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
    required bool showLabel,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
              horizontal: _w(10), vertical: _w(5)),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brandOrange.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.brandOrange : _neutralBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: Responsive.sp(14),
                  color: selected
                      ? AppColors.brandOrange
                      : AppColors.textSecondary),
              if (showLabel) ...[
                SizedBox(width: _w(4)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Responsive.sp(11),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.brandOrange
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
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
          width: _railWidth,
          decoration: const BoxDecoration(
            color: _neutralBg,
            border: Border(
              right: BorderSide(color: _neutralBorder, width: 1),
            ),
          ),
          child: ListView.builder(
            itemCount: categories.length,
            padding: EdgeInsets.symmetric(vertical: _w(8)),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == selected.id;

              return GestureDetector(
                onTap: () => context
                    .read<CategoryBloc>()
                    .add(SelectCategoryEvent(categoryId: cat.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                      horizontal: _w(8), vertical: _w(12)),
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
                      _circleImage(
                        _imageOf(cat),
                        size: _railCircleSize,
                        zoom: 1.15,
                        borderColor: isSelected
                            ? AppColors.brandOrange
                            : _neutralBorder,
                        borderWidth: isSelected ? 2.5 : 1,
                      ),
                      SizedBox(height: _w(6)),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.sp(11),
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
              padding: EdgeInsets.all(_w(14)),
              children: [
                _buildHero(selected),
                SizedBox(height: _w(18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: _w(15),
                            decoration: BoxDecoration(
                              color: AppColors.brandOrange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: _w(8)),
                          Flexible(
                            child: Text(
                              'Subcategories',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.sectionHeading.copyWith(
                                fontSize: Responsive.sp(14.5),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: _w(8)),
                    GestureDetector(
                      onTap: () => _openCategory(selected),
                      child: Text(
                        'View All (${subs.length}) →',
                        style: TextStyle(
                          fontSize: Responsive.sp(11),
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _w(12)),
                if (subs.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subs.length,
                    // Column count adapts to the pane width automatically.
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: _subTileMaxExtent,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: _w(8),
                      mainAxisSpacing: _w(12),
                    ),
                    itemBuilder: (context, i) =>
                        _subcategoryTile(selected, subs[i]),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(_w(24)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _neutralBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: _w(36), color: AppColors.textTertiary),
                        SizedBox(height: _w(8)),
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
        height: _heroHeight,
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
            // blurred backdrop fills the banner...
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: _img(_imageOf(cat)),
            ),
            Container(color: Colors.black.withValues(alpha: 0.25)),
            // ...and the full, uncropped image sits on top
            _img(_imageOf(cat),
                fit: BoxFit.contain, alignment: Alignment.center),
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
              padding: EdgeInsets.all(_w(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _w(8), vertical: _w(3)),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cat.children.length} Subcategories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(9.5),
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
                                fontSize: Responsive.sp(18),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: _w(2)),
                            Text(
                              'Explore all styles →',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: Responsive.sp(11),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(_w(6)),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: Responsive.sp(14),
                            color: AppColors.brandBlue),
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

  /// Clean white circle, thin neutral border, no pink shadow.
  Widget _subcategoryTile(CategoryApiModel parent, CategoryApiModel sub) {
    return GestureDetector(
      onTap: () => _openCategory(parent, sub),
      child: Column(
        children: [
          _circleImage(sub.image, size: _subCircleSize, zoom: 1.15),
          SizedBox(height: _w(6)),
          Text(
            sub.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.sp(11),
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
        padding: EdgeInsets.all(_w(16)),
        itemCount: categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _visualGridColumns, // 2 / 3 / 4
          childAspectRatio: 0.72,
          crossAxisSpacing: _w(14),
          mainAxisSpacing: _w(14),
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
                border: Border.all(color: _neutralBorder),
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
                    top: _w(10),
                    right: _w(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: _w(8), vertical: _w(3)),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cat.children.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(10),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: _w(12),
                    left: _w(12),
                    right: _w(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.sp(16),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: _w(2)),
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
                                  fontSize: Responsive.sp(10.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(_w(4)),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_forward_rounded,
                                  size: Responsive.sp(12),
                                  color: AppColors.brandBlue),
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
      child: SingleChildScrollView(
        padding: EdgeInsets.all(_w(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: _w(48), color: AppColors.brandOrange),
            SizedBox(height: _w(12)),
            Text('No Categories Found', style: AppTextStyle.sectionHeading),
            SizedBox(height: _w(6)),
            Text(
              'No category matches "$_query".',
              textAlign: TextAlign.center,
              style: AppTextStyle.caption,
            ),
          ],
        ),
      ),
    );
  }
}