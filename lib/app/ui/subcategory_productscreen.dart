import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/ui/product_details_screen.dart';

import '../bloc/subcategory/subcategory_bloc.dart';
import '../bloc/subcategory/subcategory_event.dart';
import '../bloc/subcategory/subcategory_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
// TODO: adjust this path to wherever your Responsive class lives.
import '../data/models/homemodel.dart';
import '../widgets/product_card.dart';
import '../widgets/responsive.dart';

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
  /// The grid never gets wider than this; on huge screens it is centred.
  static const double _maxContentWidth = 1200;

  /// Aspect ratio of a product card at normal text size (width / height).
  static const double _cardAspectRatio = 0.66;

  final ScrollController _scroll = ScrollController();

  // ---------- responsive helpers ----------
  double _scale = 1.0;

  /// Scales a design-pixel value (fonts, paddings, icons...).
  double _s(double v) => v * _scale;

  /// Number of grid columns for the available width.
  int _columnsFor(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

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

  /// On big screens the first page may not fill the viewport, so the user
  /// can never scroll and [_onScroll] never fires. Ask for more in that case.
  void _loadMoreIfNotScrollable(SubCategoryProductLoadedState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      if (state.hasMore &&
          !state.isLoadingMore &&
          _scroll.position.maxScrollExtent <= 0) {
        context
            .read<SubCategoryProductBloc>()
            .add(const LoadMoreSubCategoryProductsEvent());
      }
    });
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
    // Refresh responsive values on every build (rotation, resize, etc).
    Responsive.init(context);
    _scale = Responsive.screenWidth < 600
        ? (Responsive.screenWidth / 390).clamp(0.85, 1.15)
        : 1.0;

    // Keep cards intact with very large system font sizes.
    final mq = MediaQuery.of(context);
    final textScaler =
    mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mq.copyWith(textScaler: textScaler),
      child: Scaffold(
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
              Text(
                widget.subCategory.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.appBarTitle,
              ),
              if (widget.parentName != null)
                Text(
                  widget.parentName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(
                    fontSize: _s(11),
                    color: AppColors.textTertiary,
                  ),
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
              return _buildError(context, state.errorMessage);
            }

            if (state is SubCategoryProductLoadedState) {
              return state.products.isEmpty
                  ? _buildEmpty()
                  : _buildGrid(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ---------- error ----------
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          // Don't stretch edge-to-edge on tablets / web.
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(_s(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: _s(44), color: AppColors.textTertiary),
                SizedBox(height: _s(12)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.caption
                      .copyWith(fontSize: _s(AppTextStyle.caption.fontSize ?? 12)),
                ),
                SizedBox(height: _s(14)),
                ElevatedButton(
                  onPressed: () => context
                      .read<SubCategoryProductBloc>()
                      .add(const LoadSubCategoryProductsEvent()),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- empty ----------
  Widget _buildEmpty() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      // LayoutBuilder + minHeight keeps the message vertically placed
      // sensibly on any screen height and keeps pull-to-refresh working.
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(_s(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: _s(44), color: AppColors.textTertiary),
                    SizedBox(height: _s(10)),
                    Text(
                      'No products in ${widget.subCategory.name} yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.caption.copyWith(
                          fontSize: _s(AppTextStyle.caption.fontSize ?? 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- product grid ----------
  Widget _buildGrid(SubCategoryProductLoadedState state) {
    _loadMoreIfNotScrollable(state);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = _columnsFor(width);

          // Centre the grid and cap its width on very large screens while
          // the scroll view (and its scrollbar) still spans the full width.
          final contentWidth = math.min(width, _maxContentWidth);
          final sidePad = (width - contentWidth) / 2 + _s(16);
          final spacing = _s(14);

          // Exact tile size, so cards keep their proportions at any width.
          final tileWidth =
              (width - sidePad * 2 - spacing * (columns - 1)) / columns;

          // Give the text area extra room when the user has a larger
          // system font (card text sits under the image).
          final extraTextHeight =
              (MediaQuery.textScalerOf(context).scale(14) - 14) * 3.5;
          final tileHeight = tileWidth / _cardAspectRatio + extraTextHeight;

          return CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePad, _s(16), sidePad, _s(16)),
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: tileHeight,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: _s(24)),
                  child: Center(
                    child: state.isLoadingMore
                        ? SizedBox(
                      height: _s(22),
                      width: _s(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    )
                        : (!state.hasMore
                        ? Text(
                      "You're all caught up",
                      style: AppTextStyle.caption.copyWith(
                          fontSize:
                          _s(AppTextStyle.caption.fontSize ?? 12)),
                    )
                        : SizedBox(height: _s(22))),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}