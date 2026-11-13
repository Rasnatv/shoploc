import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../bloc/categoriesbloc/category_bloc.dart';
import '../bloc/categoriesbloc/category_event.dart';
import '../bloc/categoriesbloc/category_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../data/dummy_data/shoploc_dummy_data.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../widgets/network_image_with_fallback.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import 'product_list_screen.dart';


enum CategoryViewLayout { splitRail, visualGrid }

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryViewLayout _currentLayout = CategoryViewLayout.splitRail;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCategory(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    String? subcategory,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          initialCategoryId: categoryId,
          initialSubcategory: subcategory,
          categoryTitle: subcategory != null
              ? '$subcategory • $categoryName'
              : categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is CategoryErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.errorMessage, style: AppTextStyle.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CategoryBloc>()
                        .add(const LoadCategoriesEvent()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryLoadedState) {
            final categories = state.categories;
            if (categories.isEmpty) {
              return const Center(child: Text('No categories available'));
            }

            // Apply search filter if active
            final filteredCategories = _searchQuery.isEmpty
                ? categories
                : categories.where((cat) {
                    final q = _searchQuery.toLowerCase();
                    return cat.name.toLowerCase().contains(q) ||
                        cat.description.toLowerCase().contains(q) ||
                        cat.subcategories.any((s) => s.toLowerCase().contains(q));
                  }).toList();

            return Column(
              children: [
                // Inline Search Bar (when search is toggled)
                if (_isSearchActive) _buildInlineSearchBar(),

                // Mode Selector Bar (Rail View vs Visual Grid)
                _buildLayoutSwitcher(),

                // Main Content View
                Expanded(
                  child: filteredCategories.isEmpty
                      ? _buildEmptySearch()
                      : _currentLayout == CategoryViewLayout.splitRail
                          ? _buildSplitRailView(filteredCategories)
                          : _buildVisualGridView(filteredCategories),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
            'Shop Indian Silhouettes & Western Outfits',
            style: AppTextStyle.caption.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        // Search Toggle
        IconButton(
          icon: Icon(
            _isSearchActive ? Icons.search_off_rounded : Icons.search_rounded,
            color: _isSearchActive ? AppColors.brandOrange : AppColors.textPrimary,
          ),
          tooltip: 'Search Categories',
          onPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),

        // Cart Icon with Real-Time Badge
        BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final count =
                cartState is CartLoadedState ? cartState.totalItemCount : 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  tooltip: 'Shopping Cart',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CartScreen(
                          onGoShopping: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.brandOrange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            );
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
          hintText: 'Search kurtas, co-ords, dresses...',
          hintStyle: AppTextStyle.inputHint,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.brandOrange,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          setState(() => _searchQuery = val.trim());
        },
      ),
    );
  }

  /// Top layout switcher: Split Browser vs Visual Grid
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
              _buildLayoutOption(
                icon: Icons.splitscreen_rounded,
                label: 'Rail View',
                isSelected: _currentLayout == CategoryViewLayout.splitRail,
                onTap: () {
                  setState(() => _currentLayout = CategoryViewLayout.splitRail);
                },
              ),
              const SizedBox(width: 8),
              _buildLayoutOption(
                icon: Icons.grid_view_rounded,
                label: 'Grid View',
                isSelected: _currentLayout == CategoryViewLayout.visualGrid,
                onTap: () {
                  setState(() => _currentLayout = CategoryViewLayout.visualGrid);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandOrange.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.brandOrange : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.brandOrange : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Split-Rail View: Left Category Navigation Rail + Right Detail Pane
  Widget _buildSplitRailView(List<CategoryModel> categories) {
    if (_selectedCategoryIndex >= categories.length) {
      _selectedCategoryIndex = 0;
    }
    final selectedCategory = categories[_selectedCategoryIndex];
    final previewProducts = ShoplocDummyData.products
        .where((p) => p.categoryId == selectedCategory.id)
        .take(4)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Category Sidebar Rail
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
              final isSelected = index == _selectedCategoryIndex;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? AppColors.brandOrange : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Thumbnail
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.brandOrange.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: NetworkImageWithFallback(
                          imageUrl: cat.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.brandOrange : AppColors.textPrimary,
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

        // Right Detail Pane: Category Banner + Subcategories Grid + Preview Products
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // Hero Category Banner
              GestureDetector(
                onTap: () => _navigateToCategory(
                  context,
                  categoryId: selectedCategory.id,
                  categoryName: selectedCategory.name,
                ),
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
                      NetworkImageWithFallback(
                        imageUrl: selectedCategory.imageUrl,
                        fit: BoxFit.cover,
                      ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${selectedCategory.productCount} Designs',
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
                                        selectedCategory.name,
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
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.brandBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Subcategories Section Header

              const SizedBox(height: 20),

              // Trending Picks in this Category
              if (previewProducts.isNotEmpty) ...[
                Text(
                  'Popular in ${selectedCategory.name}',
                  style: AppTextStyle.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previewProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, pIndex) {
                    final product = previewProducts[pIndex];
                    return _CategoryPreviewProductCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Visual Grid View: 2-column portrait boutique tiles
  Widget _buildVisualGridView(List<CategoryModel> categories) {
    return GridView.builder(
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
          onTap: () => _navigateToCategory(
            context,
            categoryId: cat.id,
            categoryName: cat.name,
          ),
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
                NetworkImageWithFallback(
                  imageUrl: cat.imageUrl,
                  fit: BoxFit.cover,
                ),
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
                // Item count badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brandOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cat.productCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Title and subtitle
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cat.subcategories.isNotEmpty
                                  ? '${cat.subcategories.length} Styles'
                                  : 'Shoploc Boutique',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.brandBlue,
                            ),
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
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.brandOrange),
            const SizedBox(height: 12),
            Text('No Categories Found', style: AppTextStyle.sectionHeading),
            const SizedBox(height: 6),
            Text(
              'No category matches "$_searchQuery".',
              style: AppTextStyle.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact mini product preview card for the right pane of Split-Rail view
class _CategoryPreviewProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _CategoryPreviewProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NetworkImageWithFallback(
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        Formatters.formatPrice(product.discountedPrice),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandOrange,
                        ),
                      ),
                      if (product.originalPrice > product.discountedPrice) ...[
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatPrice(product.originalPrice),
                          style: const TextStyle(
                            fontSize: 9.5,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
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
}
