import 'product_model.dart';

class CartItemModel {
  final String id; // unique key: '${product.id}_${selectedSize}_${selectedColor}'
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => product.discountedPrice * quantity;
  double get originalTotalPrice => product.originalPrice * quantity;
  double get totalSavings => originalTotalPrice - totalPrice;

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id']?.toString() ?? '',
      product: ProductModel.fromMap(Map<String, dynamic>.from(map['product'] as Map)),
      selectedSize: map['selectedSize']?.toString() ?? '',
      selectedColor: map['selectedColor']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      addedAt: map['addedAt'] != null
          ? DateTime.tryParse(map['addedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static String generateId(String productId, String size, String color) {
    return '${productId}_${size}_$color';
  }
}

