import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../data/models/searchmodel.dart';
import '../router/app_router.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/responsive.dart';

/// Opened from the Home search bar:  context.push(AppRouter.search);
/// Pass `extra: {'query': 'olive'}` to open it with a search already typed.
class SearchScreen extends StatelessWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => SearchBloc(),
      child: _SearchView(initialQuery: initialQuery),
    );
  }
}

class _SearchView extends StatefulWidget {
  final String initialQuery;
  const _SearchView({required this.initialQuery});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  /// Quick ideas shown before the user types (same words as the Home hint).
  static const List<String> _suggestions = [
    'Co-Ord Sets',
    'Kurta',
    'Dresses',
    'Olive',
  ];

  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SearchBloc>().add(SearchSubmitted(widget.initialQuery));
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
    _focus.requestFocus();
  }

  void _useSuggestion(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _focus.unfocus();
    context.read<SearchBloc>().add(SearchSubmitted(text));
  }

  void _openProduct(SearchProductModel p) {
    _focus.unfocus();
    context.push(AppRouter.productPath(p.id));
  }

  String _money(double v) => Formatters.formatPrice(v);

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => AppRouter.back(context),
        ),
        title: _searchField(),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.value(
                mobile: double.infinity, tablet: 700.0, desktop: 800.0),
          ),
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is SearchErrorState) {
                return EmptyStateView(
                  icon: Icons.error_outline_rounded,
                  title: 'Search failed',
                  message: state.errorMessage,
                  buttonText: 'Retry',
                  onButtonPressed: () => context
                      .read<SearchBloc>()
                      .add(SearchSubmitted(state.query)),
                );
              }
              if (state is SearchLoadedState) {
                if (state.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No products found',
                    message:
                    'We couldn\'t find anything for "${state.query}". Try a different word.',
                  );
                }
                return _results(state);
              }
              return _startView();
            },
          ),
        ),
      ),
    );
  }

  // ---------------- search field (app bar) ----------------
  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          style: AppTextStyle.inputText,
          cursorColor: AppColors.primary,
          onChanged: (v) =>
              context.read<SearchBloc>().add(SearchQueryChanged(v)),
          onSubmitted: (v) =>
              context.read<SearchBloc>().add(SearchSubmitted(v)),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Search "Co-Ord Sets", "Kurta"...',
            hintStyle: AppTextStyle.inputHint,
            prefixIcon: const Icon(Icons.search,
                color: AppColors.textTertiary, size: 22),
            // the X only shows while there is text
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.textTertiary),
                onPressed: _clear,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ---------------- start view (nothing typed) ----------------
  Widget _startView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Text('Popular searches',
            style: AppTextStyle.labelLarge
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _suggestions)
              ActionChip(
                label: Text(s, style: AppTextStyle.categoryChip),
                avatar: const Icon(Icons.north_west_rounded,
                    size: 14, color: AppColors.primary),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.borderLight),
                onPressed: () => _useSuggestion(s),
              ),
          ],
        ),
        const SizedBox(height: 40),
        const Icon(Icons.search_rounded,
            size: 56, color: AppColors.textTertiary),
        const SizedBox(height: 8),
        Text('Type at least 2 letters to search products',
            textAlign: TextAlign.center, style: AppTextStyle.caption),
      ],
    );
  }

  // ---------------- results ----------------
  Widget _results(SearchLoadedState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${state.results.length} '
                  '${state.results.length == 1 ? 'result' : 'results'} '
                  'for "${state.query}"',
              style: AppTextStyle.caption,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            itemCount: state.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _resultTile(state.results[i]),
          ),
        ),
      ],
    );
  }

  Widget _resultTile(SearchProductModel p) {
    return InkWell(
      onTap: () => _openProduct(p),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 78,
                child: NetworkImageWithFallback(
                  imageUrl: p.image,
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
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(_money(p.sellingPrice),
                          style: AppTextStyle.labelLarge),
                      if (p.hasOffer) ...[
                        Text(
                          _money(p.price),
                          style: AppTextStyle.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          '${p.discountPercent}% OFF',
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}