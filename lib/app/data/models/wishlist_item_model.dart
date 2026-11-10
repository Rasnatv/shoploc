import 'product_model.dart';

class WishlistItemModel {
  final String productId;
  final ProductModel product;
  final DateTime addedAt;

  const WishlistItemModel({
    required this.productId,
    required this.product,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'product': product.toMap(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      productId: map['productId']?.toString() ?? '',
      product: ProductModel.fromMap(Map<String, dynamic>.from(map['product'] as Map)),
      addedAt: map['addedAt'] != null
          ? DateTime.tryParse(map['addedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

