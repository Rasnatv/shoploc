import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../models/product.dart';
import 'product_card.dart';

/// Responsive product grid: 2 columns on phones, 3 on tablets, 4 on desktop.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final int? crossAxisCount;

  const ProductGrid({
    super.key,
    required this.products,
    this.shrinkWrap = false,
    this.padding = EdgeInsets.zero,
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, cons) {
        final count = crossAxisCount ?? Responsive.gridCount(context);
        const spacing = 12.0;
        final cardW =
            (cons.maxWidth - padding.horizontal - spacing * (count - 1)) / count;
        final extent = cardW * 4 / 3 + 88; // image (3:4) + text area

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          padding: padding,
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 14,
            mainAxisExtent: extent,
          ),
          itemBuilder: (_, i) => ProductCard(products[i]),
        );
      });
}
