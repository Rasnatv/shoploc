import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/productlistbloc/productlist_bloc.dart';
import '../bloc/productlistbloc/productlist_event.dart';
import '../bloc/productlistbloc/productlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/productlisttype.dart';
import '../widgets/product_card.dart';


/// "See All" screen for New Arrivals / Trending / Best Sellers.
/// Creates its own [ProductListBloc] for the given [type].
class ProductsSeeAllScreen extends StatelessWidget {
  final ProductListType type;
  const ProductsSeeAllScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ProductListBloc(type: type)..add(const LoadProductListEvent()),
      child: _View(type: type),
    );
  }
}

class _View extends StatefulWidget {
  final ProductListType type;
  const _View({required this.type});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<ProductListBloc>().add(const LoadMoreProductListEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ProductListBloc>();
    bloc.add(const RefreshProductListEvent());
    await bloc.stream.first;
  }

  void _openProduct(int id) {
    // TODO: open product details using product id / slug
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(widget.type.title)),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoadingState ||
              state is ProductListInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is ProductListErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(state.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.caption),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ProductListBloc>()
                          .add(const LoadProductListEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProductListLoadedState) {
            if (state.products.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 160),
                    Center(
                      child: Text('No products found.',
                          style: AppTextStyle.caption),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, i) {
                          final p = state.products[i];
                          return HomeProductCard(
                            product: p,
                            onTap: () => _openProduct(p.id),
                          );
                        },
                        childCount: state.products.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.66,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: state.isLoadingMore
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        )
                            : (!state.hasMore
                            ? Text("You're all caught up",
                            style: AppTextStyle.caption)
                            : const SizedBox(height: 22)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}