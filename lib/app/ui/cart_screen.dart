import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import 'checkout_screen.dart';


class CartScreen extends StatefulWidget {
  final VoidCallback onGoShopping;
  const CartScreen({super.key, required this.onGoShopping});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    if (_couponController.text.trim().isNotEmpty) {
      context.read<CartBloc>().add(
            ApplyCouponEvent(couponCode: _couponController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Shopping Cart', style: AppTextStyle.appBarTitle),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoadedState && state.items.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Empty Cart?'),
                        content: const Text('Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<CartBloc>().add(const ClearCartEvent());
                            },
                            child: const Text('Empty Cart', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear',
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
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoadedState && state.couponMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.couponMessage!),
                backgroundColor: state.isCouponError ? AppColors.error : AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is CartLoadedState) {
            if (state.items.isEmpty) {
              return EmptyStateView(
                icon: Icons.shopping_bag_outlined,
                title: 'Your Shopping Cart is Empty',
                message:
                    'Looks like you haven\'t added any styles yet. Discover our latest boutique arrivals!',
                buttonText: 'Start Shopping',
                onButtonPressed: widget.onGoShopping,
              );
            }

            final amountToFreeShipping =
                (AppConstants.freeShippingThreshold - state.subtotal).clamp(0.0, double.infinity);

            return Column(
              children: [
                // Free Shipping Progress Bar
                if (amountToFreeShipping > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.accentSoft,
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, size: 18, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Add ${Formatters.formatPrice(amountToFreeShipping)} more to get FREE Delivery!',
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.successLight,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Congratulations! You have unlocked FREE Delivery!',
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      final product = item.product;

                      return Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 78,
                                height: 96,
                                child: NetworkImageWithFallback(
                                  imageUrl: product.images.isNotEmpty ? product.images.first : '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Item Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle.productName,
                                        ),
                                      ),
                                      // Remove Item
                                      GestureDetector(
                                        onTap: () {
                                          context.read<CartBloc>().add(
                                                RemoveFromCartEvent(cartItemId: item.id),
                                              );
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Variation Info
                                  Text(
                                    'Size: ${item.selectedSize}  •  Color: ${item.selectedColor}',
                                    style: AppTextStyle.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Price & Quantity Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Formatters.formatPrice(item.totalPrice),
                                        style: AppTextStyle.productPrice,
                                      ),
                                      // Quantity Increment/Decrement
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.border),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                context.read<CartBloc>().add(
                                                      UpdateCartQuantityEvent(
                                                        cartItemId: item.id,
                                                        newQuantity: item.quantity - 1,
                                                      ),
                                                    );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                child: Icon(Icons.remove, size: 14),
                                              ),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: AppTextStyle.labelMedium,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                context.read<CartBloc>().add(
                                                      UpdateCartQuantityEvent(
                                                        cartItemId: item.id,
                                                        newQuantity: item.quantity + 1,
                                                      ),
                                                    );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                child: Icon(Icons.add, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coupon Box
                        if (state.appliedCoupon == null)
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _couponController,
                                  hint: 'REFERAL CODE',
                                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CustomButton(
                                text: 'Apply',
                                width: 90,
                                height: 48,
                                onPressed: _applyCoupon,
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                const SizedBox(width: 8),
                                Text(
                                  'referal "${state.appliedCoupon}" applied!',
                                  style: AppTextStyle.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    _couponController.clear();
                                    context.read<CartBloc>().add(const RemoveCouponEvent());
                                  },
                                  child: Text(
                                    'Remove',
                                    style: AppTextStyle.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 14),

                        // Subtotal
                        _buildSummaryRow('Bag Subtotal', Formatters.formatPrice(state.subtotal)),
                        if (state.productDiscount > 0)
                          _buildSummaryRow(
                            'Product Savings',
                            '- ${Formatters.formatPrice(state.productDiscount)}',
                            color: AppColors.success,
                          ),
                        if (state.couponDiscount > 0)
                          _buildSummaryRow(
                            'Coupon Discount',
                            '- ${Formatters.formatPrice(state.couponDiscount)}',
                            color: AppColors.success,
                          ),
                        _buildSummaryRow(
                          'Estimated Delivery',
                          state.deliveryFee == 0
                              ? 'FREE'
                              : Formatters.formatPrice(state.deliveryFee),
                          color: state.deliveryFee == 0 ? AppColors.success : null,
                        ),

                        const Divider(height: 18),

                        // Grand Total & Checkout CTA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Grand Total', style: AppTextStyle.caption),
                                Text(
                                  Formatters.formatPrice(state.grandTotal),
                                  style: AppTextStyle.productPriceLarge,
                                ),
                              ],
                            ),
                            CustomButton(
                              text: 'Proceed to Checkout',
                              width: 190,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
