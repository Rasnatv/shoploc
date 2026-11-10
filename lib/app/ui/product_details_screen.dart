import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/productbloc/product_bloc.dart';
import '../bloc/productbloc/product_event.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../data/models/product_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/product_card.dart';
import '../widgets/rating_badge.dart';

import 'cart_screen.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _imagePageController = PageController();
  int _activeImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.availableSizes.isNotEmpty) {
      _selectedSize = widget.product.availableSizes.first;
    }
    if (widget.product.availableColors.isNotEmpty) {
      _selectedColor = widget.product.availableColors.first;
    }
    context.read<ProductBloc>().add(
          LoadProductDetailsEvent(productId: widget.product.id),
        );
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  bool _validateSelections() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size first'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    if (_selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a color first'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    return true;
  }

  void _handleAddToCart() {
    if (!_validateSelections()) return;

    context.read<CartBloc>().add(
          AddToCartEvent(
            product: widget.product,
            selectedSize: _selectedSize!,
            selectedColor: _selectedColor!,
            quantity: _quantity,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${widget.product.name}" to cart!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
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
      ),
    );
  }

  void _handleBuyNow() {
    if (!_validateSelections()) return;

    context.read<CartBloc>().add(
          AddToCartEvent(
            product: widget.product,
            selectedSize: _selectedSize!,
            selectedColor: _selectedColor!,
            quantity: _quantity,
          ),
        );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            radius: 18,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16,color: Colors.black,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              final isWishlisted = state is WishlistLoadedState &&
                  state.isProductWishlisted(product.id);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                  radius: 18,
                  child: IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isWishlisted ? AppColors.primary : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      context.read<WishlistBloc>().add(
                            ToggleWishlistEvent(product: product),
                          );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: (size.height * 0.52).clamp(320.0, 480.0),
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: product.images.length,
                    onPageChanged: (i) => setState(() => _activeImageIndex = i),
                    itemBuilder: (context, index) {
                      return NetworkImageWithFallback(
                        imageUrl: product.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Dots Indicator
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(product.images.length, (idx) {
                          final isActive = idx == _activeImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 6,
                            width: isActive ? 20 : 6,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details Content Box
            Container(
              transform: Matrix4.translationValues(0, -16, 0),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.categoryName.toUpperCase(),
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.primary,
                        ),
                      ),
                      RatingBadge(
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Product Title
                  Text(product.name, style: AppTextStyle.mainHeading.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(product.subtitle, style: AppTextStyle.productSubtitle),
                  const SizedBox(height: 14),

                  // Price & Discount Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.formatPrice(product.discountedPrice),
                        style: AppTextStyle.productPriceLarge,
                      ),
                      const SizedBox(width: 10),
                      if (product.originalPrice > product.discountedPrice) ...[
                        Text(
                          Formatters.formatPrice(product.originalPrice),
                          style: AppTextStyle.originalPriceLarge,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.discountBadge,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.discountPercent}% OFF',
                            style: AppTextStyle.badgeText,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Size Selector
                  Text('Select Size', style: AppTextStyle.labelLarge),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: product.availableSizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: AppTextStyle.labelMedium.copyWith(
                                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Color Selector
                  Text('Available Colors', style: AppTextStyle.labelLarge),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: product.availableColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return ChoiceChip(
                        label: Text(color),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: AppTextStyle.caption.copyWith(
                          color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _selectedColor = color),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Selector & Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity', style: AppTextStyle.labelLarge),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline, size: 22),
                                color: AppColors.textPrimary,
                              ),
                              Text('$_quantity', style: AppTextStyle.labelLarge),
                              IconButton(
                                onPressed: _quantity < product.stockCount
                                    ? () => setState(() => _quantity++)
                                    : null,
                                icon: const Icon(Icons.add_circle_outline, size: 22),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Stock Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product.inStock ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.inStock ? Icons.check_circle : Icons.warning_amber_rounded,
                              size: 14,
                              color: product.inStock ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.inStock ? 'In Stock (${product.stockCount} left)' : 'Out of Stock',
                              style: AppTextStyle.caption.copyWith(
                                color: product.inStock ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Delivery Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Doorstep Delivery', style: AppTextStyle.labelMedium),
                              Text(product.deliveryInfo, style: AppTextStyle.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Product Description
                  Text('About This Style', style: AppTextStyle.sectionHeading),
                  const SizedBox(height: 8),
                  Text(product.description, style: AppTextStyle.bodyLarge),
                  const SizedBox(height: 24),

                  // Product Specifications
                  Text('Product Specifications', style: AppTextStyle.sectionHeading),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: product.specifications.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.divider)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(entry.key, style: AppTextStyle.labelMuted),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(entry.value, style: AppTextStyle.labelMedium),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),


          ],
        ),)]),),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                child: CustomButton(
                  text: 'Add to Cart',
                  type: ButtonType.outlined,
                  icon: Icons.shopping_bag_outlined,
                  onPressed: _handleAddToCart,
                ),
              ),
              const SizedBox(width: 12),
              // Buy Now
              Expanded(
                child: CustomButton(
                  text: 'Buy Now',
                  icon: Icons.flash_on_rounded,
                  onPressed: _handleBuyNow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
