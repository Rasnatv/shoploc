double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
String _toStr(dynamic v) => v?.toString() ?? '';

/// One result of POST /products/search  ->  data[]
/// { "id": 21, "name": "...", "image": "https://...", "price": "750.00", "offer_price": "" }
///
/// [price]      = regular price
/// [offerPrice] = discounted price ("" / 0 when there is no offer)
class SearchProductModel {
  final int id;
  final String name;
  final String image;
  final double price;
  final double offerPrice;

  const SearchProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.offerPrice = 0,
  });

  /// True when an offer price exists and is lower than the regular price.
  bool get hasOffer => offerPrice > 0 && offerPrice < price;

  /// The price the customer actually pays.
  double get sellingPrice => hasOffer ? offerPrice : price;

  int get discountPercent =>
      hasOffer ? (((price - offerPrice) / price) * 100).round() : 0;

  factory SearchProductModel.fromJson(Map<String, dynamic> json) =>
      SearchProductModel(
        id: int.tryParse(_toStr(json['id'])) ?? 0,
        name: _toStr(json['name']),
        image: _toStr(json['image']),
        price: _toDouble(json['price']),
        offerPrice: _toDouble(json['offer_price']),
      );
}

/// POST /products/search   body: { "search": "olive" }
/// { status, status_code, message, data: [ {product}, ... ] }
class SearchResponse {
  final String message;
  final List<SearchProductModel> products;

  const SearchResponse({required this.message, required this.products});

  bool get isEmpty => products.isEmpty;

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return SearchResponse(
      message: _toStr(json['message']),
      products: raw is List
          ? raw
          .whereType<Map>()
          .map((e) =>
          SearchProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : <SearchProductModel>[],
    );
  }
}