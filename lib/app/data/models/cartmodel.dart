double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
int _toInt(dynamic v) =>
    int.tryParse(v?.toString() ?? '') ?? (double.tryParse(v?.toString() ?? '')?.round() ?? 0);
String _toStr(dynamic v) => v?.toString() ?? '';

/// One line of GET /cart  ->  data.items[]
/// { cart_item_id, product_id, name, image, color_id, color_name, size,
///   quantity, price, offer_price, item_total }
///
/// [price]      = regular price
/// [offerPrice] = discounted price ("" / 0 when there is no offer)
class CartItemModel {
  final int cartItemId;
  final int productId;
  final String name;
  final String image;
  final int colorId;
  final String colorName;
  final String size;
  final int quantity;
  final double price;
  final double offerPrice;
  final double itemTotal;

  const CartItemModel({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.image,
    required this.colorId,
    required this.colorName,
    required this.size,
    required this.quantity,
    required this.price,
    required this.offerPrice,
    required this.itemTotal,
  });

  bool get hasOffer => offerPrice > 0 && offerPrice < price;

  /// Price of ONE piece that the customer pays.
  double get unitPrice => hasOffer ? offerPrice : price;

  int get discountPercent =>
      hasOffer ? (((price - offerPrice) / price) * 100).round() : 0;

  /// New quantity with the line total recalculated (used for instant UI update).
  CartItemModel withQuantity(int q) => CartItemModel(
    cartItemId: cartItemId,
    productId: productId,
    name: name,
    image: image,
    colorId: colorId,
    colorName: colorName,
    size: size,
    quantity: q,
    price: price,
    offerPrice: offerPrice,
    itemTotal: unitPrice * q,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final qty = _toInt(json['quantity']);
    final price = _toDouble(json['price']);
    final offer = _toDouble(json['offer_price']);
    final unit = (offer > 0 && offer < price) ? offer : price;
    final total = json['item_total'] == null
        ? unit * qty
        : _toDouble(json['item_total']);
    return CartItemModel(
      cartItemId: _toInt(json['cart_item_id']),
      productId: _toInt(json['product_id']),
      name: _toStr(json['name']),
      image: _toStr(json['image']),
      colorId: _toInt(json['color_id']),
      colorName: _toStr(json['color_name']),
      size: _toStr(json['size']),
      quantity: qty,
      price: price,
      offerPrice: offer,
      itemTotal: total,
    );
  }
}

/// GET /cart
/// { message, data: { items: [...], total_items: 2, cart_total: 3350 } }
class CartResponse {
  final String message;
  final List<CartItemModel> items;
  final int totalItems;
  final double cartTotal;

  const CartResponse({
    required this.message,
    required this.items,
    required this.totalItems,
    required this.cartTotal,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final raw = map['items'];
    final items = raw is List
        ? raw
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
        : <CartItemModel>[];
    return CartResponse(
      message: _toStr(json['message']),
      items: items,
      totalItems: map['total_items'] == null ? items.length : _toInt(map['total_items']),
      cartTotal: map['cart_total'] == null
          ? items.fold<double>(0, (a, b) => a + b.itemTotal)
          : _toDouble(map['cart_total']),
    );
  }
}

/// POST /cart/add, /cart/update, /cart/remove
/// { message, data: { cart_item_id, quantity } }   (remove -> data: {})
class CartActionResponse {
  final String message;
  final int? cartItemId;
  final int? quantity;

  const CartActionResponse({required this.message, this.cartItemId, this.quantity});

  factory CartActionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return CartActionResponse(
      message: _toStr(json['message']),
      cartItemId: map['cart_item_id'] == null ? null : _toInt(map['cart_item_id']),
      quantity: map['quantity'] == null ? null : _toInt(map['quantity']),
    );
  }
}