// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/ordersbloc/order_bloc.dart';
// import '../bloc/ordersbloc/order_event.dart';
// import '../bloc/ordersbloc/order_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../core/utils/formatters.dart';
// import '../widgets/empty_state_view.dart';
// import '../widgets/network_image_with_fallback.dart';
// import 'order_details_screen.dart';
//
// class OrdersScreen extends StatefulWidget {
//   const OrdersScreen({super.key});
//
//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }
//
// class _OrdersScreenState extends State<OrdersScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<OrderBloc>().add(const LoadOrdersEvent());
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'delivered':
//         return AppColors.success;
//       case 'shipped':
//         return AppColors.info;
//       case 'confirmed':
//       case 'processing':
//         return AppColors.warning;
//       case 'cancelled':
//         return AppColors.error;
//       default:
//         return AppColors.textSecondary;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         title: Text('My Orders', style: AppTextStyle.appBarTitle),
//       ),
//       body: BlocBuilder<OrderBloc, OrderState>(
//         builder: (context, state) {
//           if (state is OrderLoadingState) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//             );
//           }
//
//           if (state is OrderLoadedState) {
//             if (state.orders.isEmpty) {
//               return EmptyStateView(
//                 icon: Icons.receipt_long_outlined,
//                 title: 'No Orders Yet',
//                 message: 'You have not placed any orders yet. Discover our latest collections and start shopping!',
//                 buttonText: 'Start Shopping',
//                 onButtonPressed: () => Navigator.of(context).pop(),
//               );
//             }
//
//             return ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: state.orders.length,
//               separatorBuilder: (_, _) => const SizedBox(height: 14),
//               itemBuilder: (context, index) {
//                 final order = state.orders[index];
//                 final statusColor = _getStatusColor(order.status);
//                 final firstItem = order.items.isNotEmpty ? order.items.first : null;
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigator.of(context).push(
//                     //   MaterialPageRoute(
//                     //     builder: (_) => OrderDetailsScreen(order: order),
//                     //   ),
//                     // );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: AppColors.cardBackground,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(color: AppColors.borderLight),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: AppColors.shadow,
//                           blurRadius: 6,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Order ID & Status Badge
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(order.id, style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700)),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: statusColor.withValues(alpha: 0.12),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 order.status.toUpperCase(),
//                                 style: AppTextStyle.badgeText.copyWith(
//                                   color: statusColor,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           'Placed on ${Formatters.formatDate(order.createdAt)}',
//                           style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
//                         ),
//                         const Divider(height: 18),
//
//                         // Item Preview
//                         if (firstItem != null)
//                           Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: SizedBox(
//                                   width: 60,
//                                   height: 70,
//                                   child: NetworkImageWithFallback(
//                                     imageUrl: firstItem.productImage,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       firstItem.productName,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
//                                     ),
//                                     const SizedBox(height: 3),
//                                     Text(
//                                       'Size: ${firstItem.selectedSize}  •  Qty: ${firstItem.quantity}',
//                                       style: AppTextStyle.caption,
//                                     ),
//                                     if (order.items.length > 1) ...[
//                                       const SizedBox(height: 3),
//                                       Text(
//                                         '+ ${order.items.length - 1} more items',
//                                         style: AppTextStyle.caption.copyWith(
//                                           color: AppColors.primary,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                         const Divider(height: 18),
//
//                         // Total & Action
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Total: ${Formatters.formatPrice(order.totalAmount)}',
//                               style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   'View Details',
//                                   style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary),
//                                 ),
//                                 const SizedBox(width: 2),
//                                 const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/myorders/myorders_bloc.dart';
import '../bloc/myorders/myorders_event.dart';
import '../bloc/myorders/myorders_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../core/utils/object_factory.dart';
import '../data/models/ordersmodel.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/responsive.dart';

class OrdersScreen extends StatefulWidget {
  /// Called by the "Start Shopping" button (switch to the Home tab).
  final VoidCallback? onGoShopping;
  const OrdersScreen({super.key, this.onGoShopping});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scroll = ScrollController();

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    if (_loggedIn) _loadOnOpen();
  }

  /// First visit -> full loader. Coming back later -> silent refresh,
  /// so a freshly placed order shows up without a spinner flash.
  void _loadOnOpen() {
    final bloc = context.read<OrderBloc>();
    if (bloc.state is OrderLoadedState) {
      bloc.add(const RefreshOrdersEvent());
    } else {
      bloc.add(const LoadOrdersEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<OrderBloc>().add(const LoadMoreOrdersEvent());
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<OrderBloc>();
    bloc.add(const RefreshOrdersEvent());
    // a failed refresh emits nothing, so never wait forever
    await bloc.stream.first
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  Future<void> _login() async {
    final ok = await context.push<bool>('/auth',
        extra: {'isRegister': false, 'fromOnboarding': false});
    if (ok == true && mounted) {
      setState(() {});
      context.read<OrderBloc>().add(const LoadOrdersEvent());
    }
  }

  // ------------------------------------------------------------------
  // helpers
  // ------------------------------------------------------------------

  Color _statusColor(String status) {
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

  String _date(OrderModel o) => o.orderDate != null
      ? Formatters.formatDateTime(o.orderDate!)
      : o.orderDateRaw;

  String _itemMeta(OrderItemModel i) {
    final parts = <String>[
      if (i.hasSize) 'Size: ${i.size}',
      if (i.hasColor) i.color,
      'Qty: ${i.quantity}',
    ];
    return parts.join('  •  ');
  }

  // ------------------------------------------------------------------
  // build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('My Orders', style: AppTextStyle.appBarTitle),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          // ---- guest ----
          if (!_loggedIn) {
            return EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'Login to see your Orders',
              message: 'Sign in to track and view all your purchases.',
              buttonText: 'Login',
              onButtonPressed: _login,
            );
          }

          // ---- loading ----
          if (state is OrderLoadingState || state is OrderInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // ---- error ----
          if (state is OrderErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('Failed to load orders',
                        style: AppTextStyle.sectionHeading),
                    const SizedBox(height: 6),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.caption),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context
                          .read<OrderBloc>()
                          .add(const LoadOrdersEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ---- loaded ----
          if (state is OrderLoadedState) {
            if (state.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Orders Yet',
                        message:
                        'You have not placed any orders yet. Discover our latest collections and start shopping!',
                        buttonText:
                        widget.onGoShopping == null ? null : 'Start Shopping',
                        onButtonPressed: widget.onGoShopping,
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: ListView.separated(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.sp(16), vertical: Responsive.sp(12)),
                itemCount: state.orders.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index >= state.orders.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      ),
                    );
                  }
                  return _orderCard(state.orders[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // order card
  // ------------------------------------------------------------------

  Widget _statusBadge(String status, String label) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyle.badgeText
            .copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final first = order.firstItem;

    return GestureDetector(
      onTap: () => _showDetails(order),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // order number + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(order.orderNumber,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.labelLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                _statusBadge(order.status, order.statusLabel),
              ],
            ),
            const SizedBox(height: 6),
            Text('Placed on ${_date(order)}',
                style: AppTextStyle.caption
                    .copyWith(color: AppColors.textTertiary)),
            const Divider(height: 18),

            // first item preview
            if (first != null)
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 70,
                      child: NetworkImageWithFallback(
                          imageUrl: first.image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(first.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.bodySmall
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(_itemMeta(first), style: AppTextStyle.caption),
                        if (order.itemCount > 1) ...[
                          const SizedBox(height: 3),
                          Text('+ ${order.itemCount - 1} more items',
                              style: AppTextStyle.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

            const Divider(height: 18),

            // total + action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Total: ${Formatters.formatPrice(order.totalPrice, showDecimals: true)}',
                    style: AppTextStyle.labelLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Text('View Details',
                        style: AppTextStyle.labelMedium
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // details bottom sheet (all items + shipping address)
  // ------------------------------------------------------------------

  void _showDetails(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(order.orderNumber,
                      style: AppTextStyle.sectionHeading),
                ),
                const SizedBox(width: 8),
                _statusBadge(order.status, order.statusLabel),
              ],
            ),
            const SizedBox(height: 4),
            Text('Placed on ${_date(order)}',
                style: AppTextStyle.caption
                    .copyWith(color: AppColors.textTertiary)),
            const Divider(height: 28),

            Text('Items (${order.totalQuantity})',
                style: AppTextStyle.labelLarge
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...order.items.map(
                  (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 60,
                        height: 70,
                        child: NetworkImageWithFallback(
                            imageUrl: i.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.bodySmall
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(_itemMeta(i), style: AppTextStyle.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 28),
            Text('Shipping address',
                style: AppTextStyle.labelLarge
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(order.shippingAddress, style: AppTextStyle.bodySmall),

            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyle.labelLarge),
                Text(
                    Formatters.formatPrice(order.totalPrice,
                        showDecimals: true),
                    style: AppTextStyle.productPriceLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}