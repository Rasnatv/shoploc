
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';

import '../bloc/subcategory/subcategory_bloc.dart';
import '../bloc/subcategory/subcategory_event.dart';
import '../bloc/subcategory/subcategory_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/homemodel.dart';
import '../widgets/product_card.dart';

/// Products under one subcategory (POST /subcategory/products).
/// Creates its own [SubCategoryProductBloc].
class SubCategoryProductsScreen extends StatelessWidget {
  final CategoryApiModel subCategory;
  final String? parentName;

  const SubCategoryProductsScreen({
    super.key,
    required this.subCategory,
    this.parentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubCategoryProductBloc(subCategoryId: subCategory.id)
        ..add(const LoadSubCategoryProductsEvent()),
      child: _View(subCategory: subCategory, parentName: parentName),
    );
  }
}

class _View extends StatefulWidget {
  final CategoryApiModel subCategory;
  final String? parentName;
  const _View({required this.subCategory, this.parentName});

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
      context
          .read<SubCategoryProductBloc>()
          .add(const LoadMoreSubCategoryProductsEvent());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<SubCategoryProductBloc>();
    bloc.add(const RefreshSubCategoryProductsEvent());
    await bloc.stream.first;
  }

  void _openProduct(int id) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailsScreen(productId: id),
    ));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subCategory.name, style: AppTextStyle.appBarTitle),
            if (widget.parentName != null)
              Text(
                widget.parentName!,
                style: AppTextStyle.caption
                    .copyWith(fontSize: 11, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
      body: BlocBuilder<SubCategoryProductBloc, SubCategoryProductState>(
        builder: (context, state) {
          if (state is SubCategoryProductLoadingState ||
              state is SubCategoryProductInitialState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is SubCategoryProductErrorState) {
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
                          .read<SubCategoryProductBloc>()
                          .add(const LoadSubCategoryProductsEvent()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SubCategoryProductLoadedState) {
            if (state.products.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 160),
                    const Icon(Icons.inventory_2_outlined,
                        size: 44, color: AppColors.textTertiary),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'No products in ${widget.subCategory.name} yet.',
                        style: AppTextStyle.caption,
                      ),
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
                            product: p.toHomeProduct(
                                category: widget.subCategory.name),
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