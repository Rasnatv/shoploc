import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/ordersbloc/order_bloc.dart';
import '../bloc/ordersbloc/order_event.dart';
import '../bloc/ordersbloc/order_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../data/dummy_data/shoploc_dummy_data.dart';
import '../data/models/order_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/network_image_with_fallback.dart';
import 'cart_screen.dart';
import 'track_order_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'shipped':
        return AppColors.info;
      case 'confirmed':
      case 'processing':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        // Find latest updated order if exists in state
        OrderModel currentOrder = order;
        if (state is OrderLoadedState) {
          final found = state.orders.where((o) => o.id == order.id).toList();
          if (found.isNotEmpty) currentOrder = found.first;
        }

        final statusColor = _getStatusColor(currentOrder.status);
        final canCancel = currentOrder.status != 'Delivered' &&
            currentOrder.status != 'Cancelled';

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text('Order Details', style: AppTextStyle.appBarTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentOrder.id, style: AppTextStyle.sectionHeading),
                              const SizedBox(height: 2),
                              Text(
                                'Placed on ${Formatters.formatDateTime(currentOrder.createdAt)}',
                                style: AppTextStyle.caption,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentOrder.status.toUpperCase(),
                              style: AppTextStyle.badgeText.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Track Order CTA
                      CustomButton(
                        text: 'Track Order Live',
                        icon: Icons.timeline_rounded,
                        type: ButtonType.outlined,
                        height: 44,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TrackOrderScreen(order: currentOrder),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Items in this order
                Text('Items Ordered (${currentOrder.items.length})', style: AppTextStyle.sectionHeading),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentOrder.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = currentOrder.items[idx];
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 64,
                                height: 76,
                                child: NetworkImageWithFallback(
                                  imageUrl: item.productImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Size: ${item.selectedSize}  •  Color: ${item.selectedColor}',
                                    style: AppTextStyle.caption,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} × ${Formatters.formatPrice(item.unitPrice)}',
                                    style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(Formatters.formatPrice(item.totalPrice), style: AppTextStyle.labelLarge),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Address
                Text('Delivery Address', style: AppTextStyle.sectionHeading),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentOrder.shippingAddress.fullName, style: AppTextStyle.labelLarge),
                      const SizedBox(height: 4),
                      Text(currentOrder.shippingAddress.formattedAddress, style: AppTextStyle.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        'Mobile: ${currentOrder.shippingAddress.mobileNumber}',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Info
                Text('Payment Details', style: AppTextStyle.sectionHeading),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Payment Mode', currentOrder.paymentMethod),
                      const SizedBox(height: 6),
                      _buildRow('Items Subtotal', Formatters.formatPrice(currentOrder.subtotal)),
                      if (currentOrder.couponDiscount > 0) ...[
                        const SizedBox(height: 6),
                        _buildRow(
                          'Coupon Discount (${currentOrder.couponCode ?? "PROMO"})',
                          '- ${Formatters.formatPrice(currentOrder.couponDiscount)}',
                          color: AppColors.success,
                        ),
                      ],
                      const SizedBox(height: 6),
                      _buildRow(
                        'Delivery Charges',
                        currentOrder.deliveryFee == 0
                            ? 'FREE'
                            : Formatters.formatPrice(currentOrder.deliveryFee),
                        color: currentOrder.deliveryFee == 0 ? AppColors.success : null,
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: AppTextStyle.labelLarge),
                          Text(Formatters.formatPrice(currentOrder.totalAmount), style: AppTextStyle.productPriceLarge),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Actions: Reorder & Cancel
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Reorder All',
                        icon: Icons.refresh_rounded,
                        onPressed: () {
                          // Add items back into cart
                          for (final item in currentOrder.items) {
                            final dummyProd = ShoplocDummyData.products.firstWhere(
                              (p) => p.id == item.productId,
                              orElse: () => ShoplocDummyData.products.first,
                            );

                            context.read<CartBloc>().add(
                                  AddToCartEvent(
                                    product: dummyProd,
                                    selectedSize: item.selectedSize,
                                    selectedColor: item.selectedColor,
                                    quantity: item.quantity,
                                  ),
                                );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Items re-added to your cart!'),
                              backgroundColor: AppColors.success,
                            ),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen(onGoShopping: _noop)),
                          );
                        },
                      ),
                    ),
                    if (canCancel) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel Order',
                          type: ButtonType.outlined,
                          backgroundColor: AppColors.error,
                          textColor: Colors.white,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Cancel Order?'),
                                content: const Text(
                                    'Are you sure you want to cancel this order? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Keep Order'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<OrderBloc>().add(
                                            CancelOrderEvent(orderId: currentOrder.id),
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Order has been cancelled.'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    },
                                    child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _noop() {}

  Widget _buildRow(String label, String value, {Color? color}) {
    return Row(
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
    );
  }
}
