import 'product.dart';

class CartItem {
  final Product product;
  final String color;
  final String size;
  int qty;

  CartItem(this.product, this.color, this.size, [this.qty = 1]);
}
