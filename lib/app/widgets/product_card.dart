import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/app_animations.dart';
import '../core/utils/formatters.dart';
import '../data/models/product_model.dart';
import 'network_image_with_fallback.dart';
import 'rating_badge.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback? onAddToCartTap;

  const ProductCard({
    super.key,
    required this.product,
    this.isWishlisted = false,
    required this.onTap,
    required this.onWishlistTap,
    this.onAddToCartTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: NetworkImageWithFallback(
                          imageUrl: product.images.isNotEmpty ? product.images.first : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Discount Badge
                    if (product.discountPercent > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
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
                      ),

                    // Best Seller Badge
                    if (product.isBestSeller && product.discountPercent == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.bestSellerBadge,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BESTSELLER',
                            style: AppTextStyle.badgeText,
                          ),
                        ),
                      ),

                    // Animated Wishlist Heart Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedWishlistHeart(
                            isWishlisted: widget.isWishlisted,
                            onTap: widget.onWishlistTap,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    // Rating pill at bottom of image
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: RatingBadge(rating: product.rating),
                    ),
                  ],
                ),
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.categoryName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.productName,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          Formatters.formatPrice(product.discountedPrice),
                          style: AppTextStyle.productPrice,
                        ),
                        const SizedBox(width: 6),
                        if (product.originalPrice > product.discountedPrice)
                          Flexible(
                            child: Text(
                              Formatters.formatPrice(product.originalPrice),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.originalPrice,
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
    );
  }
}
