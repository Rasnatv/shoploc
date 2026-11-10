import 'package:flutter/material.dart';

abstract class ProductEvent {
  const ProductEvent();
}

class LoadProductsEvent extends ProductEvent {
  final String? categoryId;
  final String? subcategory;
  final String? searchQuery;

  const LoadProductsEvent({
    this.categoryId,
    this.subcategory,
    this.searchQuery,
  });
}

class FilterProductsEvent extends ProductEvent {
  final String? categoryId;
  final RangeValues? priceRange;
  final String? selectedSize;
  final String? selectedColor;
  final String? sortBy; // 'price_asc', 'price_desc', 'newest', 'popularity'
  final String? searchQuery;

  const FilterProductsEvent({
    this.categoryId,
    this.priceRange,
    this.selectedSize,
    this.selectedColor,
    this.sortBy,
    this.searchQuery,
  });
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent({required this.query});
}

class LoadProductDetailsEvent extends ProductEvent {
  final String productId;
  const LoadProductDetailsEvent({required this.productId});
}

