double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0.0;
int _toInt(dynamic v) =>
    int.tryParse(v?.toString() ?? '') ??
        (double.tryParse(v?.toString() ?? '')?.round() ?? 0);
String _toStr(dynamic v) => v?.toString() ?? '';

Map<String, dynamic> _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// One line of GET /order/preview  ->  data.items[]
/// { product_id, name, image, size, quantity, price, offer_price, item_total }
/// price / offer_price arrive as strings ("950.00", ""), item_total as a number.
class OrderPreviewItem {
  final int productId;
  final String name;
  final String image;
  final String size;
  final int quantity;
  final double price;
  final double offerPrice;
  final double itemTotal;

  const OrderPreviewItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.size,
    required this.quantity,
    required this.price,
    required this.offerPrice,
    required this.itemTotal,
  });

  bool get hasOffer => offerPrice > 0 && offerPrice < price;

  /// Price of ONE piece that the customer pays.
  double get unitPrice => hasOffer ? offerPrice : price;

  factory OrderPreviewItem.fromJson(Map<String, dynamic> json) {
    final qty = _toInt(json['quantity']);
    final price = _toDouble(json['price']);
    final offer = _toDouble(json['offer_price']);
    final unit = (offer > 0 && offer < price) ? offer : price;
    return OrderPreviewItem(
      productId: _toInt(json['product_id']),
      name: _toStr(json['name']),
      image: _toStr(json['image']),
      size: _toStr(json['size']),
      quantity: qty,
      price: price,
      offerPrice: offer,
      itemTotal: json['item_total'] == null ? unit * qty : _toDouble(json['item_total']),
    );
  }
}

/// GET /order/preview
/// { message, data: { items: [...], total_items: 1, subtotal: 1900 } }
class OrderPreviewResponse {
  final String message;
  final List<OrderPreviewItem> items;
  final int totalItems;
  final double subtotal;

  const OrderPreviewResponse({
    required this.message,
    required this.items,
    required this.totalItems,
    required this.subtotal,
  });

  bool get isEmpty => items.isEmpty;

  /// Total pieces (sum of quantities).
  int get pieces => items.fold(0, (s, i) => s + i.quantity);

  factory OrderPreviewResponse.fromJson(Map<String, dynamic> json) {
    final map = _asMap(json['data']);
    final raw = map['items'];
    final items = raw is List
        ? raw
        .whereType<Map>()
        .map((e) => OrderPreviewItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : <OrderPreviewItem>[];
    return OrderPreviewResponse(
      message: _toStr(json['message']),
      items: items,
      totalItems: map['total_items'] == null ? items.length : _toInt(map['total_items']),
      subtotal: map['subtotal'] == null
          ? items.fold<double>(0, (a, b) => a + b.itemTotal)
          : _toDouble(map['subtotal']),
    );
  }
}

/// GET /checkout/summary
/// { message, data: { subtotal: 1900, tax: 0, delivery: "Free Delivery", total_amount: 1900 } }
///
/// [delivery] is text from the server ("Free Delivery"); it may also be a
/// number in the future, so [deliveryLabel] handles both.
class CheckoutSummaryResponse {
  final String message;
  final double subtotal;
  final double tax;
  final String delivery;
  final double totalAmount;

  const CheckoutSummaryResponse({
    required this.message,
    required this.subtotal,
    required this.tax,
    required this.delivery,
    required this.totalAmount,
  });

  /// Delivery as a number when the server sends one ("50", 50), else null.
  double? get deliveryAmount => double.tryParse(delivery.trim());

  bool get isFreeDelivery =>
      delivery.toLowerCase().contains('free') || deliveryAmount == 0;

  factory CheckoutSummaryResponse.fromJson(Map<String, dynamic> json) {
    final map = _asMap(json['data']);
    return CheckoutSummaryResponse(
      message: _toStr(json['message']),
      subtotal: _toDouble(map['subtotal']),
      tax: _toDouble(map['tax']),
      delivery: _toStr(map['delivery']),
      totalAmount: _toDouble(map['total_amount']),
    );
  }
}
