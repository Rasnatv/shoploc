import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final LocalStorageService _storageService;

  ProductBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<FilterProductsEvent>(_onFilterProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<LoadProductDetailsEvent>(_onLoadProductDetails);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    await Future.delayed(const Duration(milliseconds: 200));

    final filtered = _applyFilters(
      categoryId: event.categoryId,
      subcategory: event.subcategory,
      searchQuery: event.searchQuery,
      sortBy: 'popularity',
    );

    emit(ProductListLoadedState(
      products: filtered,
      activeCategoryId: event.categoryId,
      activeSubcategory: event.subcategory,
      searchQuery: event.searchQuery ?? '',
    ));
  }

  Future<void> _onFilterProducts(
    FilterProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final filtered = _applyFilters(
      categoryId: event.categoryId,
      priceRange: event.priceRange,
      size: event.selectedSize,
      color: event.selectedColor,
      sortBy: event.sortBy ?? 'popularity',
      searchQuery: event.searchQuery,
    );

    emit(ProductListLoadedState(
      products: filtered,
      activeCategoryId: event.categoryId,
      activePriceRange: event.priceRange,
      activeSize: event.selectedSize,
      activeColor: event.selectedColor,
      activeSortBy: event.sortBy ?? 'popularity',
      searchQuery: event.searchQuery ?? '',
    ));
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final filtered = _applyFilters(
      searchQuery: event.query,
      sortBy: 'popularity',
    );

    emit(ProductListLoadedState(
      products: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetailsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    await Future.delayed(const Duration(milliseconds: 150));

    final all = ShoplocDummyData.products;
    final product = all.firstWhere(
      (p) => p.id == event.productId,
      orElse: () => all.first,
    );

    // Save to recently viewed
    final recent = _storageService.getRecentlyViewedIds();
    recent.remove(product.id);
    recent.insert(0, product.id);
    if (recent.length > 10) {
      recent.removeLast();
    }
    await _storageService.saveRecentlyViewedIds(recent);

    final related = all
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .take(4)
        .toList();

    emit(ProductDetailsLoadedState(
      product: product,
      relatedProducts: related.isNotEmpty ? related : all.where((p) => p.id != product.id).take(4).toList(),
    ));
  }

  List<ProductModel> _applyFilters({
    String? categoryId,
    String? subcategory,
    dynamic priceRange,
    String? size,
    String? color,
    String sortBy = 'popularity',
    String? searchQuery,
  }) {
    List<ProductModel> result = List.from(ShoplocDummyData.products);

    // Category
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      result = result.where((p) => p.categoryId == categoryId).toList();
    }

    // Subcategory
    if (subcategory != null && subcategory.isNotEmpty) {
      result = result.where((p) => p.subcategory.toLowerCase() == subcategory.toLowerCase()).toList();
    }

    // Search query
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.subcategory.toLowerCase().contains(q);
      }).toList();
    }

    // Price range
    if (priceRange != null) {
      result = result.where((p) {
        return p.discountedPrice >= priceRange.start && p.discountedPrice <= priceRange.end;
      }).toList();
    }

    // Size
    if (size != null && size.isNotEmpty) {
      result = result.where((p) => p.availableSizes.contains(size)).toList();
    }

    // Color
    if (color != null && color.isNotEmpty) {
      result = result.where((p) {
        return p.availableColors.any((c) => c.toLowerCase() == color.toLowerCase());
      }).toList();
    }

    // Sorting
    switch (sortBy) {
      case 'price_asc':
        result.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case 'price_desc':
        result.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'popularity':
      default:
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return result;
  }
}

