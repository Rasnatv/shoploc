import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final int price;
  final double rating;
  final int reviews;
  final Color color; // used by placeholder image; replace with image URL/asset
  final String category;
  final int? oldPrice;

  const Product(this.id, this.name, this.price, this.rating, this.reviews,
      this.color, this.category,
      {this.oldPrice});

  int? get discountPercent =>
      oldPrice == null ? null : (((oldPrice! - price) / oldPrice!) * 100).floor();
}
