class ProductModel {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String categoryId;
  final String categoryName;
  final String subcategory;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final List<String> images;
  final List<String> availableSizes;
  final List<String> availableColors;
  final Map<String, String> specifications;
  final String deliveryInfo;
  final int stockCount;
  final bool inStock;
  final double rating;
  final int reviewCount;
  final bool isNewArrival;
  final bool isBestSeller;
  final bool isTrending;
  final bool isFeatured;
  final DateTime createdAt;

  String get primaryImage => images.isNotEmpty ? images.first : '';
  double get price => discountedPrice;
  bool get hasDiscount => originalPrice > discountedPrice;

  const ProductModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.subcategory,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.images,
    required this.availableSizes,
    required this.availableColors,
    required this.specifications,
    this.deliveryInfo = 'Delivered within 3 - 5 business days',
    this.stockCount = 10,
    this.inStock = true,
    this.rating = 4.5,
    this.reviewCount = 24,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.isTrending = false,
    this.isFeatured = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subcategory': subcategory,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'discountPercent': discountPercent,
      'images': images,
      'availableSizes': availableSizes,
      'availableColors': availableColors,
      'specifications': specifications,
      'deliveryInfo': deliveryInfo,
      'stockCount': stockCount,
      'inStock': inStock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNewArrival': isNewArrival,
      'isBestSeller': isBestSeller,
      'isTrending': isTrending,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      subcategory: map['subcategory']?.toString() ?? '',
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (map['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (map['discountPercent'] as num?)?.toInt() ?? 0,
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableSizes: (map['availableSizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableColors: (map['availableColors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      specifications: (map['specifications'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
      deliveryInfo: map['deliveryInfo']?.toString() ??
          'Delivered within 3 - 5 business days',
      stockCount: (map['stockCount'] as num?)?.toInt() ?? 10,
      inStock: map['inStock'] ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isNewArrival: map['isNewArrival'] == true,
      isBestSeller: map['isBestSeller'] == true,
      isTrending: map['isTrending'] == true,
      isFeatured: map['isFeatured'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

