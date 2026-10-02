
import '../core/appcolors.dart';
import '../models/cart_item.dart';
import '../models/category_item.dart';
import '../models/color_option.dart';
import '../models/product.dart';

/// Dummy data + simple in-memory state (replace with API / state management).
class AppData {
  AppData._();

  static const List<Product> products = [
    Product(1, 'Co-Ord Set', 1299, 4.5, 120, AppColors.lavender, 'Co-Ord Sets', oldPrice: 1699),
    Product(2, 'Kurta Set', 1499, 4.5, 120, AppColors.yellow, 'Kurta Sets'),
    Product(3, 'Midi Dress', 1399, 4.3, 98, AppColors.green, 'Midi Dress'),
    Product(4, 'Top & Jeans Set', 1199, 4.6, 76, AppColors.pink, 'Tops & Tunics'),
    Product(5, 'Co-Ord Set', 1399, 4.3, 98, AppColors.mint, 'Co-Ord Sets'),
    Product(6, 'Co-Ord Set', 1299, 4.6, 76, AppColors.charcoal, 'Co-Ord Sets'),
    Product(7, 'Co-Ord Set', 1349, 4.4, 65, AppColors.pink, 'Co-Ord Sets'),
    Product(8, 'Rayon Kurta Set', 1399, 4.3, 98, AppColors.green, 'Kurta Sets'),
    Product(9, 'Cotton Kurta Set', 1299, 4.6, 76, AppColors.pink, 'Kurta Sets'),
    Product(10, 'Anarkali Kurta Set', 1699, 4.4, 65, AppColors.blue, 'Kurta Sets'),
    Product(11, 'Printed Kurta Set', 1499, 4.5, 120, AppColors.yellow, 'Kurta Sets'),
  ];

  static const List<CategoryItem> categories = [
    CategoryItem('Co-Ord Sets', 'Stylish & Comfortable', AppColors.catPink),
    CategoryItem('Kurta Sets', 'Traditional with a twist', AppColors.catCream),
    CategoryItem('Midi Dress', 'Easy, Breezy, Everyday', AppColors.catGreen),
    CategoryItem('Tops & Tunics', 'Simple. Classy. You.', AppColors.catBlue),
    CategoryItem('Dresses', 'For every occasion', AppColors.catLilac),
  ];

  static const List<ColorOption> colorOptions = [
    ColorOption('Lavender', AppColors.lavender),
    ColorOption('Beige', AppColors.beige),
    ColorOption('Sage', AppColors.sage),
    ColorOption('Black', AppColors.navy),
  ];

  static const List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // ---- In-memory state ----
  static final List<Product> wishlist = [
    products[0],
    products[1],
    products[2],
    products[3],
  ];

  static final List<CartItem> cart = [
    CartItem(products[0], 'Lavender', 'M'),
    CartItem(products[1], 'Yellow', 'L'),
    CartItem(products[3], 'Pink', 'M'),
  ];
}
