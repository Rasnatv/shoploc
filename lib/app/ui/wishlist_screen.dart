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
import '../widgets/custom_button.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import 'product_details_screen.dart';


class WishlistScreen extends StatelessWidget {
  final VoidCallback onGoShopping;
  const WishlistScreen({super.key, required this.onGoShopping});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('My Wishlist', style: AppTextStyle.appBarTitle),
        actions: [
          BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              if (state is WishlistLoadedState && state.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Wishlist?'),
                        content: const Text('Are you sure you want to remove all saved items?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<WishlistBloc>().add(const ClearWishlistEvent());
                            },
                            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear All',
                    style: AppTextStyle.labelMedium.copyWith(color: AppColors.textTertiary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is WishlistLoadedState) {
            if (state.items.isEmpty) {
              return EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: 'Your Wishlist is Empty',
                message:
                    'Explore our curated collections of Co-Ord sets, Kurtas and Dresses to save your favourites for later.',
                buttonText: 'Discover Fashion',
                onButtonPressed: onGoShopping,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = state.items[index];

                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  onDismissed: (_) {
                    context.read<WishlistBloc>().add(
                          RemoveFromWishlistEvent(productId: product.id),
                        );
                  },
                  child: GestureDetector(
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 100,
                              child: NetworkImageWithFallback(
                                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.categoryName.toUpperCase(),
                                  style: AppTextStyle.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: AppColors.primary,
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
                                  children: [
                                    Text(
                                      Formatters.formatPrice(product.discountedPrice),
                                      style: AppTextStyle.productPrice,
                                    ),
                                    const SizedBox(width: 8),
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
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Move to Cart CTA
                                    Expanded(
                                      child: SizedBox(
                                        height: 34,
                                        child: CustomButton(
                                          text: 'Move to Cart',
                                          height: 34,
                                          icon: Icons.shopping_bag_outlined,
                                          onPressed: () {
                                            final size = product.availableSizes.isNotEmpty
                                                ? product.availableSizes.first
                                                : 'Free Size';
                                            final color = product.availableColors.isNotEmpty
                                                ? product.availableColors.first
                                                : 'Default';

                                            context.read<CartBloc>().add(
                                                  AddToCartEvent(
                                                    product: product,
                                                    selectedSize: size,
                                                    selectedColor: color,
                                                    quantity: 1,
                                                  ),
                                                );

                                            context.read<WishlistBloc>().add(
                                                  RemoveFromWishlistEvent(productId: product.id),
                                                );

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Moved "${product.name}" to your cart!'),
                                                backgroundColor: AppColors.success,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Remove
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: AppColors.textTertiary,
                                      ),
                                      onPressed: () {
                                        context.read<WishlistBloc>().add(
                                              RemoveFromWishlistEvent(productId: product.id),
                                            );
                                      },
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
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
