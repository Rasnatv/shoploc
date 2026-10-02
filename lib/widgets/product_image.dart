import 'package:flutter/material.dart';

/// Placeholder product image (gradient + icon).
/// Replace the child with Image.asset(...) / Image.network(...) for real photos.
class ProductImage extends StatelessWidget {
  final Color color;
  final double? height;
  final double? width;
  final double radius;

  const ProductImage(this.color,
      {super.key, this.height, this.width, this.radius = 14});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withAlpha(115), color],
          ),
        ),
        child: const Center(
            child: Icon(Icons.checkroom, size: 40, color: Colors.white70)),
      );
}
