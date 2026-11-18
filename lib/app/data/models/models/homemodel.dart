double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
String _toStr(dynamic v) => v?.toString() ?? '';

/// Category (parent or child). Parents carry [children].
class CategoryApiModel {
  final int id;
  final String name;
  final String image;
  final int? parentId;
  final List<CategoryApiModel> children;

  const CategoryApiModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    this.children = const [],
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return CategoryApiModel(
      id: int.tryParse(_toStr(json['id'])) ?? 0,
      name: _toStr(json['name']),
      image: _toStr(json['image']),
      parentId: int.tryParse(_toStr(json['parent_id'])), // "" -> null
      children: rawChildren is List
          ? rawChildren
          .map((e) => CategoryApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
          : const [],
    );
  }
}

/// Product card item returned by /home/highlights.
class HomeProductModel {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double originalPrice;
  final String badge;
  final String trendType; // featured | best-seller | hot-trend ...
  final double rating;
  final String category;
  final String image;

  const HomeProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.originalPrice,
    required this.badge,
    required this.trendType,
    required this.rating,
    required this.category,
    required this.image,
  });

  bool get hasDiscount => originalPrice > price && price > 0;

  int get discountPercent =>
      hasDiscount ? (((originalPrice - price) / originalPrice) * 100).round() : 0;

  bool get isBestSeller => trendType == 'best-seller';
  bool get isFeatured => trendType == 'featured';
  bool get isHotTrend => trendType == 'hot-trend';

  factory HomeProductModel.fromJson(Map<String, dynamic> json) => HomeProductModel(
    id: int.tryParse(_toStr(json['id'])) ?? 0,
    name: _toStr(json['name']),
    slug: _toStr(json['slug']),
    price: _toDouble(json['price']),
    originalPrice: _toDouble(json['original_price']),
    badge: _toStr(json['badge']),
    trendType: _toStr(json['trend_type']),
    rating: _toDouble(json['rating']),
    category: _toStr(json['category']),
    image: _toStr(json['image']),
  );
}

class HomeHighlightsResponse {
  final String message;
  final List<HomeProductModel> newArrivals;
  final List<HomeProductModel> trending;

  const HomeHighlightsResponse({
    required this.message,
    required this.newArrivals,
    required this.trending,
  });

  static List<HomeProductModel> _list(dynamic raw) => raw is List
      ? raw.map((e) => HomeProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
      : <HomeProductModel>[];

  factory HomeHighlightsResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?) ?? {};
    return HomeHighlightsResponse(
      message: _toStr(json['message']),
      newArrivals: _list(data['new_arrivals']),
      trending: _list(data['trending']),
    );
  }
}

class CategoriesResponse {
  final String message;
  final List<CategoryApiModel> categories;

  const CategoriesResponse({required this.message, required this.categories});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return CategoriesResponse(
      message: _toStr(json['message']),
      categories: raw is List
          ? raw.map((e) => CategoryApiModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
    );
  }
}