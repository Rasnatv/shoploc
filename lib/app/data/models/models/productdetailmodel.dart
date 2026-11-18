import 'package:flutter/material.dart';

double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
String _toStr(dynamic v) => v?.toString() ?? '';
int _toInt(dynamic v) => int.tryParse(_toStr(v)) ?? 0;
bool _toBool(dynamic v) =>
    v == true || v == 1 || _toStr(v) == '1' || _toStr(v).toLowerCase() == 'true';

class ProductImageModel {
  final int id;
  final int colorId;
  final String image;

  const ProductImageModel({
    required this.id,
    required this.colorId,
    required this.image,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) =>
      ProductImageModel(
        id: _toInt(json['id']),
        colorId: _toInt(json['color_id']),
        image: _toStr(json['image']),
      );
}

class ProductVariantModel {
  final int id;
  final int colorId;
  final String colorName;
  final String colorCode;
  final String size;
  final int stock;
  final bool inStock;

  const ProductVariantModel({
    required this.id,
    required this.colorId,
    required this.colorName,
    required this.colorCode,
    required this.size,
    required this.stock,
    required this.inStock,
  });

  Color get color {
    var hex = colorCode.replaceAll('#', '').trim();
    if (hex.length == 6) hex = 'FF$hex';
    final v = int.tryParse(hex, radix: 16);
    return v == null ? Colors.grey : Color(v);
  }

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final stock = _toInt(json['stock']);
    return ProductVariantModel(
      id: _toInt(json['id']),
      colorId: _toInt(json['color_id']),
      colorName: _toStr(json['color_name']),
      colorCode: _toStr(json['color_code']),
      size: _toStr(json['size']),
      stock: stock,
      inStock: json.containsKey('in_stock') ? _toBool(json['in_stock']) : stock > 0,
    );
  }
}

class ProductColorOption {
  final int id;
  final String name;
  final Color color;
  final bool inStock;

  const ProductColorOption({
    required this.id,
    required this.name,
    required this.color,
    required this.inStock,
  });
}

class ProductDetailsModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final double price;
  final double originalPrice;
  final double shippingCharge;
  final String badge;
  final String trendType;
  final double rating;
  final int categoryId;
  final String category;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  const ProductDetailsModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.shippingCharge,
    required this.badge,
    required this.trendType,
    required this.rating,
    required this.categoryId,
    required this.category,
    required this.images,
    required this.variants,
  });

  bool get hasDiscount => originalPrice > price && price > 0;
  int get discountPercent =>
      hasDiscount ? (((originalPrice - price) / originalPrice) * 100).round() : 0;
  bool get freeShipping => shippingCharge <= 0;

  String? get tag {
    if (badge.isNotEmpty) return badge;
    switch (trendType) {
      case 'best-seller':
        return 'Best Seller';
      case 'hot-trend':
        return 'Hot Trend';
      case 'featured':
        return 'Featured';
    }
    return null;
  }

  bool get inStock => variants.any((v) => v.inStock);

  List<ProductColorOption> get colors {
    final seen = <int>{};
    final out = <ProductColorOption>[];
    for (final v in variants) {
      if (!seen.add(v.colorId)) continue;
      out.add(ProductColorOption(
        id: v.colorId,
        name: v.colorName,
        color: v.color,
        inStock: variants.any((x) => x.colorId == v.colorId && x.inStock),
      ));
    }
    return out;
  }

  int get defaultColorId {
    if (variants.isEmpty) return 0;
    final inStockVariant = variants.where((v) => v.inStock);
    return (inStockVariant.isNotEmpty ? inStockVariant.first : variants.first)
        .colorId;
  }

  List<ProductVariantModel> variantsForColor(int colorId) =>
      variants.where((v) => v.colorId == colorId).toList();

  String? defaultSizeFor(int colorId) {
    final list = variantsForColor(colorId);
    if (list.isEmpty) return null;
    final ok = list.where((v) => v.inStock);
    return (ok.isNotEmpty ? ok.first : list.first).size;
  }

  ProductVariantModel? findVariant(int colorId, String? size) {
    for (final v in variants) {
      if (v.colorId == colorId && v.size == size) return v;
    }
    return null;
  }

  List<ProductImageModel> imagesForColor(int colorId) {
    final matched =
    images.where((i) => i.colorId == colorId || i.colorId == 0).toList();
    return matched.isNotEmpty ? matched : images;
  }

  // Lines like "Fit: Regular Fit" become specification rows;
  // everything else stays as the "About" text.
  static final RegExp _specLine =
  RegExp(r'^([A-Za-z][A-Za-z0-9 /&-]{1,28}):\s*(\S.*)$');

  List<String> get _lines =>
      description.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();

  List<MapEntry<String, String>> get specifications => [
    for (final l in _lines)
      if (_specLine.hasMatch(l))
        MapEntry(_specLine.firstMatch(l)!.group(1)!.trim(),
            _specLine.firstMatch(l)!.group(2)!.trim()),
  ];

  String get aboutText => _lines
      .where((l) => l.isNotEmpty && !_specLine.hasMatch(l))
      .join('\n\n');

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(dynamic raw, T Function(Map<String, dynamic>) f) => raw is List
        ? raw.map((e) => f(Map<String, dynamic>.from(e as Map))).toList()
        : <T>[];

    return ProductDetailsModel(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      slug: _toStr(json['slug']),
      description: _toStr(json['description']),
      price: _toDouble(json['price']),
      originalPrice: _toDouble(json['original_price']),
      shippingCharge: _toDouble(json['shipping_charge']),
      badge: _toStr(json['badge']),
      trendType: _toStr(json['trend_type']),
      rating: _toDouble(json['rating']),
      categoryId: _toInt(json['category_id']),
      category: _toStr(json['category']),
      images: list(json['images'], ProductImageModel.fromJson),
      variants: list(json['variants'], ProductVariantModel.fromJson),
    );
  }
}

/// POST /products/details
class ProductDetailsResponse {
  final bool success;
  final String message;
  final ProductDetailsModel? product;

  const ProductDetailsResponse({
    required this.success,
    required this.message,
    required this.product,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProductDetailsResponse(
      success: _toStr(json['status']) == '1',
      message: _toStr(json['message']),
      product: data is Map
          ? ProductDetailsModel.fromJson(Map<String, dynamic>.from(data))
          : null,
    );
  }
}