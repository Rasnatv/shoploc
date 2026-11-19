import 'homemodel.dart';

double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
String _toStr(dynamic v) => v?.toString() ?? '';
bool _toBool(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase();
  return s == '1' || s == 'true';
}

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) parse) =>
    raw is List
        ? raw
        .whereType<Map>()
        .map((e) => parse(Map<String, dynamic>.from(e)))
        .toList()
        : <T>[];

/// "images": [ { "id": 95, "color_id": 11, "image": "https://..." } ]
class SubCategoryProductImage {
  final int id;
  final int colorId;
  final String image;

  const SubCategoryProductImage({
    required this.id,
    required this.colorId,
    required this.image,
  });

  factory SubCategoryProductImage.fromJson(Map<String, dynamic> json) =>
      SubCategoryProductImage(
        id: _toInt(json['id']),
        colorId: _toInt(json['color_id']),
        image: _toStr(json['image']),
      );
}

/// "variants": [ { "id": 152, "color_id": 11, "color_name": "Brown",
///   "color_code": "#7a6262", "size": "Free Size", "stock": 1, "in_stock": true } ]
class SubCategoryProductVariant {
  final int id;
  final int colorId;
  final String colorName;
  final String colorCode; // e.g. "#7a6262"
  final String size;
  final int stock;
  final bool inStock;

  const SubCategoryProductVariant({
    required this.id,
    required this.colorId,
    required this.colorName,
    required this.colorCode,
    required this.size,
    required this.stock,
    required this.inStock,
  });

  factory SubCategoryProductVariant.fromJson(Map<String, dynamic> json) =>
      SubCategoryProductVariant(
        id: _toInt(json['id']),
        colorId: _toInt(json['color_id']),
        colorName: _toStr(json['color_name']),
        colorCode: _toStr(json['color_code']),
        size: _toStr(json['size']),
        stock: _toInt(json['stock']),
        inStock: _toBool(json['in_stock']),
      );
}

/// One product from POST /subcategory/products
class SubCategoryProductModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String image; // main image
  final List<SubCategoryProductImage> images;
  final double price; // regular price
  final double offerPrice; // 0 when there is no offer
  final double discountPercent;
  final double shippingCharge;
  final String badge;
  final String trendType;
  final double rating;
  final int categoryId;
  final String category;
  final bool inStock;
  final List<SubCategoryProductVariant> variants;

  const SubCategoryProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.image,
    required this.images,
    required this.price,
    required this.offerPrice,
    required this.discountPercent,
    required this.shippingCharge,
    required this.badge,
    required this.trendType,
    required this.rating,
    required this.categoryId,
    required this.category,
    required this.inStock,
    required this.variants,
  });

  bool get hasOffer => offerPrice > 0 && offerPrice < price;

  /// Price the customer actually pays.
  double get sellingPrice => hasOffer ? offerPrice : price;

  /// Distinct sizes / colors across variants (handy for filters later).
  List<String> get sizes =>
      variants.map((v) => v.size).where((s) => s.isNotEmpty).toSet().toList();
  List<String> get colorNames => variants
      .map((v) => v.colorName)
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  factory SubCategoryProductModel.fromJson(Map<String, dynamic> json) =>
      SubCategoryProductModel(
        id: _toInt(json['id']),
        name: _toStr(json['name']),
        slug: _toStr(json['slug']),
        description: _toStr(json['description']),
        image: _toStr(json['image']),
        images: _list(json['images'], SubCategoryProductImage.fromJson),
        price: _toDouble(json['price']),
        offerPrice: _toDouble(json['offer_price']), // "" -> 0
        discountPercent: _toDouble(json['discount_percent']),
        shippingCharge: _toDouble(json['shipping_charge']),
        badge: _toStr(json['badge']),
        trendType: _toStr(json['trend_type']),
        rating: _toDouble(json['rating']),
        categoryId: _toInt(json['category_id']),
        category: _toStr(json['category']),
        // if the API omits in_stock, treat as available
        inStock: json.containsKey('in_stock') ? _toBool(json['in_stock']) : true,
        variants: _list(json['variants'], SubCategoryProductVariant.fromJson),
      );

  /// Lets us reuse the existing [HomeProductCard] widget.
  /// [category] is only a fallback when the API sends an empty category.
  HomeProductModel toHomeProduct({String category = ''}) => HomeProductModel(
    id: id,
    name: name,
    slug: slug,
    price: sellingPrice,
    originalPrice: hasOffer ? price : 0,
    badge: badge,
    trendType: trendType,
    rating: rating,
    category: this.category.isNotEmpty ? this.category : category,
    image: image,
  );
}

/// { status, status_code, message, data: [ ...products ] }
class SubCategoryProductsResponse {
  final String message;
  final List<SubCategoryProductModel> products;

  const SubCategoryProductsResponse({
    required this.message,
    required this.products,
  });

  factory SubCategoryProductsResponse.fromJson(Map<String, dynamic> json) =>
      SubCategoryProductsResponse(
        message: _toStr(json['message']),
        products: _list(json['data'], SubCategoryProductModel.fromJson),
      );
}