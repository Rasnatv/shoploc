
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../data/models/whishlistmodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/responsive.dart';
import '../widgets/network_image_with_fallback.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  /// Called by the "Discover Fashion" button (switch to the Home tab).
  final VoidCallback? onGoShopping;
  const WishlistScreen({super.key, this.onGoShopping});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final ScrollController _scroll = ScrollController();

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    final bloc = context.read<WishlistBloc>();
    // Already loaded elsewhere (e.g. a heart was tapped)? don't reload.
    if (bloc.state is WishlistInitialState) {
      bloc.add(const LoadWishlistEvent());
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
      context.read<WishlistBloc>().add(const LoadMoreWishlistEvent());
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<WishlistBloc>();
    bloc.add(const RefreshWishlistEvent());
    // a failed refresh emits nothing, so never wait forever
    await bloc.stream.first.timeout(const Duration(seconds: 15),
        onTimeout: () => bloc.state);
  }

  Future<void> _login() async {
    final ok = await context.push<bool>('/auth',
        extra: {'isRegister': false, 'fromOnboarding': false});
    if (ok == true && mounted) {
      setState(() {});
      context.read<WishlistBloc>().add(const LoadWishlistEvent());
    }
  }

  void _openProduct(WishlistItemModel item) {
    // Wishlist state is global, so the heart on the details page is already correct.
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: item.id)));
  }

  String _rupees(double v) =>
      '₹${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';

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
        title: BlocBuilder<WishlistBloc, WishlistState>(
          buildWhen: (a, b) =>
          (a is WishlistLoadedState ? a.count : -1) !=
              (b is WishlistLoadedState ? b.count : -1),
          builder: (context, state) {
            final count = state is WishlistLoadedState ? state.count : 0;
            return Text(count > 0 ? 'My Wishlist ($count)' : 'My Wishlist',
                style: AppTextStyle.appBarTitle);
          },
        ),
      ),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        // show a snackbar only on the screen the user is looking at
        listenWhen: (prev, cur) =>
        cur is WishlistLoadedState &&
            cur.message != null &&
            cur.message!.fromWishlistScreen &&
            (prev is! WishlistLoadedState ||
                prev.message?.seq != cur.message!.seq),
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          final m = (state as WishlistLoadedState).message!;
          m.isError ? AppSnackbar.error(m.text) : AppSnackbar.success(m.text);
        },
        builder: (context, state) {
          // ---- guest ----
          if (!_loggedIn) {
            return EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Login to see your Wishlist',
              message:
              'Sign in to save your favourite pieces and find them here anytime.',
              buttonText: 'Login',
              onButtonPressed: _login,
            );
          }

          // ---- loading ----
          if (state is WishlistLoadingState || state is WishlistInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // ---- error ----
          if (state is WishlistErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('Failed to load wishlist',
                        style: AppTextStyle.sectionHeading),
                    const SizedBox(height: 6),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.caption),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context
                          .read<WishlistBloc>()
                          .add(const LoadWishlistEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ---- loaded ----
          if (state is WishlistLoadedState) {
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
                        icon: Icons.favorite_border_rounded,
                        title: 'Your Wishlist is Empty',
                        message:
                        'Explore our curated collections of Co-Ord sets, Kurtas and Dresses to save your favourites for later.',
                        buttonText: widget.onGoShopping == null
                            ? null
                            : 'Discover Fashion',
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
                itemCount: state.items.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
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
                  return _buildItem(context, state.items[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, WishlistItemModel item) {
    return Dismissible(
      key: ValueKey('wishlist_${item.id}'),
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
      onDismissed: (_) => context
          .read<WishlistBloc>()
          .add(RemoveFromWishlistEvent(productId: item.id)),
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
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: Responsive.sp(80),
                  height: Responsive.sp(100),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.productName,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(_rupees(item.sellingPrice),
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
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 22, color: AppColors.textTertiary),
                onPressed: () => context
                    .read<WishlistBloc>()
                    .add(RemoveFromWishlistEvent(productId: item.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}