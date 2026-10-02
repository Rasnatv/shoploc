import 'package:flutter/material.dart';

import '../core/appcolors.dart';
import '../core/apptheme.dart';


class StarRating extends StatelessWidget {
  final double rating;
  final int reviews;
  const StarRating(this.rating, this.reviews, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: AppColors.star),
          const SizedBox(width: 3),
          Text('$rating ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text('($reviews)', style: AppText.caption),
        ],
      );
}
