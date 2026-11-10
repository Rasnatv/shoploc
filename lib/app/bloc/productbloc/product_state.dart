import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';


abstract class ProductState {
  const ProductState();
}

class ProductInitialState extends ProductState {
  const ProductInitialState();
}

class ProductLoadingState extends ProductState {
  const ProductLoadingState();
}

class ProductListLoadedState extends ProductState {
  final List<ProductModel> products;
  final String? activeCategoryId;
  final String? activeSubcategory;
  final RangeValues? activePriceRange;
  final String? activeSize;
  final String? activeColor;
  final String activeSortBy; // 'popularity', 'newest', 'price_asc', 'price_desc'
  final String searchQuery;

  const ProductListLoadedState({
    required this.products,
    this.activeCategoryId,
    this.activeSubcategory,
    this.activePriceRange,
    this.activeSize,
    this.activeColor,
    this.activeSortBy = 'popularity',
    this.searchQuery = '',
  });

  ProductListLoadedState copyWith({
    List<ProductModel>? products,
    String? activeCategoryId,
    String? activeSubcategory,
    RangeValues? activePriceRange,
    String? activeSize,
    String? activeColor,
    String? activeSortBy,
    String? searchQuery,
  }) {
    return ProductListLoadedState(
      products: products ?? this.products,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      activeSubcategory: activeSubcategory ?? this.activeSubcategory,
      activePriceRange: activePriceRange ?? this.activePriceRange,
      activeSize: activeSize ?? this.activeSize,
      activeColor: activeColor ?? this.activeColor,
      activeSortBy: activeSortBy ?? this.activeSortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductDetailsLoadedState extends ProductState {
  final ProductModel product;
  final List<ProductModel> relatedProducts;

  const ProductDetailsLoadedState({
    required this.product,
    required this.relatedProducts,
  });
}

class ProductErrorState extends ProductState {
  final String errorMessage;
  const ProductErrorState({required this.errorMessage});
}

