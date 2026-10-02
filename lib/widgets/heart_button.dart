import 'package:flutter/material.dart';
import '../core/appcolors.dart';
import '../data/app_data.dart';
import '../models/product.dart';

/// Wishlist toggle button.
class HeartButton extends StatefulWidget {
  final Product product;
  final double size;
  final VoidCallback? onChanged;
  const HeartButton(this.product, {super.key, this.size = 30, this.onChanged});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  @override
  Widget build(BuildContext context) {
    final liked = AppData.wishlist.contains(widget.product);
    return GestureDetector(
      onTap: () {
        setState(() => liked
            ? AppData.wishlist.remove(widget.product)
            : AppData.wishlist.add(widget.product));
        widget.onChanged?.call();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
            color: Colors.white70, shape: BoxShape.circle),
        child: Icon(liked ? Icons.favorite : Icons.favorite_border,
            size: widget.size * .55,
            color: liked ? AppColors.red : AppColors.dark),
      ),
    );
  }
}
