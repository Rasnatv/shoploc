import 'package:flutter/material.dart';
import '../core/apptheme.dart';
import '../models/product.dart';
import '../ui/product_detail_page.dart';
import 'heart_button.dart';
import 'product_image.dart';
import 'star_rating.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetailPage(product))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(children: [
              Positioned.fill(child: ProductImage(product.color)),
              Positioned(top: 8, right: 8, child: HeartButton(product)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(fontSize: 13)),
          Text('₹${product.price}', style: AppText.price),
          const SizedBox(height: 2),
          StarRating(product.rating, product.reviews),
        ]),
      );
}
