double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
String _toStr(dynamic v) => v?.toString() ?? '';

/// One item of GET /wishlist
/// { "id": 20, "name": "...", "image": "...", "price": "600.00", "offer_price": "" }
///
/// [price]      = regular price
/// [offerPrice] = discounted price ("" / 0 when there is no offer)
class WishlistItemModel {
  final int id;
  final String name;
  final String image;
  final double price;
  final double offerPrice;

  const WishlistItemModel({
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

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      WishlistItemModel(
        id: int.tryParse(_toStr(json['id'])) ?? 0,
        name: _toStr(json['name']),
        image: _toStr(json['image']),
        price: _toDouble(json['price']),
        offerPrice: _toDouble(json['offer_price']),
      );
}

/// GET /wishlist?page=&per_page=
class WishlistResponse {
  final String message;
  final List<WishlistItemModel> items;

  const WishlistResponse({required this.message, required this.items});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return WishlistResponse(
      message: _toStr(json['message']),
      items: raw is List
          ? raw
          .map((e) =>
          WishlistItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
          : <WishlistItemModel>[],
    );
  }
}

/// POST /wishlist/add  and  POST /wishlist/remove  ->  { "message": "...", "data": {} }
class WishlistActionResponse {
  final String message;
  const WishlistActionResponse({required this.message});

  factory WishlistActionResponse.fromJson(Map<String, dynamic> json) =>
      WishlistActionResponse(message: _toStr(json['message']));
}