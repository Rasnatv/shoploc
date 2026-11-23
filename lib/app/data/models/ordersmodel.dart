String _toStr(dynamic v) => v?.toString() ?? '';
int _toInt(dynamic v) => int.tryParse(_toStr(v)) ?? 0;
double _toDouble(dynamic v) => double.tryParse(_toStr(v)) ?? 0.0;

/// One product line inside an order  ->  data[].items[]
/// {
///   "product_id": 41, "product_name": "testproduct", "image": "https://...",
///   "size": "M", "color": "", "quantity": 1
/// }
class OrderItemModel {
  final int productId;
  final String productName;
  final String image;
  final String size;
  final String color; // can be "" (product has no colour)
  final int quantity;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.image,
    required this.size,
    required this.color,
    required this.quantity,
  });

  bool get hasColor => color.trim().isNotEmpty;
  bool get hasSize => size.trim().isNotEmpty;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    productId: _toInt(json['product_id']),
    productName: _toStr(json['product_name']),
    image: _toStr(json['image']),
    size: _toStr(json['size']),
    color: _toStr(json['color']),
    quantity: _toInt(json['quantity']),
  );
}

/// One order  ->  data[]
/// {
///   "order_id": 92, "order_number": "ORD00092",
///   "order_date": "2026-11-23 04:04:16", "total_price": "2.00",
///   "status": "processing", "shipping_address": "...", "items": [ ... ]
/// }
class OrderModel {
  final int orderId;
  final String orderNumber;
  final String orderDateRaw; // exactly what the server sent
  final DateTime? orderDate; // parsed, null if the format is unexpected
  final double totalPrice;
  final String status; // processing | cancelled | shipped | delivered ...
  final String shippingAddress;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderDateRaw,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    required this.items,
  });

  // ---- convenience getters for the UI ----
  String get statusLower => status.trim().toLowerCase();
  bool get isCancelled => statusLower == 'cancelled';
  bool get isDelivered => statusLower == 'delivered';

  /// "processing" -> "Processing"
  String get statusLabel => statusLower.isEmpty
      ? ''
      : statusLower[0].toUpperCase() + statusLower.substring(1);

  OrderItemModel? get firstItem => items.isEmpty ? null : items.first;

  /// Number of product lines.
  int get itemCount => items.length;

  /// Sum of all quantities.
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final dateRaw = _toStr(json['order_date']);
    return OrderModel(
      orderId: _toInt(json['order_id']),
      orderNumber: _toStr(json['order_number']),
      orderDateRaw: dateRaw,
      // "2026-11-23 04:04:16" is accepted by DateTime.tryParse
      orderDate: DateTime.tryParse(dateRaw),
      totalPrice: _toDouble(json['total_price']),
      status: _toStr(json['status']),
      shippingAddress: _toStr(json['shipping_address']),
      items: rawItems is List
          ? rawItems
          .whereType<Map>()
          .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : <OrderItemModel>[],
    );
  }
}

/// GET /orders?page=&per_page=
/// { status, status_code, message, data: [ {order}, ... ] }
class OrdersResponse {
  final String message;
  final List<OrderModel> orders;

  const OrdersResponse({required this.message, required this.orders});

  bool get isEmpty => orders.isEmpty;

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return OrdersResponse(
      message: _toStr(json['message']),
      orders: raw is List
          ? raw
          .whereType<Map>()
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : <OrderModel>[],
    );
  }
}