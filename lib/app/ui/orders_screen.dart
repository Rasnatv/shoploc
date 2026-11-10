import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ordersbloc/order_bloc.dart';
import '../bloc/ordersbloc/order_event.dart';
import '../bloc/ordersbloc/order_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const LoadOrdersEvent());
  }

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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('My Orders', style: AppTextStyle.appBarTitle),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is OrderLoadedState) {
            if (state.orders.isEmpty) {
              return EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'No Orders Yet',
                message: 'You have not placed any orders yet. Discover our latest collections and start shopping!',
                buttonText: 'Start Shopping',
                onButtonPressed: () => Navigator.of(context).pop(),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final statusColor = _getStatusColor(order.status);
                final firstItem = order.items.isNotEmpty ? order.items.first : null;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: AppTextStyle.badgeText.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Placed on ${Formatters.formatDate(order.createdAt)}',
                          style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
                        ),
                        const Divider(height: 18),

                        // Item Preview
                        if (firstItem != null)
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 60,
                                  height: 70,
                                  child: NetworkImageWithFallback(
                                    imageUrl: firstItem.productImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      firstItem.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Size: ${firstItem.selectedSize}  •  Qty: ${firstItem.quantity}',
                                      style: AppTextStyle.caption,
                                    ),
                                    if (order.items.length > 1) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        '+ ${order.items.length - 1} more items',
                                        style: AppTextStyle.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),

                        const Divider(height: 18),

                        // Total & Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${Formatters.formatPrice(order.totalAmount)}',
                              style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Row(
                              children: [
                                Text(
                                  'View Details',
                                  style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ],
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
