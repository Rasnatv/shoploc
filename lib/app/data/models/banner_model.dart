class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? categoryId;
  final String? discountText;
  final String actionText;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.categoryId,
    this.discountText,
    this.actionText = 'Shop Now',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'discountText': discountText,
      'actionText': actionText,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      categoryId: map['categoryId']?.toString(),
      discountText: map['discountText']?.toString(),
      actionText: map['actionText']?.toString() ?? 'Shop Now',
    );
  }
}

