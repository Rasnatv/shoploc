
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../data/models/cartmodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/responsive.dart';
import 'checkout_screen.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  /// "Start Shopping" button (switch to the Home tab).
  final VoidCallback? onGoShopping;

  /// "Checkout" button. Wire your checkout screen here.
  final VoidCallback? onCheckout;

  const CartScreen({super.key, this.onGoShopping, this.onCheckout});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CartBloc>();
    if (bloc.state is CartInitialState) bloc.add(const LoadCartEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<CartBloc>();
    bloc.add(const RefreshCartEvent());
    // a failed refresh emits nothing, so never wait forever
    await bloc.stream.first.timeout(const Duration(seconds: 15),
        onTimeout: () => bloc.state);
  }

  Future<void> _login() async {
    final ok = await context.push<bool>('/auth',
        extra: {'isRegister': false, 'fromOnboarding': false});
    if (ok == true && mounted) {
      setState(() {});
      context.read<CartBloc>().add(const LoadCartEvent());
    }
  }

  String _rupees(double v) =>
      '₹${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';

  void _openProduct(CartItemModel item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: item.productId)));
  }

  void _checkout() {
    // keep your own callback working if a parent passes one
    if (widget.onCheckout != null) {
      widget.onCheckout!();
      return;
    }

    if (!_loggedIn) {
      _login();
      return;
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutScreen()))
        .then((_) {
      // refresh the cart when coming back from checkout
      if (mounted) context.read<CartBloc>().add(const RefreshCartEvent());
    });
  }

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
        title: BlocBuilder<CartBloc, CartState>(
          buildWhen: (a, b) =>
          (a is CartLoadedState ? a.pieces : -1) !=
              (b is CartLoadedState ? b.pieces : -1),
          builder: (context, state) {
            final n = state is CartLoadedState ? state.pieces : 0;
            return Text(n > 0 ? 'My Cart ($n)' : 'My Cart',
                style: AppTextStyle.appBarTitle);
          },
        ),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        // remove / update messages only (add messages are shown on the product page)
        listenWhen: (prev, cur) =>
        cur is CartLoadedState &&
            cur.message != null &&
            cur.message!.action != CartAction.add &&
            (prev is! CartLoadedState ||
                prev.message?.seq != cur.message!.seq),
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          final m = (state as CartLoadedState).message!;
          m.isError ? AppSnackbar.error(m.text) : AppSnackbar.success(m.text);
        },
        builder: (context, state) {
          // ---- guest ----
          if (!_loggedIn) {
            return EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Login to see your Cart',
              message: 'Sign in to add styles to your cart and check out.',
              buttonText: 'Login',
              onButtonPressed: _login,
            );
          }

          // ---- loading ----
          if (state is CartLoadingState || state is CartInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // ---- error ----
          if (state is CartErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('Failed to load cart',
                        style: AppTextStyle.sectionHeading),
                    const SizedBox(height: 6),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.caption),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<CartBloc>().add(const LoadCartEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! CartLoadedState) return const SizedBox.shrink();

          // ---- empty ----
          if (state.items.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: EmptyStateView(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your Shopping Cart is Empty',
                      message:
                      "Looks like you haven't added any styles yet. Discover our latest arrivals!",
                      buttonText:
                      widget.onGoShopping == null ? null : 'Start Shopping',
                      onButtonPressed: widget.onGoShopping,
                    ),
                  ),
                ),
              ),
            );
          }

          // ---- items + checkout bar ----
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(Responsive.sp(16)),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) =>
                        _buildItem(context, state, state.items[i]),
                  ),
                ),
              ),
              _buildSummary(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, CartLoadedState state, CartItemModel item) {
    final busy = state.busyIds.contains(item.cartItemId);

    return Dismissible(
      key: ValueKey('cart_${item.cartItemId}'),
      direction: busy ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => context
          .read<CartBloc>()
          .add(RemoveCartItemEvent(cartItemId: item.cartItemId)),
      child: GestureDetector(
        onTap: () => _openProduct(item),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: Responsive.sp(78),
                  height: Responsive.sp(96),
                  child: item.image.isEmpty
                      ? Container(
                    color: AppColors.blush,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.textTertiary),
                  )
                      : NetworkImageWithFallback(
                      imageUrl: item.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.productName),
                        ),
                        InkWell(
                          onTap: busy
                              ? null
                              : () => context.read<CartBloc>().add(
                              RemoveCartItemEvent(
                                  cartItemId: item.cartItemId)),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 6, bottom: 4),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.colorName.isNotEmpty) item.colorName,
                        if (item.size.isNotEmpty) 'Size: ${item.size}',
                      ].join('  •  '),
                      style: AppTextStyle.caption,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(_rupees(item.unitPrice),
                            style: AppTextStyle.productPrice),
                        if (item.hasOffer) ...[
                          Text(_rupees(item.price),
                              style: AppTextStyle.originalPrice),
                          Text(
                            '${item.discountPercent}% off',
                            style: AppTextStyle.caption.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _qtyStepper(context, item, busy),
                        const Spacer(),
                        Text(_rupees(item.itemTotal),
                            style: AppTextStyle.productPrice.copyWith(
                                fontWeight: FontWeight.w800)),
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

  Widget _qtyStepper(BuildContext context, CartItemModel item, bool busy) {
    Widget btn(IconData icon, VoidCallback? onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? AppColors.textTertiary
                : AppColors.textPrimary),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            Icons.remove,
            (busy || item.quantity <= 1)
                ? null
                : () => context.read<CartBloc>().add(UpdateCartQuantityEvent(
                cartItemId: item.cartItemId, quantity: item.quantity - 1)),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text('${item.quantity}', style: AppTextStyle.labelLarge),
            ),
          ),
          btn(
            Icons.add,
            busy
                ? null
                : () => context.read<CartBloc>().add(UpdateCartQuantityEvent(
                cartItemId: item.cartItemId, quantity: item.quantity + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(CartLoadedState state) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.sp(16), vertical: Responsive.sp(12)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total (${state.pieces} ${state.pieces == 1 ? 'item' : 'items'})',
                      style: AppTextStyle.caption),
                  const SizedBox(height: 2),
                  Text(_rupees(state.cartTotal),
                      style: AppTextStyle.productPriceLarge),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _checkout,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: const Text('Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}