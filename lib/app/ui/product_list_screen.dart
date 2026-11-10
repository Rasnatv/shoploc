import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/productbloc/product_bloc.dart';
import '../bloc/productbloc/product_event.dart';
import '../bloc/productbloc/product_state.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/dummy_data/shoploc_dummy_data.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialSubcategory;
  final String? categoryTitle;
  final bool autoFocusSearch;

  const ProductListScreen({
    super.key,
    this.initialCategoryId,
    this.initialSubcategory,
    this.categoryTitle,
    this.autoFocusSearch = false,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _isSearching = widget.autoFocusSearch;
    context.read<ProductBloc>().add(
          LoadProductsEvent(
            categoryId: widget.initialCategoryId,
            subcategory: widget.initialSubcategory,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet(BuildContext context, ProductListLoadedState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text('Sort By', style: AppTextStyle.sectionHeading),
                ),
                const Divider(),
                _buildSortOption(
                  bottomSheetContext,
                  title: 'Popularity & Rating',
                  value: 'popularity',
                  selectedValue: state.activeSortBy,
                  state: state,
                ),
                _buildSortOption(
                  bottomSheetContext,
                  title: 'Newest Arrivals',
                  value: 'newest',
                  selectedValue: state.activeSortBy,
                  state: state,
                ),
                _buildSortOption(
                  bottomSheetContext,
                  title: 'Price: Low to High',
                  value: 'price_asc',
                  selectedValue: state.activeSortBy,
                  state: state,
                ),
                _buildSortOption(
                  bottomSheetContext,
                  title: 'Price: High to Low',
                  value: 'price_desc',
                  selectedValue: state.activeSortBy,
                  state: state,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext ctx, {
    required String title,
    required String value,
    required String selectedValue,
    required ProductListLoadedState state,
  }) {
    final isSelected = value == selectedValue;
    return ListTile(
      title: Text(
        title,
        style: isSelected
            ? AppTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              )
            : AppTextStyle.bodyMedium,
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
      onTap: () {
        Navigator.pop(ctx);
        context.read<ProductBloc>().add(
              FilterProductsEvent(
                categoryId: state.activeCategoryId,
                priceRange: state.activePriceRange,
                selectedSize: state.activeSize,
                selectedColor: state.activeColor,
                sortBy: value,
                searchQuery: state.searchQuery,
              ),
            );
      },
    );
  }

  void _showFilterModal(BuildContext context, ProductListLoadedState state) {
    RangeValues currentRange = state.activePriceRange ?? const RangeValues(500, 7000);
    String? selectedCategory = state.activeCategoryId;
    String? selectedSize = state.activeSize;
    String? selectedColor = state.activeColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (filterContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
            final availableColors = [
              'Rosewood',
              'Sage Green',
              'Midnight Blue',
              'Dusty Rose',
              'Terracotta',
              'Ivory White',
              'Noir Black',
            ];

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle & Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filters', style: AppTextStyle.screenTitle),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                currentRange = const RangeValues(500, 7000);
                                selectedCategory = null;
                                selectedSize = null;
                                selectedColor = null;
                              });
                            },
                            child: Text(
                              'Reset All',
                              style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Filter Options
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Price Range
                          Text('Price Range (₹)', style: AppTextStyle.labelLarge),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₹${currentRange.start.toInt()}', style: AppTextStyle.caption),
                              Text('₹${currentRange.end.toInt()}', style: AppTextStyle.caption),
                            ],
                          ),
                          RangeSlider(
                            values: currentRange,
                            min: 500,
                            max: 7000,
                            divisions: 26,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.border,
                            onChanged: (values) {
                              setModalState(() => currentRange = values);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Category Filter
                          Text('Categories', style: AppTextStyle.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ShoplocDummyData.categories.map((c) {
                              final isCatSelected = selectedCategory == c.id;
                              return ChoiceChip(
                                label: Text(c.name),
                                selected: isCatSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: AppTextStyle.caption.copyWith(
                                  color: isCatSelected ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (sel) {
                                  setModalState(() {
                                    selectedCategory = sel ? c.id : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Size Filter
                          Text('Size', style: AppTextStyle.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableSizes.map((s) {
                              final isSizeSelected = selectedSize == s;
                              return ChoiceChip(
                                label: Text(s),
                                selected: isSizeSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: AppTextStyle.caption.copyWith(
                                  color: isSizeSelected ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (sel) {
                                  setModalState(() {
                                    selectedSize = sel ? s : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Color Filter
                          Text('Colors', style: AppTextStyle.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableColors.map((col) {
                              final isColorSelected = selectedColor == col;
                              return ChoiceChip(
                                label: Text(col),
                                selected: isColorSelected,
                                selectedColor: AppColors.primary,
                                labelStyle: AppTextStyle.caption.copyWith(
                                  color: isColorSelected ? AppColors.textLight : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (sel) {
                                  setModalState(() {
                                    selectedColor = sel ? col : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Apply CTA
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomButton(
                        text: 'Apply Filters',
                        onPressed: () {
                          Navigator.pop(filterContext);
                          context.read<ProductBloc>().add(
                                FilterProductsEvent(
                                  categoryId: selectedCategory,
                                  priceRange: currentRange,
                                  selectedSize: selectedSize,
                                  selectedColor: selectedColor,
                                  sortBy: state.activeSortBy,
                                  searchQuery: state.searchQuery,
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSubcategoryPills(BuildContext context, ProductListLoadedState state) {
    final catList = ShoplocDummyData.categories
        .where((c) => c.id == state.activeCategoryId)
        .toList();
    if (catList.isEmpty || catList.first.subcategories.isEmpty) {
      return const SizedBox.shrink();
    }
    final category = catList.first;
    final allSubcategories = ['All', ...category.subcategories];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allSubcategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sub = allSubcategories[index];
          final isSelected = (sub == 'All' && state.activeSubcategory == null) ||
              state.activeSubcategory == sub;

          return GestureDetector(
            onTap: () {
              context.read<ProductBloc>().add(
                    LoadProductsEvent(
                      categoryId: state.activeCategoryId,
                      subcategory: sub == 'All' ? null : sub,
                    ),
                  );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandOrange : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.brandOrange : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.brandOrange.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                sub,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyle.inputText,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: AppTextStyle.inputHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (query) {
                  context.read<ProductBloc>().add(SearchProductsEvent(query: query));
                },
              )
            : Text(
                widget.categoryTitle ?? 'All Products',
                style: AppTextStyle.appBarTitle,
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 22),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<ProductBloc>().add(
                        LoadProductsEvent(
                          categoryId: widget.initialCategoryId,
                          subcategory: widget.initialSubcategory,
                        ),
                      );
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is ProductListLoadedState) {
            return Column(
              children: [
                // Filter & Sort Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.products.length} Products',
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Sort Button
                      GestureDetector(
                        onTap: () => _showSortBottomSheet(context, state),
                        child: Row(
                          children: [
                            const Icon(Icons.sort_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Filter Button
                      GestureDetector(
                        onTap: () => _showFilterModal(context, state),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Filter',
                              style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Subcategory Quick Filter Chips
                if (state.activeCategoryId != null)
                  _buildSubcategoryPills(context, state),

                // Product Grid or Empty State
                Expanded(
                  child: state.products.isEmpty
                      ? EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No Products Found',
                          message:
                              'We couldn\'t find any items matching your selected criteria. Try adjusting your filters or search keywords.',
                          buttonText: 'Reset Filters',
                          onButtonPressed: () {
                            context.read<ProductBloc>().add(
                                  const LoadProductsEvent(),
                                );
                          },
                        )
                      : BlocBuilder<WishlistBloc, WishlistState>(
                          builder: (context, wishlistState) {
                            final wishlistIds = wishlistState is WishlistLoadedState
                                ? wishlistState.items.map((p) => p.id).toSet()
                                : <String>{};

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.products.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.64,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemBuilder: (context, index) {
                                final product = state.products[index];
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
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
