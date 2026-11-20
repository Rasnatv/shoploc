
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/homemodel.dart';
import '../data/models/whishlistmodel.dart';
import 'appsnackbar.dart';
import 'network_image_with_fallback.dart';
import 'responsive.dart';

/// Product card built for [HomeProductModel] (API data).
/// Has a wishlist heart (top-right) that talks to the global [WishlistBloc].
class HomeProductCard extends StatelessWidget {
  final HomeProductModel product;
  final VoidCallback onTap;

  const HomeProductCard({super.key, required this.product, required this.onTap});

  String? get _tag {
    if (product.badge.isNotEmpty) return product.badge;
    switch (product.trendType) {
      case 'best-seller':
        return 'Best Seller';
      case 'hot-trend':
        return 'Hot Trend';
      case 'featured':
        return 'Featured';
    }
    return null;
  }

  String _rupees(double v) =>
      '₹${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final tag = _tag;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.image.isEmpty
                        ? Container(
                      color: AppColors.blush,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.textTertiary),
                    )
                        : NetworkImageWithFallback(
                        imageUrl: product.image, fit: BoxFit.cover),
                    if (tag != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyle.badgeText.copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                    // ---- wishlist heart ----
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _WishlistHeart(product: product),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption.copyWith(
                        fontSize: 10, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _rupees(product.price),
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          _rupees(product.originalPrice),
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 10.5,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.discountPercent}% off',
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (product.rating > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF5A623)),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppTextStyle.caption.copyWith(fontSize: 10.5),
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

/// Round heart button. Red/filled when the product is in the wishlist.
class _WishlistHeart extends StatelessWidget {
  final HomeProductModel product;
  const _WishlistHeart({required this.product});

  void _toggle(BuildContext context) {
    context.read<WishlistBloc>().add(ToggleWishlistEvent(
      productId: product.id,
      // lets the Wishlist tab update instantly (no extra API call)
      item: WishlistItemModel(
        id: product.id,
        name: product.name,
        image: product.image,
        price: product.hasDiscount ? product.originalPrice : product.price,
        offerPrice: product.hasDiscount ? product.price : 0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      // snackbar only on the card that was tapped (and only if its page is on top)
      listenWhen: (prev, cur) =>
      cur is WishlistLoadedState &&
          cur.message != null &&
          cur.message!.productId == product.id &&
          !cur.message!.fromWishlistScreen &&
          (prev is! WishlistLoadedState ||
              prev.message?.seq != cur.message!.seq),
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        final m = (state as WishlistLoadedState).message!;
        m.isError ? AppSnackbar.error(m.text) : AppSnackbar.success(m.text);
      },
      buildWhen: (a, b) =>
      a.isWishlisted(product.id) != b.isWishlisted(product.id),
      builder: (context, state) {
        final wished = state.isWishlisted(product.id);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggle(context), // does not open the product page
          child: Container(
            height: Responsive.sp(30),
            width: Responsive.sp(30),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: AppColors.shadowMedium, blurRadius: 4),
              ],
            ),
            child: Icon(
              wished ? Icons.favorite : Icons.favorite_border,
              size: Responsive.sp(17),
              color: wished ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}