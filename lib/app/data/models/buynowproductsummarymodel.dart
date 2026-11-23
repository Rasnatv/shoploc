String _toStr(dynamic v) => v?.toString() ?? '';
double _toDouble(dynamic v) => double.tryParse(_toStr(v)) ?? 0.0;

/// POST /product/price-summary  ->  data
/// {
///   "product_price": 1500,          // price for the whole quantity
///   "delivery": "Free Delivery",    // text OR a number (charge)
///   "tax": 0,
///   "total_amount": 1500
/// }
class PriceSummaryModel {
  final double productPrice;
  final String deliveryRaw; // exactly what the server sent
  final double tax;
  final double totalAmount;

  const PriceSummaryModel({
    required this.productPrice,
    required this.deliveryRaw,
    required this.tax,
    required this.totalAmount,
  });

  /// Delivery charge when the server sends a number ("50"), else 0.
  double get deliveryCharge => double.tryParse(deliveryRaw.trim()) ?? 0.0;

  bool get hasDeliveryCharge => deliveryCharge > 0;

  /// Text to show when there is no numeric charge
  /// ("Free Delivery" from the server, or "FREE" when it sent nothing).
  String get deliveryText {
    final t = deliveryRaw.trim();
    if (t.isEmpty || double.tryParse(t) != null) return 'FREE';
    return t;
  }

  bool get hasTax => tax > 0;

  factory PriceSummaryModel.fromJson(Map<String, dynamic> json) =>
      PriceSummaryModel(
        productPrice: _toDouble(json['product_price']),
        deliveryRaw: _toStr(json['delivery']),
        tax: _toDouble(json['tax']),
        totalAmount: _toDouble(json['total_amount']),
      );
}

/// { status, status_code, message, data: { ... } }
class PriceSummaryResponse {
  final String message;
  final PriceSummaryModel summary;

  const PriceSummaryResponse({required this.message, required this.summary});

  factory PriceSummaryResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return PriceSummaryResponse(
      message: _toStr(json['message']),
      summary: PriceSummaryModel.fromJson(
          raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{}),
    );
  }
}