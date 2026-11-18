/// One banner from GET /banners
class BannerApiModel {
  final int id;
  final String image;

  const BannerApiModel({required this.id, required this.image});

  factory BannerApiModel.fromJson(Map<String, dynamic> json) => BannerApiModel(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    image: json['image']?.toString() ?? '',
  );
}

/// GET /banners -> { message, data: [ {id, image}, ... ] }
class BannersResponse {
  final String message;
  final List<BannerApiModel> banners;

  const BannersResponse({required this.message, required this.banners});

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return BannersResponse(
      message: json['message']?.toString() ?? '',
      banners: raw is List
          ? raw
          .map((e) => BannerApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((b) => b.image.isNotEmpty)
          .toList()
          : const [],
    );
  }
}