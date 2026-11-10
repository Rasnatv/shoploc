class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> subcategories;
  final int productCount;
  final bool isFeatured;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.subcategories = const [],
    this.productCount = 0,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'subcategories': subcategories,
      'productCount': productCount,
      'isFeatured': isFeatured,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      subcategories: (map['subcategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      productCount: (map['productCount'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] == true,
    );
  }
}

