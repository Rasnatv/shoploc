class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final String selectedSize;
  final String selectedColor;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.selectedSize,
    required this.selectedColor,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImage: map['productImage']?.toString() ?? '',
      selectedSize: map['selectedSize']?.toString() ?? '',
      selectedColor: map['selectedColor']?.toString() ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

